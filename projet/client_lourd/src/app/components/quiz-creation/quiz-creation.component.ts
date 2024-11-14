import {Component, Injector, OnInit} from '@angular/core';
import {FormArray, FormGroup} from '@angular/forms';
import {MatDialog} from '@angular/material/dialog';
import {ActivatedRoute, Router} from '@angular/router';
import {POPUP_TIMEOUT} from '@common/constants/quiz-creation.component.const';
import {QuizFormService} from '@app/services/quiz-form-service/quiz-form.service';
import {QuizValidationService} from '@app/services/quiz-validation.service/quiz-validation.service';
import {QuizService} from '@app/services/quiz.service/quiz.service';
import {Quiz} from '@common/interfaces/quiz.interface';
import {PageMode} from 'src/enums/page-mode.enum';
import {generateRandomId} from 'src/utils/random-id-generator/random-id-generator';
import {GAME_ADMIN_PAGE} from '@common/page-url/page-url';
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {UsersService} from "@app/services/users.service/users.service";
import {User} from "@common/interfaces/user-data.interface";
import {firstValueFrom, Observable} from "rxjs";
import {ErrorDialogComponent} from "@app/components/error-dialog/error-dialog.component";
import {TranslateService} from "@ngx-translate/core";


@Component({
    selector: 'app-quiz-creation',
    templateUrl: './quiz-creation.component.html',
    styleUrls: ['./quiz-creation.component.scss'],
})
export class QuizCreationComponent implements OnInit{
    quizForm: FormGroup;
    quiz: Quiz;
    mode: PageMode;
    isPopupVisibleDuration: boolean;
    isPopupVisibleForm: boolean;
    formErrors: string[];
    owner : Observable<User|null >;
    protected readonly pageModel = PageMode;
    currentUid: string | undefined;
    private quizFormService: QuizFormService;
    private quizValidationService: QuizValidationService;
    private quizService: QuizService;
    private route: ActivatedRoute;
    private navigateRoute: Router;
    private snackBar: SnackbarService;
    private usersService: UsersService;
    constructor(
        injector: Injector,
        private dialog: MatDialog,
        private translate: TranslateService
    ) {
        this.quizFormService = injector.get<QuizFormService>(QuizFormService);
        this.quizValidationService = injector.get<QuizValidationService>(QuizValidationService);
        this.quizService = injector.get<QuizService>(QuizService);
        this.route = injector.get<ActivatedRoute>(ActivatedRoute);
        this.navigateRoute = injector.get<Router>(Router);
        this.snackBar = injector.get<SnackbarService>(SnackbarService)
        this.usersService = injector.get<UsersService>(UsersService)
    }

    async ngOnInit() {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        this.currentUid = currentUser?.uid;
        this.isPopupVisibleDuration = false;
        this.isPopupVisibleForm = false;
        this.formErrors = [];
        const id = this.route.snapshot.paramMap.get('id');
        const isImport = this.route.snapshot.queryParamMap.has('import');

        if (id) {
            this.mode = PageMode.MODIFICATION;
            this.quiz = await firstValueFrom(this.quizService.basicGetById(id));
            this.quizFormService.quiz = this.quiz;
            this.quizForm = await this.quizFormService.fillForm(this.quiz);
        } else if (isImport) {
            this.mode = PageMode.CREATION;
            this.quizForm = await this.quizFormService.fillForm(this.quizFormService.quiz);
            this.markFormGroupTouched(this.quizForm);
        } else {
            this.quizForm = await this.quizFormService.fillForm();
            this.mode = PageMode.CREATION;
        }

        this.isPopupVisibleForm = false;

        if (this.quizForm) {
            const ownerId = this.quizForm.get('owner')?.value;
            if (ownerId) {
                this.owner = this.usersService.getUser(ownerId);
            }
        }
    }

    private markFormGroupTouched(formGroup: FormGroup) {
        (<any>Object).values(formGroup.controls).forEach((control: FormGroup<any>) => {
            if (control.controls) { // control is a FormGroup
                this.markFormGroupTouched(control);
            } else { // control is a FormControl
                control.markAsTouched();
            }
        });
    }

    get questionsArray() {
        return this.quizForm.get('questions') as FormArray;
    }

    showPopupIfFormConditionMet(condition: boolean) {
        if (condition) {
            this.isPopupVisibleForm = true;
            setTimeout(() => {
                this.isPopupVisibleForm = false;
            }, POPUP_TIMEOUT);
        }
        return condition;
    }

    onSubmit() {
        const quiz = this.quizFormService.extractQuizFromForm(this.quizForm, this.questionsArray);
        if (this.quizForm?.valid) {
            const title = this.quizForm.get('title')?.value;
            const isOwner = this.currentUid === this.quizForm.get('owner')?.value;

            if (this.mode === PageMode.MODIFICATION && !isOwner) {
                this.quizService.basicGetById(this.quiz.id).subscribe(async (latestQuiz: Quiz) => {
                    if (latestQuiz === null) {
                        this.openErrorDialog(await this.translate.get('QUIZ_CREATION.QUIZ_DELETED_BY_OTHER_USER').toPromise());
                        await this.navigateRoute.navigate([`/${GAME_ADMIN_PAGE}`]);
                        return;
                    }
                    if (!isOwner && !latestQuiz.visible) {
                        this.openErrorDialog(await this.translate.get('QUIZ_CREATION.QUIZ_VISIBILITY_CHANGED_TO_PRIVATE').toPromise());
                        await this.navigateRoute.navigate([`/${GAME_ADMIN_PAGE}`]);
                        return;
                    }
                    this.checkTitleUniquenessAndUpdateQuiz(title, quiz);
                });
            } else {
                this.checkTitleUniquenessAndUpdateQuiz(title, quiz);
            }
        } else {
            this.formErrors = this.quizValidationService.validateQuiz(quiz);
            this.showPopupIfFormConditionMet(true);
        }
    }

    private checkTitleUniquenessAndUpdateQuiz(title: string, quiz: Quiz) {
        this.quizService.checkTitleUniqueness(title).subscribe(async (response) => {
            if (response.body?.isUnique || (this.mode === PageMode.MODIFICATION && response.body?.id == quiz.id)) {
                this.addOrUpdateQuiz(quiz);
            } else {
                this.openErrorDialog(await this.translate.get('QUIZ_CREATION.TITLE_ALREADY_EXISTS').toPromise());
            }
        });
    }



    private async addOrUpdateQuiz(quiz: Quiz) {
        const navigateToAdminCallBack = () => {
            this.navigateRoute.navigate([`/${GAME_ADMIN_PAGE}`]);
        };

        if (this.mode === PageMode.MODIFICATION) {
            quiz.id = this.quiz.id;
            this.quizService.basicPut(quiz).subscribe(async () => {
                const message = await this.translate.get('QUIZ_CREATION.QUIZ_UPDATED_SUCCESS').toPromise();
                this.snackBar.show(message);
                navigateToAdminCallBack();
            });
        } else {
            quiz.id = generateRandomId();
            this.quizService.basicPost(quiz).subscribe(async () => {
                const message = await this.translate.get('QUIZ_CREATION.QUIZ_ADDED_SUCCESS').toPromise();
                this.snackBar.show(message);
                navigateToAdminCallBack();
            });
        }
    }




    private openErrorDialog(message:string) {
        this.dialog.open(ErrorDialogComponent, {
            data: {
                errorMessage: message,
            },
        });
    }
}
