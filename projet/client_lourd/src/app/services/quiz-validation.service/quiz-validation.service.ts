import { Injectable } from '@angular/core';
import {AbstractControl} from '@angular/forms';
import { Quiz, QuizChoice, QuizQuestion } from '@common/interfaces/quiz.interface';
import {
    DIVIDER,
    MIN_QUESTION_POINTS,
    MAX_QUESTION_POINTS,
    MAX_DURATION,
    MIN_DURATION,
    MIN_NUMBER_OF_CHOICES,
    MAX_NUMBER_OF_CHOICES,
    TITLE_REQUIRED,
    DESCRIPTION_REQUIRED,
    INVALID_DURATION,
    MINIMUM_NUMBER_OF_QUESTIONS_REQUIRED,
    TEXT_REQUIRED,
    QUESTION_POINTS_REQUIRED,
    INVALID_POINTS,
    NON_DIVISIBLE_BY_TEN,
    INVALID_NUMBER_OF_CHOICES,
    INVALID_CHOICE,
    INVALID_QUESTION_CHOICES,
} from '@common/constants/quiz-validation.service.const';
import { QuestionType } from '@common/enums/question-type.enum';
import {MAX_NUMBER_ALLOWED, MIN_NUMBER_ALLOWED} from "@common/constants/qui-form.service.const";

@Injectable({
    providedIn: 'root',
})
export class QuizValidationService {
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

    validateQuiz(quiz: Quiz): string[] {
        const errors: string[] = [];

        if (!quiz.title || !quiz.title.trim()) {
            errors.push(TITLE_REQUIRED);
        } else if (quiz.title.length > 100) {
            errors.push('Le titre doit contenir au maximum 100 caractères.');
        }

        if (!quiz.description || !quiz.description.trim()) {
            errors.push(DESCRIPTION_REQUIRED);
        } else if (quiz.description.length > 250) {
            errors.push('La description doit contenir au maximum 250 caractères.');
        }

        if (isNaN(quiz.duration) || quiz.duration < MIN_DURATION || quiz.duration > MAX_DURATION) {
            errors.push(INVALID_DURATION);
        }

        if (!quiz.questions || quiz.questions.length === 0) {
            errors.push(MINIMUM_NUMBER_OF_QUESTIONS_REQUIRED);
        } else {
            quiz.questions.forEach((question, index) => {
                const questionErrors = this.validateQuestion(question, index);
                errors.push(...questionErrors);
            });
        }

        return errors;
    }

    validateQuestion(question: QuizQuestion, index: number): string[] {
        const errors: string[] = [];

        if (!question.text || !question.text.trim()) {
            errors.push(`Question ${index + 1} : ${TEXT_REQUIRED}.`);
        } else if (question.text.length > 250) {
            errors.push(`Question ${index + 1} : le texte de la question doit contenir au maximum 250 caractères.`);
        }

        if (!question.points) {
            errors.push(`Question ${index + 1} : ${QUESTION_POINTS_REQUIRED}`);
        }

        if (question.points < MIN_QUESTION_POINTS || question.points > MAX_QUESTION_POINTS) {
            errors.push(`Question ${index + 1} : ${INVALID_POINTS}`);
        }

        if (question.points % DIVIDER !== 0) {
            errors.push(`Question ${index + 1} : ${NON_DIVISIBLE_BY_TEN}`);
        }

        if (question.type !== QuestionType.QCM && question.type !== QuestionType.QRE && question.type !== QuestionType.QRL) {
            errors.push(`Question ${index + 1} : ce type de question n'est pas supporté`);
            return errors;
        }

        if (question.type === QuestionType.QCM) {
            const choicesErrors = this.validateQuestionChoices(index, question.choices);
            errors.push(...choicesErrors);
        }

        if (question.type === QuestionType.QRE) {
            if (!Number.isInteger(question.answer)) {
                errors.push(`Question ${index + 1} : la réponse doit être un nombre entier.`);
            }
            if (!Number.isInteger(question.margin)) {
                errors.push(`Question ${index + 1} : la marge doit être  un nombre entier.`);
            }
            if (!Number.isInteger(question.interval?.min) || !Number.isInteger(question.interval?.max)) {
                errors.push(`Question ${index + 1} : les intervalles doivent être des nombres entiers.`);
            }

            if (question.answer !== undefined && (question.answer < MIN_NUMBER_ALLOWED || question.answer > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : la réponse doit être entre ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }
            if (question.interval?.min !== undefined && (question.interval.min < MIN_NUMBER_ALLOWED || question.interval.min > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : le minimum doit être entre ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }
            if (question.interval?.max !== undefined && (question.interval.max < MIN_NUMBER_ALLOWED || question.interval.max > MAX_NUMBER_ALLOWED)) {
                errors.push(`Question ${index + 1} : le maximum doit être entre ${MIN_NUMBER_ALLOWED} et ${MAX_NUMBER_ALLOWED}.`);
            }

            if (question.answer === undefined) {
                errors.push(`Question ${index + 1} : la réponse est requise pour les questions de type QRE.`);
                return errors;
            }

            if (!question.interval || question.interval.min === undefined || question.interval.max === undefined) {
                errors.push(`Question ${index + 1} : l'intervalle min et max sont requis pour les questions de type QRE.`);
                return errors;
            }

            if (question.margin === undefined) {
                errors.push(`Question ${index + 1} : la marge est requise pour les questions de type QRE.`);
                return errors;
            }

            if (question.interval.min > question.interval.max) {
                errors.push(`Question ${index + 1} : l'intervalle min doit être inférieur ou égal à max.`);
            }

            if (question.margin < 0) {
                errors.push(`Question ${index + 1} : la marge de tolérance doit être 0 ou plus.`);
            }
            if (question.margin % 1 !== 0) {
                errors.push(`Question ${index + 1} : la marge de tolérance doit être un nombre entier.`);
            }
            if (question.answer % 1 !== 0) {
                errors.push(`Question ${index + 1} : la réponse doit être un nombre entier.`);
            }
            if (question.interval.min % 1 !== 0) {
                errors.push(`Question ${index + 1} : le minimum doit être un nombre entier.`);
            }
            if (question.interval.max % 1 !== 0) {
                errors.push(`Question ${index + 1} : le maximum doit être un nombre entier.`);
            }

            if (question.answer < question.interval.min || question.answer > question.interval.max) {
                errors.push(`Question ${index + 1} : la réponse doit être inclus dans l'intervalle.`);
            }

            if (question.answer && question.answer.toString().includes('e')) {
                errors.push(`Question ${index + 1} : la réponse ne doit pas être en notation scientifique.`);
            }
            if (question.interval?.min && question.interval.min.toString().includes('e')) {
                errors.push(`Question ${index + 1} : le minimum ne doit pas être en notation scientifique.`);
            }
            if (question.interval?.max && question.interval.max.toString().includes('e')) {
                errors.push(`Question ${index + 1} : le maximum ne doit pas être en notation scientifique.`);
            }
            if (question.margin.toString().includes('e')) {
                errors.push(`Question ${index + 1} : la marge ne doit pas être en notation scientifique.`);
            }

            if (question.interval?.min !== undefined && question.interval?.max !== undefined) {
                const maxMargin = Math.abs((question.interval.max - question.interval.min) * 0.25);
                if (question.margin > maxMargin) {
                    errors.push(`Question ${index + 1} : la marge doit être au maximum ${Math.floor(maxMargin)} (25% de l'intervalle)`);
                }
            }
        }

        return errors;
    }


    validateQuestionChoices(questionIndex: number, choices?: QuizChoice[]): string[] {
        const errors: string[] = [];

        if (!choices || choices.length < MIN_NUMBER_OF_CHOICES || choices.length > MAX_NUMBER_OF_CHOICES) {
            errors.push(`Question ${questionIndex + 1} : ${INVALID_NUMBER_OF_CHOICES}`);
        } else {
            choices.forEach((choice, choiceIndex) => {
                if (!choice.text || !choice.text.trim()) {
                    errors.push(`Question ${questionIndex + 1}, Choix ${choiceIndex + 1} : ${TEXT_REQUIRED}`);
                } else if (choice.text.length > 50) {
                    errors.push(`Question ${questionIndex + 1}, Choix ${choiceIndex + 1} : le texte du choix doit contenir au maximum 50 caractères.`);
                }

                if (choice.isCorrect === null || choice.isCorrect === undefined) {
                    errors.push(`Question ${questionIndex + 1}, Choix ${choiceIndex + 1} : ${INVALID_CHOICE}`);
                }
            });

            const hasCorrectChoice = choices.some((choice) => choice.isCorrect);
            const hasIncorrectChoice = choices.some((choice) => !choice.isCorrect);

            if (!hasCorrectChoice || !hasIncorrectChoice) {
                errors.push(`Question ${questionIndex + 1} : ${INVALID_QUESTION_CHOICES}`);
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
