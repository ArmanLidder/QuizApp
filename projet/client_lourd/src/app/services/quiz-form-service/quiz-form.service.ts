import { Injectable } from '@angular/core';
import { AbstractControl, FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import {
    MAX_NUMBER_OF_CHOICES_PER_QUESTION,
    MAX_POINTS_PER_QUESTION,
    MAX_QCM_DURATION,
    MIN_NUMBER_OF_CHOICES_PER_QUESTION,
    MIN_NUMBER_OF_QUESTIONS,
    MIN_POINTS_PER_QUESTION,
    MIN_QCM_DURATION,
} from '@common/constants/qui-form.service.const';
import { QuizValidationService } from '@app/services/quiz-validation.service/quiz-validation.service';
import { QuestionType } from '@common/enums/question-type.enum';
import { Quiz, QuizChoice, QuizQuestion } from '@common/interfaces/quiz.interface';
import { getCurrentDateService } from 'src/utils/current-date-format/current-date-format';

@Injectable({
    providedIn: 'root',
})
export class QuizFormService {
    quiz: Quiz;

    constructor(
        private formBuilder: FormBuilder,
        private validationService: QuizValidationService,
    ) {}

    fillForm(quiz?: Quiz) {
        const quizForm: FormGroup = this.formBuilder.group({
            title: [quiz?.title, Validators.required],
            duration: [quiz?.duration, [Validators.required, Validators.min(MIN_QCM_DURATION), Validators.max(MAX_QCM_DURATION)]],
            description: [quiz?.description, Validators.required],
            questions: this.formBuilder.array([], [Validators.minLength(MIN_NUMBER_OF_QUESTIONS), Validators.required]),
            visible: [quiz?.visible],
        });
        this.fillQuestions(quizForm.get('questions') as FormArray, quiz?.questions);
        return quizForm;
    }

    fillQuestions(questionsFormArray: FormArray, quizQuestions?: QuizQuestion[]) {
        quizQuestions?.forEach((question) => {
            questionsFormArray.push(this.initQuestion(question));
        });
    }

    initQuestion(question?: QuizQuestion): FormGroup {
        const questionForm = this.formBuilder.group({
            type: [
                question?.type === QuestionType.QCM ? 'QCM' :
                    question?.type === QuestionType.QRE ? 'QRE' : 'QRL',
                Validators.required
            ],
            text: [question?.text ?? '', Validators.required],
            points: [
                question?.points ?? null,
                [
                    Validators.required,
                    Validators.min(MIN_POINTS_PER_QUESTION),
                    Validators.max(MAX_POINTS_PER_QUESTION),
                    this.validationService.divisibleByTen,
                ],
            ],
            choices: this.formBuilder.array(
                [],
                question?.type === QuestionType.QCM
                    ? [
                        Validators.minLength(MIN_NUMBER_OF_CHOICES_PER_QUESTION),
                        Validators.maxLength(MAX_NUMBER_OF_CHOICES_PER_QUESTION),
                        this.validationService.validateChoicesForm,
                    ]
                    : [],
            ),
            answer: [
                question?.answer ?? null,
                question?.type === QuestionType.QRE
                    ? [Validators.required,Validators.pattern("^[0-9]*$"), (control: any) => this.validationService.validateAnswerInRange(control, question?.interval?.min || 0, question?.interval?.max || 0)]
                    : []
            ],

            interval: this.formBuilder.group(
                {
                    min: [
                        question?.interval?.min ?? null,
                        question?.type === QuestionType.QRE
                            ? [Validators.required, Validators.pattern("^[0-9]*$")]
                            : []
                    ],
                    max: [
                        question?.interval?.max ?? null,
                        question?.type === QuestionType.QRE
                            ? [Validators.required, Validators.pattern("^[0-9]*$")]
                            : []
                    ],
                },
                { validators: question?.type === QuestionType.QRE ? this.validationService.validateInterval : [] }
            ),

            margin: [
                question?.margin ?? null,
                question?.type === QuestionType.QRE ? [Validators.required, Validators.pattern("^[0-9]*$"), this.validationService.validateMarginWithinLimit, Validators.min(0)] : []
            ],
            beingModified: question === undefined,
        });
        this.attachListenerToQuestionType(questionForm);
        this.fillChoices(questionForm.get('choices') as FormArray, question?.choices);
        return questionForm;
    }


    extractQuestion(questionForm?: AbstractControl) {
        const question: QuizQuestion = {
            type: questionForm?.get('type')?.value === 'QCM' ? QuestionType.QCM :
                questionForm?.get('type')?.value === 'QRE' ? QuestionType.QRE : QuestionType.QRL,
            text: questionForm?.get('text')?.value,
            points: questionForm?.get('points')?.value,
            choices: questionForm?.get('type')?.value === 'QCM' ? [] : undefined,
            answer: questionForm?.get('type')?.value === 'QRE' ? questionForm.get('answer')?.value : undefined,
            interval: questionForm?.get('type')?.value === 'QRE' ? questionForm.get('interval')?.value : undefined,
            margin: questionForm?.get('type')?.value === 'QRE' ? questionForm.get('margin')?.value : undefined,

        };
        questionForm?.get('choices')?.value?.forEach((choiceForm: QuizChoice) => {
            const choice: QuizChoice = {
                text: choiceForm.text,
                isCorrect: choiceForm.isCorrect,
            };
            question.choices?.push(choice);
        });
        return question;
    }

    fillChoices(choicesFormArray: FormArray, choices?: QuizChoice[]) {
        choices?.forEach((choice) => {
            choicesFormArray.push(this.initChoice(choice));
        });
    }

    initChoice(choice?: QuizChoice): FormGroup {
        return this.formBuilder.group({
            text: [choice?.text, Validators.required],
            isCorrect: [choice?.isCorrect ? 'true' : 'false'],
        });
    }

    extractQuizFromForm(quizForm: FormGroup, questionsArray: FormArray) {
        const now = getCurrentDateService();
        const questions: QuizQuestion[] = [];
        questionsArray.controls.forEach((questionForm) => {
            const question: QuizQuestion = this.extractQuestionFromForm(questionForm as FormArray);
            questions.push(question);
        });

        const quiz: Quiz = {
            id: this.quiz?.id,
            title: quizForm.value.title,
            description: quizForm.value.description,
            duration: quizForm.value.duration,
            lastModification: now,
            questions,
            visible: quizForm.value.visible,
        };
        return quiz;
    }

    private extractQuestionFromForm(questionForm: FormArray): QuizQuestion {
        const type = questionForm.get('type')?.value;

        // Initialize the question object
        const question: QuizQuestion = {
            type: type === 'QCM' ? QuestionType.QCM : type === 'QRE' ? QuestionType.QRE : QuestionType.QRL,
            text: questionForm.get('text')?.value,
            points: questionForm.get('points')?.value,
            choices: type === 'QCM' ? [] : undefined, // Only QCM questions have choices
            answer: type === 'QRE' ? questionForm.get('answer')?.value : undefined, // Only QRE questions have an answer
            interval: type === 'QRE' ? questionForm.get('interval')?.value : undefined, // Only QRE questions have an interval
            margin: type === 'QRE' ? questionForm.get('margin')?.value : undefined, // Only QRE questions have a margin
        };

        if (type === 'QCM') {
            (questionForm.get('choices') as FormArray).controls.forEach((choiceForm) => {
                const choice = this.extractChoiceFromForm(choiceForm as FormArray);
                question.choices?.push(choice);
            });
        }

        return question;
    }

    private extractChoiceFromForm(choiceForm: FormArray): QuizChoice {
        return {
            text: choiceForm.get('text')?.value,
            isCorrect: choiceForm.get('isCorrect')?.value === 'true',
        };
    }
    //ugly function but it works
    private attachListenerToQuestionType(questionForm: FormGroup) {
        questionForm.get('type')?.valueChanges.subscribe((type: string | null) => {
            const choicesControl = questionForm.get('choices') as FormArray;
            if (type === 'QCM') {
                choicesControl.setValidators([
                    Validators.minLength(MIN_NUMBER_OF_CHOICES_PER_QUESTION),
                    Validators.maxLength(MAX_NUMBER_OF_CHOICES_PER_QUESTION),
                    this.validationService.validateChoicesForm,
                ]);
            } else {
                choicesControl.clearValidators();
                choicesControl.clear();
            }
            choicesControl?.updateValueAndValidity();
        });

        // Function to set answer validators
        const updateAnswerValidators = () => {
            const minValue = questionForm.get('interval.min')?.value || 0;
            const maxValue = questionForm.get('interval.max')?.value || 0;

            questionForm.get('answer')?.setValidators([
                Validators.required,
                Validators.pattern("^[0-9]*$"),
                (control) => this.validationService.validateAnswerInRange(control, minValue, maxValue)
            ]);
            questionForm.get('answer')?.updateValueAndValidity();
        };

        questionForm.get('interval.min')?.valueChanges.subscribe(updateAnswerValidators);
        questionForm.get('interval.max')?.valueChanges.subscribe(updateAnswerValidators);

        // Function to set margin validators
        const updateMarginValidators = () => {
            questionForm.get('margin')?.setValidators([
                Validators.required,
                Validators.pattern("^[0-9]*$"),
                Validators.min(0),
                (control) => this.validationService.validateMarginWithinLimit(control)
            ]);
            questionForm.get('margin')?.updateValueAndValidity();
        };

        // Ensure that the margin validators are set correctly whenever the answer changes
        questionForm.get('answer')?.valueChanges.subscribe(updateMarginValidators);

        // Additional subscriptions to update interval validation
        questionForm.get('interval.min')?.valueChanges.subscribe(() => {
            questionForm.get('interval')?.setValidators(this.validationService.validateInterval);
            questionForm.get('interval')?.updateValueAndValidity();
        });
        questionForm.get('interval.max')?.valueChanges.subscribe(() => {
            questionForm.get('interval')?.setValidators(this.validationService.validateInterval);
            questionForm.get('interval')?.updateValueAndValidity();
        });
    }

}
