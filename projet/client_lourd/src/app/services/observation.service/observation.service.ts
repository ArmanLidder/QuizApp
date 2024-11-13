import {Injectable} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {
    HostInterfaceManagementService
} from "@app/services/host-interface-management.service/host-interface-management.service";
// import {TimerMessage} from "@common/browser-message/displayable-message/timer-message";
import {GameService} from "@app/services/game.service/game.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {NewObservedPlayer} from "@common/interfaces/socket-manager.interface";
import {
    GameInterfaceManagementService
} from "@app/services/game-interface-management.service/game-interface-management.service";
import {HOST_USERNAME} from "@common/names/host-username";
import {HostCurrentGameInterface, InitialQuestionData} from "@common/interfaces/host.interface";
import {ACTIVE, ACTIVE_STATUS, INACTIVE, INACTIVE_STATUS} from "@common/constants/host-interface.component.const";
import {EXACT_ANSWER, INCORRECT_ANSWER, WITHIN_MARGIN} from "@common/constants/statistic-zone.component.const";
// import {ObsQuestionData} from "@common/interfaces/host.interface";

@Injectable({
    providedIn: 'root'
})
export class ObservationService {
    isHost: boolean;
    observedPlayerId: string;
    gameConfigs: GameListItem;
    playersList: string[];
    qrlActivity: boolean = false;

    constructor(
        private socketService: SocketClientService,
        private gameService: GameService,
        private hostInterfaceManagementService: HostInterfaceManagementService,
        private gameInterfaceManagementService: GameInterfaceManagementService,
    ) {
    }

     observeGame(game: GameListItem) {
        this.gameConfigs = game;
        this.observedPlayerId = this.gameConfigs.hostUserId;
        this.gameService.observingHost = true;
        this.gameService.observedPlayerId = this.observedPlayerId;
        this.configureBaseSocketFeatures()
        this.socketService.send(SocketEvent.NEW_OBSERVER_GAME, game.room);
        this.isHost = true;
    }

     configureBaseSocketFeatures() {
        this.handleGetQRLInteraction();
        this.handleGetQRLAnswer();
        this.handleGetQREAnswer();
        this.handleObsGetInitialQuestion();
        this.gameInterfaceManagementService.configureBaseSocketFeatures();
        this.hostInterfaceManagementService.configureBaseSocketFeatures();
        this.handleGameStateReception();
         console.log("Congfig on Observation-Service");
     }

    observeOtherPlayer(oldUserId: string, newUserId: string) {
        const data: NewObservedPlayer = {
            roomId: this.gameConfigs.room,
            oldUserId,
            newUserId,
            isHost: this.isHost,
        }
        this.socketService.send(SocketEvent.CHANGE_OBSERVED_PLAYER, data);
        this.isHost = newUserId === this.gameConfigs.hostUserId;
        this.gameService.observingHost = this.isHost;
        this.gameService.observedPlayerId = newUserId;
        this.gameService.gameRealService.username = this.isHost ? HOST_USERNAME : newUserId;
        if (this.gameService.observerMode) this.gameService.qrlAnswer = "Le joueur est inactif ...";
    }

    private handleGetQRLInteraction() {
        this.socketService.on(SocketEvent.GET_QRL_INTERACTION, (isActive: boolean) => {
            this.gameService.qrlAnswer = isActive ? "Le joueur écrit une réponse ..." : "Le joueur est inactif ..."
        });
    }

    private handleGetQRLAnswer() {
        this.socketService.on(SocketEvent.GET_QRL_ANSWER_FOR_OBS, (answer: string) => {
            this.gameService.testQRLAnswer = answer;
        });
    }

    private handleGetQREAnswer() {
        this.socketService.on(SocketEvent.GET_QRE_ANSWER_FOR_OBS, (qreValue: number) => {
            this.gameService.qreAnswer = qreValue
        });
    }

    private handleObsGetInitialQuestion(){
        this.socketService.on(SocketEvent.GET_INITIAL_QUESTION, (data: InitialQuestionData) => {
            this.gameService.gameRealService.question = data.question;
            this.gameService.gameRealService.isLast = data.numberOfQuestions === data.index;
        });
    }

    private handleGameStateReception() {
        this.socketService.on(SocketEvent.RECEIVING_HOST_GAME_STATUS, (data: HostCurrentGameInterface) => {
            this.setUpGameState(data);
            const resetPlayerStatus = this.hostInterfaceManagementService.isGameOver
            console.log(this.hostInterfaceManagementService.leftPlayers)
            this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.gameService.gameRealService.roomId, this.hostInterfaceManagementService.leftPlayers, resetPlayerStatus)
        });
    }

    private setUpGameState(data: HostCurrentGameInterface) {
        this.hostInterfaceManagementService.timerText = data.timerText;
        this.hostInterfaceManagementService.isGameOver = data.isGameOver;
        this.hostInterfaceManagementService.isHostEvaluating = data.isHostEvaluating;
        this.hostInterfaceManagementService.isPanicMode = data.isPanicMode;
        this.hostInterfaceManagementService.isPaused = data.isPaused;
        this.hostInterfaceManagementService.leftPlayers = data.leftPlayers;
        this.hostInterfaceManagementService['interactiveListService'].players = data.players
        this.gameInterfaceManagementService.gameStats = [];
        this.gameInterfaceManagementService['unpackStats'](this.gameInterfaceManagementService['parseGameStats'](data.gameStats));
        this.hostInterfaceManagementService.gameStats = this.gameInterfaceManagementService.gameStats
        if (!data.isGameOver) {
            if (data.histogramDataChangingResponses.length === 2)
                this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
                    [ACTIVE, data.histogramDataChangingResponses[ACTIVE_STATUS]],
                    [INACTIVE, data.histogramDataChangingResponses[INACTIVE_STATUS]],
                ]);
            else if (data.histogramDataChangingResponses.length === 3)
                this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
                    [WITHIN_MARGIN, data.histogramDataChangingResponses[0]],
                    [EXACT_ANSWER, data.histogramDataChangingResponses[1]],
                    [INCORRECT_ANSWER, data.histogramDataChangingResponses[2]]
                ]);
            else
                this.hostInterfaceManagementService.histogramDataChangingResponses = this.hostInterfaceManagementService['createChoicesStatsMap'](data.histogramDataChangingResponses)
        }
    }

    reset() {
        this.hostInterfaceManagementService.reset();
        this.gameInterfaceManagementService.reset();
    }
}
