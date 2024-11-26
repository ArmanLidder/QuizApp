import {Injectable} from '@angular/core';
import {QCM_PANIC_MODE_ENABLED, QLR_PANIC_MODE_ENABLED} from '@common/constants/host-interface.component.const';
import {GameRealService} from '@app/services/game-real.service/game-real.service';
import {GameTestService} from '@app/services/game-test.service/game-test.service';
import {SocketClientService} from '@app/services/socket-client.service/socket-client.service';
import {SocketEvent} from '@common/socket-event-name/socket-event-name';
import {HOST_USERNAME} from '@common/names/host-username';
import {QuestionType} from "@common/enums/question-type.enum";
import {Auth} from "@angular/fire/auth";
import {NextQuestionData} from "@common/interfaces/host.interface";
import {TranslateService} from "@ngx-translate/core";
// import {Score} from "@common/interfaces/score.interface";
// import {QuestionStatistics} from "@common/constants/statistic-zone.component.const";

@Injectable({
    providedIn: 'root',
})
export class GameService {
    ///////////////////////////////////
    observerMode: boolean = false;
    observingHost: boolean = true;
    observedPlayerId: string;
    ///////////////////////////////////
    isTestMode: boolean = false;
    isInputFocused: boolean = false;
    answers: Map<number, string | null> = new Map();
    qrlAnswer: string = '';
    isHostEvaluating: boolean = false;
    isActive: boolean = false;
    hasInteracted: boolean = false;
    lastQrlScore: number | undefined = undefined;
    qreAnswer: number;

    // observationValues

    // For player QCM, QRL and QRE answers
    obs_qre_Answer: number;
    obs_qre_interval: string;
    obs_qrl_Answer: string;

    constructor(
        public gameTestService: GameTestService,
        public gameRealService: GameRealService,
        private socketService: SocketClientService,
        private auth: Auth,
        private translate: TranslateService,
    ) {}

    get timer() {
        return this.isTestMode ? this.gameTestService.timer?.time : this.gameRealService.timer;
    }

    get playerScore() {
        return this.gameTestService.playerScore;
    }

    get isBonus() {
        return this.gameTestService.isBonus;
    }

    get question() {
        return this.isTestMode ? this.gameTestService.question : this.gameRealService.question;
    }

    get questionNumber() {
        return this.isTestMode ? this.gameTestService.currQuestionIndex + 1 : this.gameRealService.questionNumber;
    }

    get username() {
        return this.gameRealService.username;
    }

    get lockedStatus() {
        return this.isTestMode ? this.gameTestService.locked : this.gameRealService.locked;
    }

    get validatedStatus() {
        return this.isTestMode ? this.gameTestService.validated : this.gameRealService.validated;
    }

    get audio() {
        return this.gameRealService.audio;
    }

    destroy() {
        this.reset();
        this.answers.clear();
    }

    init(pathId: string, isObserver?: boolean) {
        if (isObserver) this.observerMode = true;
        if (!this.isTestMode) {
            this.configureBaseSockets();
            this.handleGetNextQuestion();
            this.gameRealService.roomId = Number(pathId);
            this.gameRealService.init(isObserver);
        } else {
            this.gameTestService.quizId = pathId;
            this.gameTestService.init();
        }
    }

    selectChoice(index: number) {
        if (!this.lockedStatus) {
            if (this.answers.has(index)) {
                this.answers.delete(index);
                this.gameRealService.sendSelection(index, false);
            } else {
                const textChoice = this.question?.choices ? this.question.choices[index].text : null;
                this.answers.set(index, textChoice);
                this.gameRealService.sendSelection(index, true);
            }
        }
    }

    selectQREAnswer(selectedAnswer: number) {
        if (!this.lockedStatus) {
            this.qreAnswer = selectedAnswer;
            this.gameRealService.qreAnswer = selectedAnswer;
            if (!this.observerMode) this.gameRealService.sendQRESelection(selectedAnswer);
        }
    }

    sendAnswer() {
        if (!this.isTestMode) {
            this.gameRealService.answers = this.answers;
            this.gameRealService.qrlAnswer = this.qrlAnswer;
            this.gameRealService.qreAnswer = this.qreAnswer;
            this.gameRealService.sendAnswer();
            this.isActive = false;
            this.hasInteracted = false;
        } else {
            this.gameTestService.answers = this.answers;
            this.gameTestService.qrlAnswer = this.qrlAnswer;
            this.qrlAnswer = '';
            this.gameTestService.sendAnswer();
        }
        this.lastQrlScore = undefined;
        if (!this.observerMode) {
            this.socketService.send(SocketEvent.GET_LAST_QRL_STATUS, {
                roomId: this.gameRealService.roomId,
                lastQRLScore: this.lastQrlScore,
                qrlAnswer: this.qrlAnswer,
                userId: this.auth.currentUser?.uid,
            })
        }
        this.answers.clear();
    }

    isPanicDisabled() {
        if (this.question?.type == QuestionType.QRL) {
            return this.timer <= QLR_PANIC_MODE_ENABLED || this.gameRealService.inTimeTransition;
        } else {
            return this.timer <= QCM_PANIC_MODE_ENABLED || this.gameRealService.inTimeTransition;
        }
    }

    reset() {
        this.observerMode = false;
        this.isTestMode = false;
        this.qrlAnswer = '';
        this.isActive = false;
        this.hasInteracted = false;
        this.audio.pause();
        this.audio.currentTime = 0;
        this.gameRealService.destroy();
        this.gameTestService.reset();
    }

    private configureBaseSockets() {
        this.socketService.on(SocketEvent.TIME, (timeValue: number) => {
            this.handleTimeEvent(timeValue);
        });
    }

    private handleTimeEvent(timeValue: number) {
        this.gameRealService.timer = timeValue;
        if (this.timer === 0 && !this.gameRealService.locked) {
            if (this.question?.type === QuestionType.QRE && this.username !== HOST_USERNAME) this.selectQREAnswer(this.qreAnswer);
            this.gameRealService.locked = true;
            if (this.username !== HOST_USERNAME && !this.observerMode) this.sendAnswer();
        }
    }

    private handleGetNextQuestion() {
        if (this.socketService.isSocketAlive()) {
            this.socketService.on(SocketEvent.GET_NEXT_QUESTION, (data: NextQuestionData) => {
                if (!this.observerMode) {
                    this.qrlAnswer = "";
                    this.gameRealService.qrlAnswer = "";
                }
                if (this.observerMode) this.qrlAnswer = this.translate.instant('OBSERVER.QRL_PLAYER_INACTIVE');
            });
        }
    }
}
