import {Component, Input, OnDestroy} from '@angular/core';
import {AbstractControl, FormArray, FormGroup} from '@angular/forms';
import {MAX_IMG_SIZE, POPUP_TIMEOUT} from '@common/constants/quiz-creation.component.const';
import { ChoiceService } from '@app/services/choice-service/choice.service';
import { QuestionService } from '@app/services/question-service/question.service';
import { ItemMovingDirection } from 'src/enums/item-moving-direction';
import { QuestionChoicePosition } from '@app/interfaces/question-choice-position/question-choice-position';
import {QuestionImageService} from "@app/services/question-image.service/question-image.service";
import {NON_EXISTANT_INDEX} from "@common/constants/question.service.const";
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-question-list',
    templateUrl: './question-list.component.html',
    styleUrls: ['./question-list.component.scss'],
})
export class QuestionListComponent implements OnDestroy {
    @Input() questionsArray: FormArray | undefined;
    @Input() parentGroup: FormGroup;
    isPopUpVisible: boolean = false;
    questionErrors: string[] = [];
    protected readonly itemMovingDirection = ItemMovingDirection;
    imageUploadError: string | null = null;
    isUploading: boolean = false;
    constructor(
        private questionService: QuestionService,
        private choiceService: ChoiceService,
        private questionImageService: QuestionImageService,
        private translate: TranslateService
    ) {}
    ngOnDestroy() {
        this.questionService.modifiedQuestionIndex = NON_EXISTANT_INDEX;
    }

    async onImageSelected(event: Event, index: number) {
        const input = event.target as HTMLInputElement;
        (this.questionsArray?.at(index) as FormGroup).get('imageUrl')?.setValue(null);
        if (input.files && input.files.length > 0) {
            const file = input.files[0];
            if (file.size > MAX_IMG_SIZE) {
                this.imageUploadError = await this.translate.get('QUIZ_CREATION.QUESTION_LIST.IMAGE_SIZE_ERROR').toPromise();
                return;
            }
            this.imageUploadError = null;
            try {
                this.isUploading = true;
                const imageUrl = await this.questionImageService.uploadQuestionImage(file, this.parentGroup.get('id')?.value);
                this.isUploading = false;
                (this.questionsArray?.at(index) as FormGroup).get('imageUrl')?.setValue(imageUrl);
            } catch (error) {
                return;
            }
        }
    }

    showPopupIfConditionMet(condition: boolean) {
        if (condition) {
            this.isPopUpVisible = true;
            setTimeout(() => {
                this.isPopUpVisible = false;
            }, POPUP_TIMEOUT);
        }
        return condition;
    }

    async addQuestion(index: number) {
        this.questionErrors = await this.questionService.addQuestion(index, this.questionsArray)
        if (index >= 0 ) {
            this.showPopupIfConditionMet(this.questionErrors.length !== 0);
        }
    }

    removeQuestion(index: number) {
        this.questionService.removeQuestion(index, this.questionsArray);
    }

    async modifyQuestion(index: number) {
        this.questionErrors = await this.questionService.modifyQuestion(index, this.questionsArray);
        this.showPopupIfConditionMet(this.questionErrors.length !== 0);
    }
    async saveQuestion(index: number) {
        this.questionErrors = await this.questionService.saveQuestion(index, this.questionsArray);
        this.showPopupIfConditionMet(this.questionErrors.length !== 0);
    }

    moveQuestionUp(index: number) {
        this.questionService.moveQuestionUp(index, this.questionsArray);
    }

    moveQuestionDown(index: number) {
        this.questionService.moveQuestionDown(index, this.questionsArray);
    }

    moveChoice(direction: ItemMovingDirection, questionIndex: number, choiceIndex: number) {
        const choicePosition: QuestionChoicePosition = { questionNumber: questionIndex, choiceNumber: choiceIndex };
        this.choiceService.moveChoice(direction, choicePosition, this.questionsArray);
    }

    addChoice(questionIndex: number, choiceIndex: number) {
        this.choiceService.addChoice(questionIndex, choiceIndex, this.questionsArray);
    }

    removeChoice(questionIndex: number, choiceIndex: number) {
        this.choiceService.removeChoice(questionIndex, choiceIndex, this.questionsArray);
    }
    getChoicesArray(index: number) {
        return this.choiceService.getChoicesArray(index, this.questionsArray);
    }

    calculateMarginLimit(min: number | null, max: number | null): string {
        if (min === null || max === null) return '';
        const limit = Math.abs((max - min) / 4);
        return Math.floor(limit).toString();
    }


    calculateAnswerInterval(answer: number | null, margin: number | null, min: number | null, max: number | null): string {
        if (
            answer === null || answer === undefined ||
            margin === null || margin === undefined ||
            min === null || min === undefined ||
            max === null || max === undefined
        ) return '';

        const lowerBound = Math.max(answer - margin, min);
        const upperBound = Math.min(answer + margin, max);

        return `${lowerBound}, ${upperBound}`;
    }

    hasValidInterval(question: AbstractControl): boolean {
        const answerControl = question.get('answer');
        const marginControl = question.get('margin');
        const minControl = question.get('interval.min');
        const maxControl = question.get('interval.max');

        return answerControl?.value != null &&
            marginControl?.value != null &&
            minControl?.value != null &&
            maxControl?.value != null &&
            marginControl?.value >=0 &&
            !answerControl.errors &&
            !marginControl.errors &&
            !minControl.errors &&
            !maxControl.errors;
    }

    removeImage(index: number) {
        (this.questionsArray?.at(index) as FormGroup).get('imageUrl')?.setValue(null);
    }
}
