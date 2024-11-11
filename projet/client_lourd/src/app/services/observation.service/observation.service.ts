import { Injectable } from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {
  HostInterfaceManagementService
} from "@app/services/host-interface-management.service/host-interface-management.service";
import {TimerMessage} from "@common/browser-message/displayable-message/timer-message";
import {QuestionType} from "@common/enums/question-type.enum";
import {InitialQuestionData, NextQuestionData} from "@common/interfaces/host.interface";
import {Player} from "@common/constants/player-list.component.const";
import {
  ACTIVE,
  ACTIVE_STATUS,
  INACTIVE, INACTIVE_STATUS,
  PLAYER_NOT_FOUND_INDEX, TransportStatsFormat,
} from "@common/constants/host-interface.component.const";
import {QuizChoice, QuizQuestion} from "@common/interfaces/quiz.interface";
import {GameService} from "@app/services/game.service/game.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {NewObservedPlayer} from "@common/interfaces/socket-manager.interface";

@Injectable({
  providedIn: 'root'
})
export class ObservationService {
  isHost: boolean;
  observedPlayerId: string;
  gameConfigs: GameListItem;
  playersList: string[];

  constructor(
      private socketService: SocketClientService,
      private gameService: GameService,
      private hostInterfaceManagementService: HostInterfaceManagementService,
  ) {}

  observeGame(game: GameListItem) {
    this.gameConfigs = game;
    this.observedPlayerId = this.gameConfigs.hostUserId;
    this.socketService.send(SocketEvent.NEW_OBSERVER_GAME, game.room);
    this.isHost = true;
  }

  configureBaseSocketFeatures(){
    this.reset();
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
    this.handleGameStatusDistribution();
    this.handleGetQREAnswer();
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
  }

  private handleGetQREAnswer() {
    this.socketService.on(SocketEvent.GET_QRE_ANSWER_FOR_OBS, (qreValue: number) => {
      this.gameService.qreAnswer = qreValue
    });
  }

  private handleTimeTransition() {
    this.socketService.on(SocketEvent.TIME_TRANSITION, (timeValue: number) => {
      this.hostInterfaceManagementService.timerText = TimerMessage.NEXT;
      this.gameService.gameRealService.timer = timeValue;
      if (this.gameService.timer === 0) {
        this.gameService.gameRealService.inTimeTransition = false;
        this.resetInterface();
        this.hostInterfaceManagementService.timerText = TimerMessage.TIME_LEFT;
      }
    });
  }

  private handleEndQuestion() {
    this.socketService.on(SocketEvent.END_QUESTION, () => {
      this.gameService.audio.pause();
      this.gameService.audio.currentTime = 0;
      this.gameService.gameRealService.audioPaused = false;
      this.gameService.gameRealService.inTimeTransition = true;
      this.resetInterface();
      if (!(this.gameService.question?.type === QuestionType.QCM || this.gameService.question?.type === QuestionType.QRE))
        this.hostInterfaceManagementService.isHostEvaluating = true;
    });
  }

  private handleFinalTimeTransition() {
    this.socketService.on(SocketEvent.FINAL_TIME_TRANSITION, (timeValue: number) => {
      this.hostInterfaceManagementService.timerText = TimerMessage.RESULT_AVAILABLE_IN;
      this.gameService.gameRealService.timer = timeValue;
      if (this.gameService.timer === 0) {
        this.hostInterfaceManagementService.isGameOver = true;
        this.gameService.audio.pause();
      }
    });
  }

  private handleRefreshChoicesStats() {
    this.socketService.on(SocketEvent.REFRESH_CHOICES_STATS, (choicesStatsValue: number[]) => {
      this.hostInterfaceManagementService.histogramDataChangingResponses = this.createChoicesStatsMap(choicesStatsValue);
    });
  }

  private handleGetInitialQuestion() {
    this.socketService.on(SocketEvent.GET_INITIAL_QUESTION, async (data: InitialQuestionData) => {
      const numberOfPlayers = await this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.hostInterfaceManagementService['roomId'], this.hostInterfaceManagementService.leftPlayers);
      this.initGraph(data.question, numberOfPlayers);
    });
  }

  private handleGetNextQuestion() {
    this.socketService.on(SocketEvent.GET_NEXT_QUESTION, async (data: NextQuestionData) => {
      const numberOfPlayers = await this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.hostInterfaceManagementService['roomId'], this.hostInterfaceManagementService.leftPlayers);
      this.initGraph(data.question, numberOfPlayers);
    });
  }

  private handleRemovedPlayer() {
    this.socketService.on(SocketEvent.REMOVED_PLAYER, (username) => {
      const playerIndex = this.hostInterfaceManagementService['interactiveListService'].players.findIndex((player: Player) => player[0] === username);
      if (playerIndex !== PLAYER_NOT_FOUND_INDEX) {
        this.hostInterfaceManagementService.leftPlayers.push(this.hostInterfaceManagementService['interactiveListService'].players[playerIndex]);
        this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.hostInterfaceManagementService['roomId'], this.hostInterfaceManagementService.leftPlayers, false);
      }
    });
  }

  private handleEndQuestionAfterRemoval() {
    this.socketService.on(SocketEvent.END_QUESTION_AFTER_REMOVAL, () => {
      this.resetInterface();
    });
  }

  private handleHostPanicMode() {
    this.socketService.on(SocketEvent.PANIC_MODE, () => {
      if (this.gameService.timer > 0 && !this.gameService.gameRealService.audioPaused) {
        this.gameService.audio.play();
      }
      this.hostInterfaceManagementService.isPanicMode = true;
    });
  }

  private handleHostTimerPause() {
    this.socketService.on(SocketEvent.PAUSE_TIMER, () => {
      if (this.gameService.gameRealService.audioPaused && this.hostInterfaceManagementService.isPanicMode) {
        this.gameService.audio.play();
      } else if (!this.gameService.gameRealService.audioPaused && this.hostInterfaceManagementService.isPanicMode) {
        this.gameService.audio.pause();
      }
      this.gameService.gameRealService.audioPaused = !this.gameService.gameRealService.audioPaused;
    });
  }

  private handleEvaluationOver() {
    this.socketService.on(SocketEvent.EVALUATION_OVER, () => {
      this.hostInterfaceManagementService['interactiveListService'].getPlayersList(this.hostInterfaceManagementService['roomId'], this.hostInterfaceManagementService.leftPlayers, false);
    });
  }

  private handleRefreshActivityStats() {
    this.socketService.on(SocketEvent.REFRESH_ACTIVITY_STATS, (activityStatsValue: [number, number]) => {
      this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
        [ACTIVE, activityStatsValue[ACTIVE_STATUS]],
        [INACTIVE, activityStatsValue[INACTIVE_STATUS]],
      ]);
    });
  }

  private resetInterface() {
    this.gameService.gameRealService.validated = true;
    this.gameService.gameRealService.locked = true;
  }

  private initGraph(question: QuizQuestion, numberOfPlayers?: number) {
    this.hostInterfaceManagementService.isHostEvaluating = false;
    this.hostInterfaceManagementService.histogramDataValue = new Map();
    this.hostInterfaceManagementService.histogramDataChangingResponses = new Map();
    if (this.gameService.question?.type === QuestionType.QCM) {
      question.choices?.forEach((choice: QuizChoice) => {
        this.hostInterfaceManagementService.histogramDataValue.set(choice.text, choice.isCorrect as boolean);
      });
    } else {
      this.hostInterfaceManagementService.histogramDataChangingResponses = new Map([
        [ACTIVE, 0],
        [INACTIVE, numberOfPlayers as number],
      ]);
      this.hostInterfaceManagementService.histogramDataValue = new Map([
        [ACTIVE, true],
        [INACTIVE, false],
      ]);
    }
  }

  private createChoicesStatsMap(choicesStatsValue: number[]) {
    const choicesStats = new Map();
    const choices = this.gameService.question?.choices;
    choices?.forEach((choice: QuizChoice, index: number) => choicesStats.set(choice.text, choicesStatsValue[index]));
    console.log(choicesStats);
    return choicesStats;
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
    stats.forEach((stat) => {
      const values = new Map<string, boolean>(stat[0]);
      const responses = new Map<string, number>(stat[1]);
      this.hostInterfaceManagementService.gameStats.push([values, responses, stat[2]]);
    });
  }

   reset() {
    this.hostInterfaceManagementService.timerText = TimerMessage.TIME_LEFT;
    this.hostInterfaceManagementService.isGameOver = false;
    this.hostInterfaceManagementService.histogramDataChangingResponses = new Map<string, number>();
    this.hostInterfaceManagementService.histogramDataValue = new Map<string, boolean>();
    this.hostInterfaceManagementService.leftPlayers = [];
    this.hostInterfaceManagementService.responsesQRL = new Map<string, { answers: string; time: number }>();
    this.hostInterfaceManagementService.isHostEvaluating = false;
    this.hostInterfaceManagementService.gameStats = [];
    this.hostInterfaceManagementService.isPaused = false;
    this.hostInterfaceManagementService.isPanicMode = false;
    this.playersList = [];
  }
}
