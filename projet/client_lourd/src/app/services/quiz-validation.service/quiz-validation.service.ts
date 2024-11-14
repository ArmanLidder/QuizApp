import {inject, Injectable} from '@angular/core';
import {AbstractControl} from '@angular/forms';
import { Quiz, QuizChoice, QuizQuestion } from '@common/interfaces/quiz.interface';
import {
    DIVIDER,
    MIN_QUESTION_POINTS,
    MAX_QUESTION_POINTS,
    MAX_DURATION,
    MIN_DURATION,
    MIN_NUMBER_OF_CHOICES,
    MAX_NUMBER_OF_CHOICES
} from '@common/constants/quiz-validation.service.const';
import { QuestionType } from '@common/enums/question-type.enum';
import {MAX_NUMBER_ALLOWED, MIN_NUMBER_ALLOWED} from "@common/constants/qui-form.service.const";
import {TranslateService} from "@ngx-translate/core";

@Injectable({
    providedIn: 'root',
})
export class QuizValidationService {
    private translate = inject(TranslateService);

    isQuiz(quiz: unknown): quiz is Quiz {
        const isValid =
            typeof quiz === 'object' &&
            quiz !== null &&
            typeof (quiz as Quiz).title === 'string' &&
            typeof (quiz as Quiz).description === 'string' &&
            typeof (quiz as Quiz).duration === 'number' &&
            typeof (quiz as Quiz).lastModification === 'string' &&
            this.isQuestion(quiz as Quiz);
        return isValid;
    }

    validateChoicesForm(control: AbstractControl): { [key: string]: boolean } | null {
        const choices = control.value;
        if (
            choices.some((choice: QuizChoice) => (choice.isCorrect as unknown as string) === 'true') &&
            choices.some((choice: QuizChoice) => (choice.isCorrect as unknown as string) === 'false')
        ) {
            return null;
        } else {
            return { invalidChoices: true };
        }
    }

    divisibleByTen(control: AbstractControl): { [key: string]: boolean } | null {
        const value = control.value;
        return value % DIVIDER === 0 ? null : { notDivisibleByTen: true };
    }

    async validateQuiz(quiz: Quiz): Promise<string[]> {
        const errors: string[] = [];

        if (!quiz.title || !quiz.title.trim()) {
            errors.push(await this.translate.get('IMPORT_ERRORS.TITLE_REQUIRED').toPromise());
        } else if (quiz.title.length > 100) {
            errors.push(await this.translate.get('IMPORT_ERRORS.TITLE_MAX_LENGTH').toPromise());
        }

        if (!quiz.description || !quiz.description.trim()) {
            errors.push(await this.translate.get('IMPORT_ERRORS.DESCRIPTION_REQUIRED').toPromise());
        } else if (quiz.description.length > 250) {
            errors.push(await this.translate.get('IMPORT_ERRORS.DESCRIPTION_MAX_LENGTH').toPromise());
        }

        if (quiz.description && quiz.description.trim() === '') {
            errors.push(await this.translate.get('IMPORT_ERRORS.DESCRIPTION_ONLY_SPACES').toPromise());
        }

        if (quiz.title && quiz.title.trim() === '') {
            errors.push(await this.translate.get('IMPORT_ERRORS.TITLE_ONLY_SPACES').toPromise());
        }

        if (isNaN(quiz.duration) || quiz.duration < MIN_DURATION || quiz.duration > MAX_DURATION) {
            errors.push(await this.translate.get('IMPORT_ERRORS.INVALID_DURATION').toPromise());
        }

        if (!quiz.questions || quiz.questions.length === 0) {
            errors.push(await this.translate.get('IMPORT_ERRORS.MINIMUM_NUMBER_OF_QUESTIONS_REQUIRED').toPromise());
        } else {
            for (const [index, question] of quiz.questions.entries()) {
                const questionErrors = await this.validateQuestion(question, index);
                errors.push(...questionErrors);
            }
        }

        return errors;
    }


    async validateQuestion(question: QuizQuestion, index: number){
        const errors: string[] = [];

        if (!question.text || !question.text.trim()) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.TEXT_REQUIRED').toPromise()}`);
        } else if (question.text.length > 250) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.QUESTION_TEXT_MAX_LENGTH').toPromise()}`);
        }

        if (!question.points) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.QUESTION_POINTS_REQUIRED').toPromise()}`);
        }

        if (question.points < MIN_QUESTION_POINTS || question.points > MAX_QUESTION_POINTS) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INVALID_POINTS').toPromise()}`);
        }

        if (question.points % DIVIDER !== 0) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.NON_DIVISIBLE_BY_TEN').toPromise()}`);
        }

        if (![QuestionType.QCM, QuestionType.QRE, QuestionType.QRL].includes(question.type)) {
            errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.UNSUPPORTED_QUESTION_TYPE').toPromise()}`);
            return errors;
        }

        if (question.type === QuestionType.QCM) {
            const choicesErrors = await this.validateQuestionChoices(index, question.choices);
            errors.push(...choicesErrors);
        }

        if (question.type === QuestionType.QRE) {
            if (!Number.isInteger(question.answer)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_ANSWER_REQUIRED').toPromise()}`);
            }
            if (!Number.isInteger(question.margin)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_MARGIN_REQUIRED').toPromise()}`);
            }
            if (!Number.isInteger(question.interval?.min) || !Number.isInteger(question.interval?.max)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_INTERVAL_REQUIRED').toPromise()}`);
            }

            if (question.answer !== undefined && (question.answer < MIN_NUMBER_ALLOWED || question.answer > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.ANSWER_WITHIN_LIMITS').toPromise()} ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }
            if (question.interval?.min !== undefined && (question.interval.min < MIN_NUMBER_ALLOWED || question.interval.min > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.MINIMUM_WITHIN_LIMITS').toPromise()} ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }
            if (question.interval?.max !== undefined && (question.interval.max < MIN_NUMBER_ALLOWED || question.interval.max > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.MAXIMUM_WITHIN_LIMITS').toPromise()} ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }

            if (question.answer === undefined) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.QRE_ANSWER_REQUIRED').toPromise()}`);
                return errors;
            }

            if (!question.interval || question.interval.min === undefined || question.interval.max === undefined) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.QRE_INTERVAL_REQUIRED').toPromise()}`);
                return errors;
            }

            if (question.margin === undefined) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.QRE_MARGIN_REQUIRED').toPromise()}`);
                return errors;
            }

            if (question.interval.min > question.interval.max) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.MIN_LESS_THAN_MAX').toPromise()}`);
            }

            if (question.margin < 0) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.MARGIN_NON_NEGATIVE').toPromise()}`);
            }
            if (question.margin % 1 !== 0) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_MARGIN_REQUIRED').toPromise()}`);
            }
            if (question.answer % 1 !== 0) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_ANSWER_REQUIRED').toPromise()}`);
            }
            if (question.interval.min % 1 !== 0) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_INTERVAL_REQUIRED').toPromise()}`);
            }
            if (question.interval.max % 1 !== 0) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.INTEGER_INTERVAL_REQUIRED').toPromise()}`);
            }

            if (question.answer < question.interval.min || question.answer > question.interval.max) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.ANSWER_OUTSIDE_INTERVAL').toPromise()}`);
            }

            if (question.answer && question.answer.toString().includes('e')) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.SCIENTIFIC_NOTATION_NOT_ALLOWED').toPromise()} réponse.`);
            }
            if (question.interval?.min && question.interval.min.toString().includes('e')) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.SCIENTIFIC_NOTATION_NOT_ALLOWED').toPromise()} minimum.`);
            }
            if (question.interval?.max && question.interval.max.toString().includes('e')) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.SCIENTIFIC_NOTATION_NOT_ALLOWED').toPromise()} maximum.`);
            }
            if (question.margin.toString().includes('e')) {
                errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.SCIENTIFIC_NOTATION_NOT_ALLOWED').toPromise()} marge.`);
            }

            if (question.interval?.min !== undefined && question.interval?.max !== undefined) {
                const maxMargin = Math.abs((question.interval.max - question.interval.min) * 0.25);
                if (question.margin > maxMargin) {
                    errors.push(`Question ${index + 1} : ${await this.translate.get('IMPORT_ERRORS.MAX_MARGIN_LIMIT').toPromise()} ${Math.floor(maxMargin)} ${await this.translate.get('IMPORT_ERRORS.INTERVAL_25_PERCENT_LIMIT').toPromise()}`);
                }
            }
        }

        return errors;
    }



    async validateQuestionChoices(questionIndex: number, choices?: QuizChoice[]): Promise<string[]> {
        const errors: string[] = [];
        const choiceLabel = await this.translate.get('CHOICE_LABEL').toPromise();

        if (!choices || choices.length < MIN_NUMBER_OF_CHOICES || choices.length > MAX_NUMBER_OF_CHOICES) {
            errors.push(`Question ${questionIndex + 1} : ${await this.translate.get('IMPORT_ERRORS.INVALID_NUMBER_OF_CHOICES').toPromise()}`);
        } else {
            for (const [choiceIndex, choice] of choices.entries()) {
                if (!choice.text || !choice.text.trim()) {
                    errors.push(`Question ${questionIndex + 1}, ${choiceLabel} ${choiceIndex + 1} : ${await this.translate.get('IMPORT_ERRORS.TEXT_REQUIRED').toPromise()}`);
                } else if (choice.text.length > 50) {
                    errors.push(`Question ${questionIndex + 1}, ${choiceLabel} ${choiceIndex + 1} : ${await this.translate.get('IMPORT_ERRORS.CHOICE_TEXT_MAX_LENGTH').toPromise()}`);
                }

                if (choice.isCorrect === null || choice.isCorrect === undefined) {
                    errors.push(`Question ${questionIndex + 1}, ${choiceLabel} ${choiceIndex + 1} : ${await this.translate.get('IMPORT_ERRORS.INVALID_CHOICE').toPromise()}`);
                }
            }

            const hasCorrectChoice = choices.some((choice) => choice.isCorrect);
            const hasIncorrectChoice = choices.some((choice) => !choice.isCorrect);

            if (!hasCorrectChoice || !hasIncorrectChoice) {
                errors.push(`Question ${questionIndex + 1} : ${await this.translate.get('IMPORT_ERRORS.INVALID_QUESTION_CHOICES').toPromise()}`);
            }
        }
        return errors;
    }



    private isQuestion(quiz: Quiz): boolean {
        return (
            Array.isArray(quiz.questions) &&
            quiz.questions.every(
                (question) =>
                    typeof question.type === 'number' &&
                    typeof question.text === 'string' &&
                    typeof question.points === 'number' &&
                    Array.isArray(question.choices) &&
                    question.choices.every(
                        (choice) => typeof choice.text === 'string' && (choice.isCorrect === undefined || typeof choice.isCorrect === 'boolean'),
                    ),
            )
        );
    }

    validateInterval(control: AbstractControl): { [key: string]: boolean } | null {
        const min = control.get('min')?.value;
        const max = control.get('max')?.value;
        if (min !== undefined && max !== undefined && max < min) {
            return { maxLessThanMin: true };
        }
        return null;
    }


    validateAnswerInRange(control: AbstractControl, min: number, max: number): { [key: string]: boolean } | null {
        const answer = control.value;
        if (answer < min || answer > max) {
            return { answerOutOfRange: true };
        }
        return null;
    }


    validateMarginWithinLimit(control: AbstractControl): { [key: string]: boolean } | null {
        const min = control.parent?.get('interval.min')?.value;
        const max = control.parent?.get('interval.max')?.value;
        const margin = control.value;

        if (min !== undefined && max !== undefined && margin !== undefined) {
            const maxMargin = Math.abs((max - min) / 4);
            if (margin > maxMargin) {
                return { marginTooLarge: true };
            }
        }
        return null;
    }


}
