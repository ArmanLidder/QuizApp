import { QuizQuestion } from './quiz.interface';
import {Player} from "../constants/player-list.component.const";

export interface InitialQuestionData {
    question: QuizQuestion;
    username: string;
    index: number;
    numberOfQuestions: number;
}

export interface NextQuestionData {
    question: QuizQuestion;
    index: number;
    isLast: boolean;
}

export interface ObsQuestionData {
    question: QuizQuestion;
    username: string;
    index: number;
    numberOfQuestions: number;
    isLast: boolean;
    gameActivityStatus: [number, number];
}


export interface HostCurrentGameInterface {
    roomId: number;
    timerText: string;
    isGameOver: boolean;
    leftPlayers: Player[];
    players: Player[];
    histogramDataChangingResponses: [number, number] | number[];
    isHostEvaluating: boolean;
    gameStats: string;
    isPaused: boolean;
    isPanicMode: boolean;
}
