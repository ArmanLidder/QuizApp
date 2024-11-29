import {ApplicationRef, Injectable} from '@angular/core';
import {Router} from "@angular/router";
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {
    HostInterfaceManagementService
} from "@app/services/host-interface-management.service/host-interface-management.service";
import {GameService} from "@app/services/game.service/game.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {NewObservedPlayer} from "@common/interfaces/socket-manager.interface";
import {
    GameInterfaceManagementService
} from "@app/services/game-interface-management.service/game-interface-management.service";
import {HOST_USERNAME} from "@common/names/host-username";
import {
    HostCurrentGameInterface,
    InitialQuestionData,
    PlayerCurrentGameInterface
} from "@common/interfaces/host.interface";
import {
    ACTIVE,
    ACTIVE_STATUS,
    INACTIVE,
    INACTIVE_STATUS,
    TransportStatsFormat
} from "@common/constants/host-interface.component.const";
// import {EXACT_ANSWER, INCORRECT_ANSWER, WITHIN_MARGIN} from "@common/constants/statistic-zone.component.const";
import {TranslateService} from "@ngx-translate/core";
import {QuestionType} from "@common/enums/question-type.enum";
import {
    WaitingRoomManagementService
} from "@app/services/waiting-room-management.service/waiting-room-management.service";

@Injectable({
    providedIn: 'root'
})
export class ObservationService {
    isHost: boolean;
    observedPlayerId: string;
    gameConfigs: GameListItem;
    playersList: string[];
    firstCall: boolean;

    WITHIN_MARGIN = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.WITHIN_MARGIN');
    EXACT_ANSWER = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.EXACT_ANSWER');
    INCORRECT_ANSWER = this.translate.instant('GAME_INTERFACE.QRE_HISTOGRAM_X_VAL.INCORRECT_ANSWER');

    constructor(
        private socketService: SocketClientService,
        private gameService: GameService,
        private waitingRoom: WaitingRoomManagementService,
        private hostInterfaceManagementService: HostInterfaceManagementService,
        private gameInterfaceManagementService: GameInterfaceManagementService,
        private router: Router,
        private translate: TranslateService,
        private appRef: ApplicationRef,
    ) {
    }

    observeGame(game: GameListItem, firstCall: boolean) {
        this.firstCall = firstCall;
        this.gameConfigs = game;
        this.waitingRoom.gameType = game.gameType as "classic" | "equipe"
        this.observedPlayerId = this.gameConfigs.hostUserId;
        this.gameService.observingHost = true;
        this.gameService.observedPlayerId = this.observedPlayerId;
        // this.configureBaseSocketFeatures();
        this.socketService.send(SocketEvent.NEW_OBSERVER_GAME, {roomId: game.room, isFirst: firstCall});
        this.isHost = true
        console.log({
            gameConfigs: this.gameConfigs,
            observedPlayerId: this.observedPlayerId,
            isHost: this.isHost,
            gameService: {
                observeMode: this.gameService.observerMode,
                observingHost: this.gameService.observingHost,
                observedPlayerId: this.gameService.observedPlayerId
            },
            playersList: this.playersList,
            InteractiveList: this.hostInterfaceManagementService['interactiveListService'].players
        });
    }

    configureBaseSocketFeatures() {
        this.handleGameStateReception();
        this.handleGetQRLInteraction();
        this.handleGetQRLAnswer();
        this.handleGetQREAnswer();
        this.handleObsGetInitialQuestion();
        this.gameInterfaceManagementService.configureBaseSocketFeatures();
        this.hostInterfaceManagementService.configureBaseSocketFeatures();
        this.handleGameStatusDistribution()
        this.handlePlayerGameState();
        this.handleHostLeft();
        this.handleLastQRLAnswerReception();
    }

    observeOtherPlayer(oldUserId: string, newUserId: string) {
        const data: NewObservedPlayer = {
            roomId: this.gameConfigs.room,
            oldUserId,
            newUserId,
            isHost: this.isHost,
        }
        this.isHost = newUserId === this.gameConfigs.hostUserId;
        this.gameService.observingHost = this.isHost;
        this.gameService.observedPlayerId = newUserId;
        this.gameService.gameRealService.username = this.isHost ? HOST_USERNAME : newUserId;
        if (this.gameService.observerMode) {
            this.gameService.obs_qrl_Answer = this.translate.instant('OBSERVER.QRL_PLAYER_INACTIVE');
        }
        this.socketService.send(SocketEvent.CHANGE_OBSERVED_PLAYER, data);
        if (this.isHost) this.socketService.send(SocketEvent.NEW_OBSERVER_GAME, {
            roomId: this.gameConfigs.room,
            isFirst: false
        });
    }

    private handleHostLeft() {
        this.socketService.on(SocketEvent.REMOVED_FROM_GAME, () => {
            this.socketService.send(SocketEvent.OBS_LEFT, {
                roomId: this.gameConfigs.room,
                observedId: this.gameService.observedPlayerId
            })
            this.router.navigate(['/']);
        });
    }

    private handleGetQRLInteraction() {
        this.socketService.on(SocketEvent.GET_QRL_INTERACTION, (isActive: boolean) => {
            this.gameService.qrlAnswer = isActive ? this.translate.instant('OBSERVER.QRL_PLAYER_ACTIVE') : this.translate.instant('OBSERVER.QRL_PLAYER_INACTIVE');
        });
    }

    private handleGetQRLAnswer() {
        this.socketService.on(SocketEvent.GET_QRL_ANSWER_FOR_OBS, (answer: string) => {
            this.gameService.obs_qrl_Answer = answer;
        });
    }

    private handleGetQREAnswer() {
        this.socketService.on(SocketEvent.GET_QRE_ANSWER_FOR_OBS, (qreValue: number) => {
            this.gameService.obs_qre_Answer = qreValue
            const lowerBound = Math.max(this.gameService.question!.interval!.min!, this.gameService.obs_qre_Answer - this.gameService.question!.margin!);
            const upperBound = Math.min(this.gameService.question!.interval!.max!, this.gameService.obs_qre_Answer + this.gameService.question!.margin!);
            this.gameService.obs_qre_interval = `${lowerBound.toString()} - ${upperBound.toString()}`;
        });
    }

    private handleObsGetInitialQuestion() {
        this.socketService.on(SocketEvent.GET_INITIAL_QUESTION, (data: InitialQuestionData) => {
            this.gameService.gameRealService.question = data.question;
            this.gameService.gameRealService.isLast = data.numberOfQuestions === data.index;
        });
    }

    private handleGameStateReception() {
        this.socketService.on(SocketEvent.RECEIVING_HOST_GAME_STATUS,  async (data: HostCurrentGameInterface) => {
            console.log('receiving host game status', data)
            this.setUpGameState(data);
            const numberOfPlayer = await this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.gameService.gameRealService.roomId, this.hostInterfaceManagementService.leftPlayers, false)
            if ((!this.hostInterfaceManagementService.isGameOver && this.firstCall)) this.hostInterfaceManagementService['initGraph'](this.gameService.question!, numberOfPlayer);
        });
    }

    private handleGameStatusDistribution() {
        this.socketService.on(SocketEvent.GAME_STATUS_DISTRIBUTION, (gameStats: string) => {
            this.unpackStats(this.parseGameStats(gameStats));
        });
    }

    private parseGameStats(stringifyStats: string) {
        return JSON.parse(stringifyStats);
    }

    private unpackStats(stats: TransportStatsFormat) {
        this.hostInterfaceManagementService.gameStats = [];
        stats.forEach((stat) => {
            const values = new Map<string, boolean>(stat[0]);
            const responses = new Map<string, number>(stat[1]);
            this.hostInterfaceManagementService.gameStats.push([values, responses, stat[2]]);
        });
    }

    private handlePlayerGameState() {
        this.socketService.on(SocketEvent.RECEIVE_PLAYER_GAME_STATUS, (data: PlayerCurrentGameInterface) => {
            this.gameInterfaceManagementService.isBonus = data.isBonus;
            this.gameInterfaceManagementService.isGameOver = this.hostInterfaceManagementService.isGameOver;
            this.gameInterfaceManagementService.playerScore = data.playerScore;
            this.gameInterfaceManagementService.timerText = this.hostInterfaceManagementService.timerText;
            this.gameInterfaceManagementService.players = data.players;
            console.log("player OBs init event", data.players)
            this.gameInterfaceManagementService.inPanicMode = this.hostInterfaceManagementService.isPanicMode;
            this.gameService.obs_qre_Answer = data.qreAnswer;
            if (this.gameService.question?.type === QuestionType.QRE) {
                const lowerBound = Math.max(this.gameService.question!.interval!.min!, this.gameService.obs_qre_Answer - this.gameService.question!.margin!);
                const upperBound = Math.min(this.gameService.question!.interval!.max!, this.gameService.obs_qre_Answer + this.gameService.question!.margin!);
                this.gameService.obs_qre_interval = `${lowerBound.toString()} - ${upperBound.toString()}`;
            }
            this.gameService.obs_qrl_Answer = data.qrlAnswer;
            this.gameService.qrlAnswer = data.qrlAnswer;
            this.gameInterfaceManagementService['getScore']();
        });
    }

    private setUpGameState(data: HostCurrentGameInterface) {
        this.gameService.gameRealService.validated = data.isValidated;
        this.gameService.gameRealService.timer = data.currentTime;
        this.hostInterfaceManagementService.timerText = data.timerText;
        this.hostInterfaceManagementService.isGameOver = data.isGameOver;
        this.hostInterfaceManagementService.isHostEvaluating = data.isHostEvaluating;
        this.hostInterfaceManagementService.isPanicMode = data.isPanicMode;
        this.hostInterfaceManagementService.isPaused = data.isPaused;
        this.hostInterfaceManagementService.leftPlayers = data.leftPlayers;
        this.waitingRoom.teams = new Map(data.teams);
        this.hostInterfaceManagementService['interactiveListService'].players = Array.from(new Set(data.players));
        this.gameInterfaceManagementService.gameStats = [];
        this.gameInterfaceManagementService['unpackStats'](this.gameInterfaceManagementService['parseGameStats'](data.gameStats));
        this.hostInterfaceManagementService.gameStats = this.gameInterfaceManagementService.gameStats
        if (!data.isGameOver) {

            if (this.gameService.question?.type === QuestionType.QRL)
                this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
                    [ACTIVE, data.histogramDataChangingResponses[ACTIVE_STATUS]],
                    [INACTIVE, data.histogramDataChangingResponses[INACTIVE_STATUS]],
                ]);
            else if (this.gameService.question?.type === QuestionType.QRE) {
                this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
                    [this.WITHIN_MARGIN, data.histogramDataChangingResponses[0]],
                    [this.EXACT_ANSWER, data.histogramDataChangingResponses[1]],
                    [this.INCORRECT_ANSWER, data.histogramDataChangingResponses[2]]
                ]);
            }
            else
                this.hostInterfaceManagementService.histogramDataChangingResponses = this.hostInterfaceManagementService['createChoicesStatsMap'](data.histogramDataChangingResponses)
            console.log("hostInterfaceManagementService.histogramDataChangingResponses is now ", this.hostInterfaceManagementService.histogramDataChangingResponses)
        }
        this.appRef.tick();
    }

    private handleLastQRLAnswerReception() {
        this.socketService.on(SocketEvent.RECEIVE_LAST_QRL_INTERACTION, (data: {
            roomId: number;
            lastQRLScore: number | undefined;
            qrlAnswer: string | undefined,
            userId: string
        }) => {
            if (this.gameService.observedPlayerId === data.userId) {
                this.gameService.lastQrlScore = data.lastQRLScore;
                this.gameService.obs_qrl_Answer = data.qrlAnswer ?? "";
            }
        });
    }

    reset() {
        this.hostInterfaceManagementService.reset();
        this.gameInterfaceManagementService.reset();
    }
}
