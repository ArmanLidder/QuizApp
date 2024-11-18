import {Injectable, ApplicationRef} from '@angular/core';
import {
    ACTIVE,
    ACTIVE_STATUS,
    INACTIVE,
    INACTIVE_STATUS,
    PLAYER_NOT_FOUND_INDEX,
    RESPONSE,
    TransportStatsFormat,
    VALUE,
} from '@common/constants/host-interface.component.const';
import {Player} from '@common/constants/player-list.component.const';
import {GameService} from '@app/services/game.service/game.service';
import {
    InteractiveListSocketService
} from '@app/services/interactive-list-socket.service/interactive-list-socket.service';
import {SocketClientService} from '@app/services/socket-client.service/socket-client.service';
import {QuestionType} from '@common/enums/question-type.enum';
import {HostCurrentGameInterface, InitialQuestionData, NextQuestionData} from '@common/interfaces/host.interface';
import {QuizChoice, QuizQuestion} from '@common/interfaces/quiz.interface';
import {HOST_USERNAME} from '@common/names/host-username';
import {SocketEvent} from '@common/socket-event-name/socket-event-name';
import {
    QuestionStatistics,
} from '@common/constants/statistic-zone.component.const';
import {TranslateService} from "@ngx-translate/core";
import {GameConfigService} from "@app/services/game-config.service/game-config.service";
import {OpenaiService} from "@app/services/openai.service/openai.service";
import {QrlEvaluationService} from "@app/services/qrl-evaluation.service/qrl-evaluation.service";

@Injectable({
    providedIn: 'root',
})
export class HostInterfaceManagementService {
    timerText: string = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.TIME_LEFT');
    isGameOver: boolean = false;
    histogramDataChangingResponses = new Map<string, number>();
    histogramDataValue = new Map<string, boolean>();
    leftPlayers: Player[] = [];
    responsesQRL = new Map<string, { answers: string; time: number }>();
    isHostEvaluating: boolean = false;
    gameStats: QuestionStatistics[] = [];
    isPaused: boolean = false;
    isPanicMode: boolean = false;
    WITHIN_MARGIN = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.WITHIN_MARGIN');
    EXACT_ANSWER = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.EXACT_ANSWER');
    INCORRECT_ANSWER = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.INCORRECT_ANSWER');


    constructor(
        public gameService: GameService,
        private readonly socketService: SocketClientService,
        private interactiveListService: InteractiveListSocketService,
        private translate: TranslateService,
        private gameConfig: GameConfigService,
        private openIA: OpenaiService,
        private evaluationQRLService: QrlEvaluationService,
        private appRef: ApplicationRef,
    ) {}

    private get roomId() {
        return this.gameService.gameRealService.roomId;
    }

    sendPauseTimer() {
        this.isPaused = !this.isPaused;
        this.socketService.send(SocketEvent.PAUSE_TIMER, this.gameService.gameRealService.roomId);
    }

    startPanicMode() {
        this.socketService.send(SocketEvent.PANIC_MODE, {
            roomId: this.gameService.gameRealService.roomId,
            timer: this.gameService.gameRealService.timer,
        });
        this.isPanicMode = true;
    }

    saveStats() {
        const question = this.gameService.gameRealService.question;
        if (question !== null) {
            const savedStats: QuestionStatistics = [this.histogramDataValue, this.histogramDataChangingResponses, question];
            if (question.type !== QuestionType.QRL) this.gameStats.push(savedStats);
        }
    }

    requestNextQuestion() {
        this.isPanicMode = false;
        this.gameService.gameRealService.validated = false;
        this.gameService.gameRealService.locked = false;
        if (!this.gameService.observerMode) this.socketService.send(SocketEvent.START_TRANSITION, this.gameService.gameRealService.roomId);
    }

    handleLastQuestion() {
        this.sendGameStats();
        this.socketService.send(SocketEvent.SHOW_RESULT, this.gameService.gameRealService.roomId);
    }

    configureBaseSocketFeatures() {
        if (!this.gameService.observerMode) {
            this.reset();
            this.handleRequestHostGameStatus();
        }
        this.handleTimeTransition();
        this.handleEndQuestion();
        this.handleFinalTimeTransition();
        this.handleRefreshChoicesStats();
        this.handleGetInitialQuestion();
        this.handleGetNextQuestion();
        this.handleRemovedPlayer();
        this.handleEndQuestionAfterRemoval();
        this.handleEvaluationOver();
        this.handleRefreshActivityStats();
        this.handleHostPanicMode();
        this.handleHostTimerPause();
        this.handleRefreshQREStats();

    }

    private handleTimeTransition() {
        this.socketService.on(SocketEvent.TIME_TRANSITION, (timeValue: number) => {
            if (!this.gameService.observerMode) {
                this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.NEXT');
                this.gameService.gameRealService.timer = timeValue;
                if (this.gameService.timer === 0) {
                    this.gameService.gameRealService.inTimeTransition = false;
                    this.resetInterface();
                    this.socketService.send(SocketEvent.NEXT_QUESTION, this.gameService.gameRealService.roomId);
                    this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.TIME_LEFT');
                }
            } else {
                this.obsHandleTimeTransition(timeValue);
            }
        });
    }

    private obsHandleTimeTransition(timeValue: number){
        this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.NEXT');
        if (this.gameService.observingHost) this.gameService.gameRealService.timer = timeValue;
        if (this.gameService.timer === 0) {
            if (this.gameService.observingHost) {
                this.gameService.gameRealService.inTimeTransition = false;
                this.resetInterface();
            }
            this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.TIME_LEFT');
        }
    }

    private handleEndQuestion() {
        this.socketService.on(SocketEvent.END_QUESTION, () => {
            if (!this.gameService.observerMode) {
                this.gameService.audio.pause();
                this.gameService.audio.currentTime = 0;
                this.gameService.gameRealService.audioPaused = false;
                this.gameService.gameRealService.inTimeTransition = true;
                this.resetInterface();
                if (this.gameService.question?.type === QuestionType.QCM || this.gameService.question?.type === QuestionType.QRE) {
                    this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers, false);
                } else {
                    this.sendQrlAnswer();
                    this.isHostEvaluating = true;
                }
            } else {
                this.obsHandleEndQuestion();
            }
        });
    }

    private obsHandleEndQuestion() {
        if (this.gameService.observingHost) {
            this.gameService.audio.pause();
            this.gameService.audio.currentTime = 0;
            this.gameService.gameRealService.audioPaused = false;
            this.gameService.gameRealService.inTimeTransition = true;
            this.resetInterface();
        }
        if (this.gameService.question?.type === QuestionType.QCM || this.gameService.question?.type === QuestionType.QRE) {
            if (this.gameService.observingHost) {
                this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers, false);
            }
        } else {
            this.isHostEvaluating = true;
        }
    }

    private handleFinalTimeTransition() {
        this.socketService.on(SocketEvent.FINAL_TIME_TRANSITION, (timeValue: number) => {
            if (!this.gameService.observerMode) {
                this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.RESULT_AVAILABLE_IN');
                this.gameService.gameRealService.timer = timeValue;
                if (this.gameService.timer === 0 && this.gameService.username === HOST_USERNAME) {
                    this.isGameOver = true;
                    this.interactiveListService.isFinal = true;
                    this.gameService.audio.pause();
                    this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers);
                    this.socketService.send(SocketEvent.SAVE_FINAL_GAME_STATS, this.gameService.gameRealService.roomId);
                }
            } else {
                this.obsHandleFinalTimeTransition(timeValue);
            }
        });
    }

    private obsHandleFinalTimeTransition(timeValue: number){
        this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.RESULT_AVAILABLE_IN');
        if (this.gameService.observingHost) this.gameService.gameRealService.timer = timeValue;
        if (this.gameService.timer === 0) {
            this.isGameOver = true;
            this.interactiveListService.isFinal = true;
            this.gameService.audio.pause();
            this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers);
        }
    }

    private handleRefreshChoicesStats() {
        this.socketService.on(SocketEvent.REFRESH_CHOICES_STATS, (choicesStatsValue: number[]) => {
            this.histogramDataChangingResponses = this.createChoicesStatsMap(choicesStatsValue);
        });
    }

    private handleRefreshQREStats() {
        this.socketService.on(SocketEvent.REFRESH_QRE_STATS, (qreStatsValue: number[]) => {
            this.histogramDataChangingResponses = new Map([
                [this.WITHIN_MARGIN, qreStatsValue[0]],
                [this.EXACT_ANSWER, qreStatsValue[1]],
                [this.INCORRECT_ANSWER, qreStatsValue[2]]
            ]);
        });
    }

    private handleGetInitialQuestion() {
        this.socketService.on(SocketEvent.GET_INITIAL_QUESTION, async (data: InitialQuestionData) => {
            const numberOfPlayers = await this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers);
            this.initGraph(data.question, numberOfPlayers);
        });
    }

    private handleGetNextQuestion() {
        this.socketService.on(SocketEvent.GET_NEXT_QUESTION, async (data: NextQuestionData) => {
            const numberOfPlayers = await this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers);
            this.initGraph(data.question, numberOfPlayers);
        });
    }

    private handleRemovedPlayer() {
        this.socketService.on(SocketEvent.REMOVED_PLAYER, (username) => {
            const playerIndex = this.interactiveListService.players.findIndex((player: Player) => player[0] === username);
            if (playerIndex !== PLAYER_NOT_FOUND_INDEX) {
                this.leftPlayers.push(this.interactiveListService.players[playerIndex]);
                this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers, false);
            }
        });
    }

    private handleEndQuestionAfterRemoval() {
        this.socketService.on(SocketEvent.END_QUESTION_AFTER_REMOVAL, () => {
            if (!this.gameService.observerMode) this.resetInterface();
            else if(this.gameService.observingHost) this.resetInterface();
        });
    }

    private handleHostPanicMode() {
        this.socketService.on(SocketEvent.PANIC_MODE, () => {
            if (!this.gameService.observerMode) {
                if (this.gameService.timer > 0 && !this.gameService.gameRealService.audioPaused) {
                    this.gameService.audio.play();
                }
            } else if (this.gameService.observingHost) {
                if (this.gameService.timer > 0 && !this.gameService.gameRealService.audioPaused) {
                    this.gameService.audio.play();
                }
            }
            this.isPanicMode = true;
        });
    }

    private handleHostTimerPause() {
        this.socketService.on(SocketEvent.PAUSE_TIMER, () => {
            if (!this.gameService.observerMode) {
                if (this.gameService.gameRealService.audioPaused && this.isPanicMode) {
                    this.gameService.audio.play();
                } else if (!this.gameService.gameRealService.audioPaused && this.isPanicMode) {
                    this.gameService.audio.pause();
                }
                this.gameService.gameRealService.audioPaused = !this.gameService.gameRealService.audioPaused;
            } else if (!this.gameService.observingHost) {
                if (this.gameService.gameRealService.audioPaused && this.isPanicMode) {
                    this.gameService.audio.play();
                } else if (!this.gameService.gameRealService.audioPaused && this.isPanicMode) {
                    this.gameService.audio.pause();
                }
                this.gameService.gameRealService.audioPaused = !this.gameService.gameRealService.audioPaused;
            }
        });
    }

    private handleEvaluationOver() {
        this.socketService.on(SocketEvent.EVALUATION_OVER, () => {
            this.interactiveListService.getPlayersList(this.roomId, this.leftPlayers, false);
        });
    }

    private handleRefreshActivityStats() {
        this.socketService.on(SocketEvent.REFRESH_ACTIVITY_STATS, (activityStatsValue: [number, number]) => {
            this.histogramDataChangingResponses = new Map([
                [ACTIVE, activityStatsValue[ACTIVE_STATUS]],
                [INACTIVE, activityStatsValue[INACTIVE_STATUS]],
            ]);
        });
    }

    private handleRequestHostGameStatus() {
        this.socketService.on(SocketEvent.REQUEST_HOST_GAME_STATUS, () => {
            let histogramDataChangingResponses: [number, number] | number[];
            if (this.gameService.gameRealService.question?.type === QuestionType.QRE)
                histogramDataChangingResponses = [
                    Number(this.histogramDataChangingResponses.get(this.WITHIN_MARGIN)),
                    Number(this.histogramDataChangingResponses.get(this.EXACT_ANSWER)),
                    Number(this.histogramDataChangingResponses.get(this.INCORRECT_ANSWER)),
                ]
            else histogramDataChangingResponses = [
                Number(this.histogramDataChangingResponses.get(ACTIVE)),
                Number(this.histogramDataChangingResponses.get(INACTIVE))
            ]
            const gameStatus: HostCurrentGameInterface = {
                roomId: this.roomId,
                timerText: this.timerText,
                currentTime: this.gameService.gameRealService.timer,
                isGameOver: this.isGameOver,
                leftPlayers: this.leftPlayers,
                players: this.interactiveListService.players,
                histogramDataChangingResponses: this.gameService.gameRealService.question?.type === QuestionType.QCM ? [1000] : histogramDataChangingResponses,
                isHostEvaluating: this.isHostEvaluating,
                gameStats: this.stringifyStats(),
                isPaused: this.isPaused,
                isPanicMode: this.isPanicMode,
                isValidated: this.gameService.gameRealService.validated
            }
            this.socketService.send(SocketEvent.SENDING_HOST_GAME_STATUS, gameStatus);
        });
    }

    private resetInterface() {
        this.gameService.gameRealService.validated = true;
        this.gameService.gameRealService.locked = true;
    }

    private initGraph(question: QuizQuestion, numberOfPlayers?: number) {
        this.isHostEvaluating = false;
        this.histogramDataValue = new Map();
        this.histogramDataChangingResponses = new Map();
        if (this.gameService.question?.type === QuestionType.QCM) {
            question.choices?.forEach((choice: QuizChoice) => {
                this.histogramDataValue.set(choice.text, choice.isCorrect as boolean);
            });
        } else if (this.gameService.question?.type === QuestionType.QRE) {
            this.histogramDataValue.set(this.WITHIN_MARGIN, true);
            this.histogramDataValue.set(this.EXACT_ANSWER, true);
            this.histogramDataValue.set(this.INCORRECT_ANSWER, false);
        } else {
            this.histogramDataChangingResponses = new Map([
                [ACTIVE, 0],
                [INACTIVE, numberOfPlayers as number],
            ]);
            this.histogramDataValue = new Map([
                [ACTIVE, true],
                [INACTIVE, false],
            ]);
        }
    }

    private createChoicesStatsMap(choicesStatsValue: number[]) {
        const choicesStats = new Map();
        const choices = this.gameService.question?.choices;
        choices?.forEach((choice: QuizChoice, index: number) => choicesStats.set(choice.text, choicesStatsValue[index]));
        return choicesStats;
    }

    private sendQrlAnswer() {
        this.socketService.send(SocketEvent.GET_PLAYER_ANSWERS, this.gameService.gameRealService.roomId, (playerAnswers: string) => {
            this.responsesQRL = new Map(JSON.parse(playerAnswers));
            if (this.gameConfig.IA) {
                if(this.openIA) this.openIA.init();
                for (const [key, value] of this.responsesQRL.entries()) {
                    this.openIA.
                    correctAnswer(value.answers, this.gameService.question?.text ?? "", this.translate.currentLang).
                    then((response) => {
                        const res = response?.choices[0].message?.content ?? "No Answer";
                        const score = this.extractScoreFromIAQRL(res);
                        this.evaluationQRLService.correctedQrlByOpenAi.set(key, [score, response?.choices[0].message?.content ?? "No Answer"])
                        this.appRef.tick();
                    });
                }
                this.appRef.tick();
            }

        });
    }

    private sendGameStats() {
        const gameStats = this.stringifyStats();
        this.socketService.send(SocketEvent.GAME_STATUS_DISTRIBUTION, {
            roomId: this.gameService.gameRealService.roomId,
            stats: gameStats
        });
    }

    private stringifyStats() {
        const stats = this.prepareStatsTransport();
        return JSON.stringify(stats);
    }

    private prepareStatsTransport() {
        const data: TransportStatsFormat = [];
        this.gameStats.forEach((stats) => {
            const values = Array.from(stats[VALUE]);
            const responses = Array.from(stats[RESPONSE]);
            data.push([values, responses, stats[2] as QuizQuestion]);
        });
        return data;
    }

    private extractScoreFromIAQRL(qrl_text: string) {
        const patternAa = /Aa/;
        const patternBb = /Bb/;
        const patternCc = /Cc/;
        if (patternCc.test(qrl_text)) return 100;
        else if (patternBb.test(qrl_text)) return 50;
        else if (patternAa.test(qrl_text)) return 0;
        return 0;
    }

    reset() {
        this.timerText = this.translate.instant('GAME_INTERFACE.TIMER_TEXT.TIME_LEFT');
        this.isGameOver = false;
        this.histogramDataChangingResponses = new Map<string, number>();
        this.histogramDataValue = new Map<string, boolean>();
        this.leftPlayers = [];
        this.responsesQRL = new Map<string, { answers: string; time: number }>();
        this.isHostEvaluating = false;
        this.gameStats = [];
        this.isPaused = false;
        this.isPanicMode = false;
    }
}
