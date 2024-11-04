import {Component, ElementRef, Input, OnInit, ViewChild, inject} from '@angular/core';
import {MatDialog} from '@angular/material/dialog';
import {Router} from '@angular/router';
import {AlertDialogComponent} from '@app/components/alert-dialog/alert-dialog.component';
import {GameConfigDialogComponent} from "@app/components/game-config-dialog/game-config-dialog.component";
import {HTTP_STATUS_CODE_CREATED} from '@common/constants/games-list.component.const';
import {QuizValidationService} from '@app/services/quiz-validation.service/quiz-validation.service';
import {QuizService} from '@app/services/quiz.service/quiz.service';
import {ErrorDictionary} from '@common/browser-message/error-message/error-message';
import {Quiz} from '@common/interfaces/quiz.interface';
import {getCurrentDateService} from 'src/utils/current-date-format/current-date-format';
import {generateRandomId} from 'src/utils/random-id-generator/random-id-generator';
import {QUIZ_TESTING_PAGE, WAITING_ROOM_HOST_PAGE} from '@common/page-url/page-url';
import {ErrorDialogComponent} from "@app/components/error-dialog/error-dialog.component";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {UniqueQuizNameDialogComponent} from "@app/components/unique-quiz-name-dialog/unique-quiz-name-dialog.component";

@Component({
    selector: 'app-games-list',
    templateUrl: './games-list.component.html',
    styleUrls: ['./games-list.component.scss'],
})
export class GamesListComponent implements OnInit {
    @Input() isAdmin: boolean;
    @Input() isImportError: boolean = false;
    @ViewChild('fileInput') fileInput: ElementRef<HTMLInputElement>;
    quizzes: Quiz[] = [];
    importedQuiz: Quiz;
    selectedQuiz: Quiz | null;
    errors: string | null = null;
    isErrors: boolean = false;
    isQuizUnique: boolean = true;

    private router = inject(Router);
    private fileReader: FileReader = new FileReader();
    private asyncFileResolver: () => void;
    private asyncFileRejecter: (error: unknown) => void;

    constructor(
        public quizServices: QuizService,
        public quizValidator: QuizValidationService,
        private dialog: MatDialog,
        private snackbar: SnackbarService
    ) {
    }

    ngOnInit() {
        this.populateGameList();
    }

    populateGameList() {
        if (this.isAdmin) this.getAllQuizzes();
        else this.getAllVisibleQuizzes();
    }

    getAllQuizzes() {
        this.quizServices.basicGetAll().subscribe((res) => {
            this.quizzes = res;
        });
    }

    getAllVisibleQuizzes() {
        this.quizServices.basicGetAllVisible().subscribe((res) => {
            this.quizzes = res;
        });
    }

    updateVisibility(quiz: Quiz) {
        this.quizServices.basicPatch(quiz.id, !quiz.visible).subscribe();
    }

    killErrorFeedback(value: boolean) {
        this.isQuizUnique = value;
        this.isErrors = !value;
        this.errors = null;
    }

    receiveQuizName(newName: string) {
        this.importedQuiz.title = newName;
        this.checkQuizNameUnique();
        this.isQuizUnique = true;
    }

    removeQuiz(id: string) {
        const index = this.quizzes.findIndex((quiz) => quiz.id === id);
        this.quizzes.splice(index, 1);
    }

    selectQuiz(quiz: Quiz): void {
        this.selectedQuiz = quiz;
    }

    selectFile(event: Event) {
        if (event.target instanceof HTMLInputElement) {
            const selectedFile = event.target.files && event.target.files[0];
            if (selectedFile?.type === 'application/json') this.readFile(selectedFile);
            event.target.value = '';
        }
    }

    async uploadFile() {
        this.fileInput.nativeElement.click();
        await this.waitForFileRead();
        this.validateFileData();
    }

    readFile(selectedFile: File) {
        this.fileReader.readAsText(selectedFile);
        this.fileReader.onload = (e) => this.extractQuizData(e);
    }

    extractQuizData(event: ProgressEvent<FileReader>) {
        try {
            this.importedQuiz = JSON.parse(event.target?.result as string);
            this.importedQuiz.lastModification = getCurrentDateService();
            this.resolveAsyncFileRead();
        } catch (error:any) {
            this.snackbar.show(`Erreur: ${error.message}`)
            this.rejectAsyncFileRead(error);
        }
    }

    // waitForFileRead returns a promise which permits the async/await syntax when importing
    // JSON file. This is enabling our program to force the code to wait for the user to complete
    // the import event before completing the execution of the code.
    async waitForFileRead(): Promise<void> {
        return new Promise<void>((resolve, reject) => {
            this.asyncFileResolver = resolve;
            this.asyncFileRejecter = reject;
        });
    }

    resolveAsyncFileRead(): void {
        this.asyncFileResolver();
    }

    rejectAsyncFileRead(error: unknown): void {
        this.asyncFileRejecter(error);
    }

    validateFileData() {
        const errors = this.quizValidator.validateQuiz(this.importedQuiz);
        if (errors.length === 0) {
            this.checkQuizNameUnique();
        } else {
            this.errors = this.setValidatorError(errors);
            this.showErrorDialog(this.errors)
        }
    }

    showErrorDialog(errorMessage: string): void {
        this.dialog.open(ErrorDialogComponent, {
            data: { errorMessage }
        });
    }

    setValidatorError(errors: string[]) {
        let index = 0;
        const isPlural = errors.length > 1;
        const endSentence = isPlural ? ErrorDictionary.ISSUES : ErrorDictionary.ISSUE;
        let errorMessage = ErrorDictionary.FILE_CONTAINS + `${endSentence} :\n\n `;
        errors.forEach((error) => {
            errorMessage += `\n${(index += 1)}- ${error}\n`;
        });
        errorMessage += ErrorDictionary.SOLUTION;
        return errorMessage;
    }

    checkQuizNameUnique() {
        this.quizServices.checkTitleUniqueness(this.importedQuiz.title).subscribe((res) => {
            this.treatResponse(res.body?.isUnique as boolean);
        });
    }

    treatResponse(value: boolean) {
        if (!value) {
            this.isQuizUnique = false;
            const dialogRef = this.dialog.open(UniqueQuizNameDialogComponent, {
                data: { quizName: this.importedQuiz.title }
            });
            dialogRef.afterClosed().subscribe((newName: string | null) => {
                if (newName) {
                    this.receiveQuizName(newName);
                } else {
                    this.killErrorFeedback(false);
                }
            });
        } else {
            this.importedQuiz.id = generateRandomId();
            this.addImportedQuiz();
        }
    }

    addImportedQuiz() {
        this.quizServices.basicPost(this.importedQuiz as Quiz).subscribe((res) => {
            if (res.status === HTTP_STATUS_CODE_CREATED) this.populateGameList();
        });
    }

    handleQuizAction(route: string){
        this.populateGameList();

        if (!this.selectedQuiz) return;

        this.quizServices.basicGetById(this.selectedQuiz.id).subscribe((res) => {
            this.selectedQuiz = null;

            if (res === null) {
                this.showError(ErrorDictionary.QUIZ_DELETED);
            } else if (res.visible) {
                this.router.navigate([route, res.id]);
            } else {
                this.showError(ErrorDictionary.QUIZ_INVISIBLE);
            }
        });
    }

    testGame() {
        this.handleQuizAction(`/${QUIZ_TESTING_PAGE}/`);
    }

    playGame() {
        const isConfigured = this.dialog.open(GameConfigDialogComponent).afterClosed()
        isConfigured.subscribe((res) => {
            console.log(`Response: ${res}`)
            if (res) this.handleQuizAction(`/${WAITING_ROOM_HOST_PAGE}/`);
        });
    }

    private showError(error: string) {
        this.dialog.open(AlertDialogComponent, {
            data: {
                title: ErrorDictionary.ERROR_TITLE_IMPORT,
                content: error,
            },
        });
    }
}
