import { QuestionType } from '../enums/question-type.enum';

export interface Quiz {
    id: string;
    title: string;
    description: string;
    duration: number;
    lastModification: string | null;
    questions: QuizQuestion[];
    visible?: boolean;
    owner?: string; //firebase uid string
}

export interface QuizQuestion {
    type: QuestionType;
    text: string;
    points: number;
    choices?: QuizChoice[]; //Only QCM
    answer? : number, //Only QRE
    interval? : {max:number, min:number} //Only QRE
    margin?: number //Only QRE
    imageUrl?: string;
}

export interface QuizChoice {
    text: string;
    isCorrect?: boolean | null;
}
