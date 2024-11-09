import { Component, Input, Output, EventEmitter, ViewChild, ElementRef } from '@angular/core';
import { Quiz } from '@common/interfaces/quiz.interface';
import { QuizService } from '@app/services/quiz.service/quiz.service';
import { Router } from '@angular/router';
import { QUIZ_CREATION } from '@common/page-url/page-url';
import { MatDialog } from '@angular/material/dialog';
import { UsersService } from '@app/services/users.service/users.service';
import { firstValueFrom } from 'rxjs';
import { ErrorDialogComponent } from '@app/components/error-dialog/error-dialog.component';
import {ConfirmationDialogComponent} from "@app/components/confirmation-dialog/confirmation-dialog.component";
import {PopUpMessage} from "@common/browser-message/displayable-message/pop-up-message";

@Component({
    selector: 'app-game-item',
    templateUrl: './game-item.component.html',
    styleUrls: ['./game-item.component.scss'],
})
export class GameItemComponent {
    @ViewChild('downloadLink', { static: false }) downloadLink!: ElementRef;
    @Input() quiz: Quiz;
    @Input() isAdmin: boolean;
    @Output() removeQuiz: EventEmitter<string> = new EventEmitter<string>();
    @Output() refresh: EventEmitter<void> = new EventEmitter<void>();
    currentUid: string | undefined;

    constructor(
        private quizService: QuizService,
        private usersService: UsersService,
        private router: Router,
        private dialog: MatDialog
    ) {
        this.loadCurrentUser();
    }

    async loadCurrentUser() {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        this.currentUid = currentUser?.uid;
    }

    private checkOwnershipAndVisibility(callback: () => void): void {
        this.quizService.basicGetById(this.quiz.id).subscribe((latestQuiz: Quiz) => {
            if(!latestQuiz) {
                this.openErrorDialog('Ce jeu n\'existe plus');
                this.refresh.emit();
                return;
            }
            if (!latestQuiz.visible && this.currentUid !== latestQuiz.owner) {
                this.openErrorDialog('Ce jeu a été défini comme privé par le créateur et ne peut pas être modifié/exporté/supprimé');
                return;
            } else {
                callback();
            }
        });
    }

    deleteGame(): void {
        const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
            data: {message: PopUpMessage.DELETE_QUIZ_MESSAGE},
        });
        dialogRef.afterClosed().subscribe(async (result) => {
            if (result) {
                this.checkOwnershipAndVisibility(() => {
                    this.quizService.basicDelete(this.quiz.id).subscribe(() => {
                        this.removeQuiz.emit(this.quiz.id);
                    });
                });
            }
        });
    }

    updateGame(): void {
        this.checkOwnershipAndVisibility(() => {
            this.router.navigate([QUIZ_CREATION, `${this.quiz.id}`]);
        });
    }

    exportGame(): void {
        this.checkOwnershipAndVisibility(() => {
            const url = this.buildJSONFile(this.formatQuiz());
            this.startExportFile(url);
            window.URL.revokeObjectURL(url);
        });
    }

    formatQuiz(): object {
        const { ...exportedQuiz } = this.quiz;
        delete exportedQuiz.visible;
        return exportedQuiz;
    }

    buildJSONFile(formattedQuiz: object): string {
        const blob = new Blob([JSON.stringify(formattedQuiz)], { type: 'application/json' });
        return window.URL.createObjectURL(blob);
    }

    startExportFile(url: string): void {
        const a = this.downloadLink.nativeElement;
        a.href = url;
        a.download = this.quiz.title + '.json';
        a.click();
    }

    private openErrorDialog(message: string): void {
        this.dialog.open(ErrorDialogComponent, {
            data: { errorMessage: message },
        });
    }
}
