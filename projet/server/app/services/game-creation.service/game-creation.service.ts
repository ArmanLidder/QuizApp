import {RoomManagingService} from '@app/services/room-managing.service/room-managing.service';
import {TRANSITION_QUESTIONS_DELAY} from '@common/constants/socket-manager.service.const';
import {TimerService} from '@app/services/timer.service/timer.service';
import {ErrorDictionary} from '@common/browser-message/error-message/error-message';
import {
    JoinTeamData,
    NewObservedPlayer,
    PlayerSelection,
    PlayerUsername
} from '@common/interfaces/socket-manager.interface';
import {HOST_USERNAME} from '@common/names/host-username';
import {SocketEvent} from '@common/socket-event-name/socket-event-name';
import * as io from 'socket.io';
import {Service} from 'typedi';
import {FirebaseService} from "@app/services/firebase.service/firebase.service";
import {Canal} from "@common/interfaces/message.interface";
import {GameConfig} from "@common/interfaces/game-info.interface";
import {Score} from "@common/interfaces/score.interface";
import {Game} from "@app/classes/game/game";
import {GameHistory, User, UserStats} from "@common/interfaces/user-data.interface";
// import {HostCurrentGameInterface} from "@common/interfaces/host.interface";
import {HostCurrentGameInterface, PlayerCurrentGameInterface} from "@common/interfaces/host.interface";
import {QuestionType} from "@common/enums/question-type.enum";

// import {InitialQuestionData, ObsQuestionData} from "@common/interfaces/host.interface";

@Service()
export class GameCreationService {
    private timerService: TimerService;
    private fs: FirebaseService;

    constructor(fs: FirebaseService) {
        this.fs = fs;
    }

    configureGameCreationSockets(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        this.timerService = new TimerService(roomManager, sio);
        this.handleRoomCreation(roomManager, socket, sio);
        this.handleJoinGame(roomManager, socket, sio);
        this.handleBanPlayer(roomManager, socket, sio);
        this.handleToggleRoomLock(roomManager, socket);
        this.handleValidateUsername(roomManager, socket);
        this.handleGatherPlayersUsername(roomManager, socket, sio);
        this.handleValidateRoomId(roomManager, socket);
        this.handlePlayerLeft(roomManager, socket, sio);
        this.handleHostLeft(roomManager, socket, sio);
        this.handleGetGameList(roomManager, socket, sio);
        this.handleSaveStats(roomManager, socket);
        this.handleJoinTeam(roomManager, socket, sio);
        this.handleCreateTeam(roomManager, socket, sio);
        this.handleGetGameType(roomManager, socket);
        this.handleNewObserver(roomManager, socket, sio);
        this.handleObserverGetPlayerList(roomManager, socket, sio);
        this.handleChangeObservedPLayer(roomManager, socket, sio);
        this.handleGameStatusForObsReception(roomManager, socket, sio);
        this.handleQCMAnswerReception(socket, sio);
        this.handleObsLastQRLAnswer(socket, sio);
        this.handleObsLeft(roomManager, socket, sio);
        this.handleGetObsCounter(roomManager, socket, sio);
    }

    private handleRoomCreation(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.CREATE_ROOM, async (data: { quizId: string, gameConfig: GameConfig }, callback) => {
            const userId = socket.handshake.auth.userId;
            const roomCode = roomManager.addRoom(data.quizId, data.gameConfig);
            await this.fs.firestore.collection('canals').add(this.generateRoomCanal(roomCode, userId))
            roomManager.addUser(roomCode, HOST_USERNAME, socket.id);
            socket.join(String(roomCode));
            this.sendUpdateGameList(roomManager, sio)
            callback(roomCode);
        });
    }

    private handleJoinGame(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.JOIN_GAME, async (data: PlayerUsername, callback) => {
            const isLocked = roomManager.isRoomLocked(data.roomId);
            if (!isLocked) {
                const roomCode = data.roomId;
                const userId = socket.handshake.auth.userId;
                // roomManager.addUser(roomCode, data.username, socket.id);
                roomManager.addUser(roomCode, userId, socket.id);
                const players = roomManager.getUsernamesArray(roomCode);
                socket.join(String(roomCode));
                await this.addUserToRoomCanal(roomCode, userId);
                sio.to(String(data.roomId)).emit(SocketEvent.NEW_PLAYER, players);
                this.sendUpdateGameList(roomManager, sio)
            }
            callback(isLocked);
        });
    }

    private handleNewObserver(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.NEW_OBSERVER_GAME, async (data: {roomId:number; isFirst: boolean}) => {
            const hostId = roomManager.getSocketIdByUsername(data.roomId, HOST_USERNAME);
            const observerId = socket.handshake.auth.userId;
            await this.addUserToRoomCanal(data.roomId, observerId);
            if (data.isFirst) {
                roomManager.updateObserverCounter(data.roomId, HOST_USERNAME, false);
                socket.join(String(data.roomId));
                socket.join(String(hostId));
                const count = roomManager.getRoomById(data.roomId).observersCounter.get(HOST_USERNAME)
                if (count >= 0) {
                    console.log("sending NEW_OBSERVER_GAME");
                    sio.to(hostId).emit(SocketEvent.UPDATE_OBS_COUNT, count);
                }
            }
            sio.to(String(hostId)).emit(SocketEvent.REQUEST_HOST_GAME_STATUS);
        });
    }

    private handleGameStatusForObsReception(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.SENDING_HOST_GAME_STATUS, (data: HostCurrentGameInterface) => {
            if (data.histogramDataChangingResponses[0] === 1000) { // To tell me it is QCM
                const game = roomManager.getGameByRoomId(data.roomId)
                data.histogramDataChangingResponses = Array.from(game.choicesStats.values());
            }
            sio.emit(SocketEvent.RECEIVING_HOST_GAME_STATUS, data);
        });
    }

    private handleChangeObservedPLayer(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.CHANGE_OBSERVED_PLAYER, (data: NewObservedPlayer) => {
            const observedPlayerId = data.isHost ? HOST_USERNAME : data.oldUserId;
            const newObservedPlayerId = data.newUserId === roomManager.getRoomById(data.roomId).hostUserId ? HOST_USERNAME : data.newUserId;
            const observedPlayerSocketId = roomManager.getSocketIdByUsername(data.roomId, observedPlayerId);
            const newObservedPlayerSocketId = roomManager.getSocketIdByUsername(data.roomId, newObservedPlayerId);
            roomManager.updateObserverCounter(data.roomId, observedPlayerId, true);
            roomManager.updateObserverCounter(data.roomId, newObservedPlayerId, false);
            const obsMapCounter = roomManager.getRoomById(data.roomId).observersCounter;
            const inc_count = obsMapCounter.get(newObservedPlayerId);
            const dec_count = obsMapCounter.get(observedPlayerId);
            socket.leave(String(observedPlayerSocketId));
            socket.join(String(newObservedPlayerSocketId));
            if (inc_count >= 0) {
                console.log("sending CHANGE_OBSERVED_PLAYER");
                sio.to(newObservedPlayerSocketId).emit(SocketEvent.UPDATE_OBS_COUNT, inc_count);
            }
            if (dec_count >= 0) {
                console.log("sending CHANGE_OBSERVED_PLAYER");
                sio.to(observedPlayerSocketId).emit(SocketEvent.UPDATE_OBS_COUNT, dec_count);
            }
            const roomId = data.roomId;
            if (newObservedPlayerId !== HOST_USERNAME) {
                const room = roomManager.getRoomById(roomId);
                const game = room.game;
                const playerScore = game.players.get(newObservedPlayerId);
                // If QRE we check if QRE Answer has been registered => true = sending qre answer else sending 0. If not qre send 0;
                const playerQREAnswer = game.currentQuizQuestion.type === QuestionType.QRE ? game.playerQREAnswer.get(newObservedPlayerId) ? game.playerQREAnswer.get(newObservedPlayerId)[1] : 0 : 0;
                const answers = game.playersAnswers.get(newObservedPlayerId)?.answers ?? "";
                const qrlAnswer = answers && game.currentQuizQuestion.type === QuestionType.QRL ? answers : "";
                let players: [string, number][] = [];
                game.players.forEach((score, username) => {
                    players.push([username, score.points]);
                })
                const choicesStatsValues = Array.from(game.choicesStats.values());
                const player_data: PlayerCurrentGameInterface = {
                    roomId: roomId,
                    isBonus: playerScore.isBonus,
                    playerScore: playerScore.points,
                    players: players,
                    qreAnswer: playerQREAnswer,
                    qrlAnswer: String(qrlAnswer),
                    choicesStatsValues: choicesStatsValues,
                }
                sio.to(String(socket.id)).emit(SocketEvent.RECEIVE_PLAYER_GAME_STATUS, player_data);
                if (game.currentQuizQuestion.type === QuestionType.QCM) {
                    console.log("sending RECEIVE_PLAYER_GAME_STATUS");
                    sio.to(String(newObservedPlayerSocketId)).emit(SocketEvent.REQUEST_PAYER_QCM_CHOICES)
                }
                if (game.currentQuizQuestion.type === QuestionType.QRL) {
                    console.log("sending RECEIVE_PLAYER_GAME_STATUS");
                    sio.to(String(newObservedPlayerSocketId)).emit(SocketEvent.REQUEST_QRL_INTERACTION, newObservedPlayerId)
                }
            }
        });
    }

    private handleObsLeft(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.OBS_LEFT, (data: {roomId: number; observedId: string}) => {
            const userId = socket.handshake.auth.userId;
            const room = roomManager.getRoomById(data.roomId);
            if (room) {
                const ObservedUserId = data.observedId === room.hostUserId ? HOST_USERNAME : data.observedId;
                roomManager.updateObserverCounter(data.roomId, ObservedUserId, true);
                const count = room.observersCounter.get(ObservedUserId)
                if (count >= 0) {
                    const socketId = roomManager.getSocketIdByUsername(data.roomId, ObservedUserId)
                    if (socketId) sio.to(socketId).emit(SocketEvent.UPDATE_OBS_COUNT, count);


                }
                this.removeUserFromRoomCanal(data.roomId, userId, roomManager);
            }
        });
    }

    private handleGetObsCounter(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.GET_OBS_COUNT, (roomId: number) => {
            const room = roomManager.getRoomById(roomId);
            const hostUserId = room.hostUserId;
            const incomingUserId = socket.handshake.auth.userId;
            const userId = hostUserId === incomingUserId ? HOST_USERNAME : incomingUserId;
            const count = room.observersCounter.get(userId);
            if (count >= 0) {
                console.log("sending new GET_OBS_COUNT");
                sio.to(socket.id).emit(SocketEvent.UPDATE_OBS_COUNT, count)
            }
        });
    }

    private handleObsLastQRLAnswer(socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.GET_LAST_QRL_STATUS, (data: {
            roomId: number;
            lastQRLScore: number | undefined,
            qrlAnswer: string | undefined,
            userId: string
        }) => {
            sio.to(String(data.roomId)).emit(SocketEvent.RECEIVE_LAST_QRL_INTERACTION, data);
        });
    }

    private handleQCMAnswerReception(socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.RECEIVE_PLAYER_QCM_CHOICES, (data: PlayerSelection) => {
            sio.to(String(socket.id)).emit(SocketEvent.OBS_QCM_INTERACTION, data);
        });
    }

    private handleBanPlayer(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.BAN_PLAYER, async (data: PlayerUsername) => {
            const bannedID = roomManager.getSocketIdByUsername(data.roomId, data.username);
            const banned_socket = sio.sockets.sockets.get(bannedID)
            const bannedUserID = banned_socket.handshake.auth.userId
            roomManager.banUser(data.roomId, bannedUserID);
            await this.removeUserFromRoomCanal(data.roomId, banned_socket.handshake.auth.userId, roomManager);
            sio.to(bannedID).emit(SocketEvent.REMOVED_FROM_GAME);
            sio.to(String(data.roomId)).emit(SocketEvent.REMOVED_PLAYER, data.username);
            this.sendUpdateGameList(roomManager, sio)
            this.sendTeams(data.roomId, roomManager, sio);
        });
    }

    private handleToggleRoomLock(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.TOGGLE_ROOM_LOCK, (roomId: number) => {
            roomManager.changeLockState(roomId);
        });
    }

    private handleValidateUsername(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.VALIDATE_USERNAME, (data: PlayerUsername, callback) => {
            let error = '';
            if (roomManager.isNameUsed(data.roomId, data.username)) error = ErrorDictionary.NAME_ALREADY_USED;
            else if (roomManager.isNameBanned(data.roomId, data.username)) error = ErrorDictionary.BAN_MESSAGE;
            callback({isValid: error.length === 0, error});
        });
    }

    private handleGatherPlayersUsername(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.GATHER_PLAYERS_USERNAME, (roomId: number, callback) => {
            const players = roomManager.getUsernamesArray(roomId);
            this.sendTeams(roomId, roomManager, sio);
            callback(players);
        });
    }

    private handleValidateRoomId(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.VALIDATE_ROOM_ID, (roomId: number, callback) => {
            let isLocked = false;
            const isRoom = roomManager.roomMap.has(roomId);
            if (isRoom) isLocked = roomManager.getRoomById(roomId).locked;
            callback({isRoom, isLocked});
        });
    }

    // This handler manages what happens when a player leaves. If the game has started during his leave, we check whether
    // he was the only player remaining, which means that everyone left, causing then the game end.
    // if there are still players in the game, we check if with this player leaving, if every player that is remaining has
    // validated his response, if it is the case, we send an END_QUESTION event
    // We finally send a PLAYER_REMOVED event to the host to remove the player from the player list
    private handlePlayerLeft(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.PLAYER_LEFT, async (roomId: number) => {
            await this.removeUserFromRoomCanal(roomId, socket.handshake.auth.userId, roomManager);
            const userInfo = roomManager.removeUserBySocketId(socket.id);
            const obsMap = roomManager.getRoomById(roomId)?.observersCounter;
            this.debug_teams("PLayer Left", roomId, roomManager);
            this.sendUpdateGameList(roomManager, sio);
            if (obsMap) obsMap.delete(socket.handshake.auth.userId);
            sio.to(String(socket.id)).emit(SocketEvent.REMOVED_FROM_GAME);
            this.sendPlayerListToObserver(roomId, roomManager, sio);
            this.sendTeams(roomId, roomManager, sio);
            if (userInfo) {
                const game = roomManager.getGameByRoomId(roomId);
                if (game) {
                    game.removePlayer(userInfo.username);
                    if (game.players.size === 0) {
                        roomManager.clearRoomTimer(roomId);
                        this.timerService.startTimer({
                            roomId,
                            time: TRANSITION_QUESTIONS_DELAY
                        }, SocketEvent.FINAL_TIME_TRANSITION);
                    } else if (game.playersAnswers.size === game.players.size) {
                        roomManager.getGameByRoomId(roomId).updateScores();
                        roomManager.clearRoomTimer(roomId);
                        roomManager.getRoomById(roomId).players.forEach((socketId, username) => {
                            if (username !== HOST_USERNAME) sio.to(socketId).emit(SocketEvent.END_QUESTION);
                        });
                        sio.to(String(roomId)).emit(SocketEvent.END_QUESTION_AFTER_REMOVAL);
                    }
                }
                sio.to(String(roomId)).emit(SocketEvent.REMOVED_PLAYER, userInfo.username);
            }
        });
    }

    private handleHostLeft(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.HOST_LEFT, async (roomId: number) => {
            // socket.to(String(roomId)).emit(SocketEvent.REMOVED_FROM_GAME);
            sio.to(String(roomId)).emit(SocketEvent.REMOVED_FROM_GAME);
            await this.deleteRoomCanal(roomId, roomManager);
            // this.sendPlayerListToObserver(roomId, roomManager, sio);
            roomManager.deleteRoom(roomId);
            this.sendUpdateGameList(roomManager, sio);
            sio.to(String(roomId)).disconnectSockets(true);
        });
    }

    private handleGetGameList(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.GET_GAME_LIST, () => {
            sio.to(socket.id).emit(SocketEvent.UPDATE_GAME_LIST, roomManager.getGamesConfig());
        });
    }

    // type are winner, loser or none
    private handleSaveStats(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.SAVE_FINAL_GAME_STATS, async (roomId: number) => {
            const game = roomManager.getGameByRoomId(roomId);
            const gameType = roomManager.getRoomById(roomId).gameType;
            const roomData = roomManager.getRoomById(roomId);
            const onlyOnePlayer = roomData.players.size === 2; // including host
            const {
                highestScorers,
                nonExtremes,
                lowestScorers
            } = gameType === 'classic' ? this.getExtremeScoresClassicGame(game.players) : this.getExtremeScoresTeamGame(this.calculateTeamsFinalScore(roomId, roomManager, game.players))
            const winnerMoney = this.calculateMoney(highestScorers, roomData.players.size - 1, roomData.total_price, onlyOnePlayer, "winner", gameType, roomId, roomManager);
            const loserMoney = this.calculateMoney(highestScorers, roomData.players.size - 1, roomData.total_price, onlyOnePlayer, "loser", gameType, roomId, roomManager);
            for (let winner of highestScorers) await this.dispatchUpdateStats(winner, game, gameType, 'winner', roomId, roomManager, winnerMoney);
            for (let loser of lowestScorers) await this.dispatchUpdateStats(loser, game, gameType, 'loser', roomId, roomManager, loserMoney);
            for (let loser of nonExtremes) await this.dispatchUpdateStats(loser, game, gameType, 'none', roomId, roomManager, loserMoney);
        });
    }

    // Money is first divided in two lot if more than 1 player: winner 2/3 of lot and loser 1/3 of lot
    // Than winner lot is divided amongst number of active winner the same applies for losers
    private calculateMoney(winners: string[] | number[], players_qty: number, amount: number, isOnlyOnePlayer: boolean, type: string, gameType: string, roomId: number, roomManager: RoomManagingService) {
        let teamSize = 0;
        if (isOnlyOnePlayer || amount === 0) return amount;
        if (gameType !== "classic") for (let team of winners) teamSize += roomManager.getRoomById(roomId).teams.get(Number(team)).members.length
        const length = teamSize !== 0 ? teamSize : winners.length
        const player_qty = type === "winner" ? length : (players_qty - length)
        const fraction = player_qty > 0 ? player_qty : 1;
        const multiplier = type === "winner" ? (2 / 3) : (1 / 3);
        return Math.floor(((amount * multiplier) / fraction));
    }

    private handleGetGameType(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.GET_GAME_TYPE, (roomId: number, callback) => {
            const gameType = roomManager.getRoomById(roomId).gameType;
            callback(gameType);
        });
    }

    private handleCreateTeam(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.CREATE_TEAM, (roomId: number) => {
            const userId = socket.handshake.auth.userId;
            roomManager.createNewTeam(roomId, userId);
            this.debug_teams('Team Creation', roomId, roomManager)
            this.sendTeams(roomId, roomManager, sio);
        });
    }

    private handleJoinTeam(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.JOIN_TEAM, ({roomId, newTeamId}: JoinTeamData) => {
            const userId = socket.handshake.auth.userId;
            roomManager.joinTeam(roomId, userId, newTeamId);
            this.debug_teams('Team JOIN', roomId, roomManager)
            this.sendTeams(roomId, roomManager, sio);
        });
    }

    private handleObserverGetPlayerList(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.GET_OBSERVER_PLAYER_LIST, (roomId: number) => {
            this.sendPlayerListToObserver(roomId, roomManager, sio);
        });
    }

    // Object from entries to send Map (Map is not directly convertable to JSON) on client new Map(Object.entries(teams))
    private sendTeams(roomId: number, roomManager: RoomManagingService, sio: io.Server) {
        const teams = roomManager.getRoomById(roomId)?.teams;
        const result = teams ? teams : new Map(); // if last player left there is no teams left so send empty map
        sio.emit(SocketEvent.GET_TEAMS, Object.fromEntries(result));
    }

    private sendUpdateGameList(roomManager: RoomManagingService, sio: io.Server) {
        sio.emit(SocketEvent.UPDATE_GAME_LIST, roomManager.getGamesConfig())
    }

    private sendPlayerListToObserver(roomId: number, roomManager: RoomManagingService, sio: io.Server) {
        try {
            sio.emit(SocketEvent.SENDING_OBSERVER_PLAYER_LIST, roomManager.getUsernamesArray(roomId))
        } catch (e) {
            console.log(roomId)
        }
    }

    private generateRoomCanal(roomId: number, userId: string, teamId?: number): Canal {
        return {
            name: teamId ? `${roomId} #${teamId}` : `room ${roomId}`,
            isPrivate: false,
            permittedUsers: [userId],
            messages: []
        } as Canal;
    }

    public async handleUserDisconnection(roomManager: RoomManagingService, socketId: string, socket: io.Socket, sio: io.Server) {
        let res = roomManager.getUsernameAndRoomBySocketId(socketId);
        if (!res) return;
        const username = res[0];
        const roomId = res[1];
        if (username === 'Organisateur') {
            //This is the exact same code used in HOST_LEFT socket event above in the file
            socket.to(String(roomId)).emit(SocketEvent.REMOVED_FROM_GAME);
            await this.deleteRoomCanal(roomId, roomManager);
            roomManager.deleteRoom(roomId);
            this.sendUpdateGameList(roomManager, sio);
            sio.to(String(roomId)).disconnectSockets(true);
        } else {
            //This is the same code used in PLAYER_LEFT socket event above in the file
            await this.removeUserFromRoomCanal(roomId, socket.handshake.auth.userId, roomManager);
            const userInfo = roomManager.removeUserBySocketId(socket.id);
            this.debug_teams("PLayer Left", roomId, roomManager);
            this.sendUpdateGameList(roomManager, sio);
            this.sendTeams(roomId, roomManager, sio);
            if (userInfo) {
                const game = roomManager.getGameByRoomId(roomId);
                if (game) {
                    game.removePlayer(userInfo.username);
                    if (game.players.size === 0) {
                        roomManager.clearRoomTimer(roomId);
                        this.timerService.startTimer({
                            roomId,
                            time: TRANSITION_QUESTIONS_DELAY
                        }, SocketEvent.FINAL_TIME_TRANSITION);
                    } else if (game.playersAnswers.size === game.players.size) {
                        roomManager.getGameByRoomId(roomId).updateScores();
                        roomManager.clearRoomTimer(roomId);
                        roomManager.getRoomById(roomId).players.forEach((socketId, username) => {
                            if (username !== HOST_USERNAME) sio.to(socketId).emit(SocketEvent.END_QUESTION);
                        });
                        sio.to(String(roomId)).emit(SocketEvent.END_QUESTION_AFTER_REMOVAL);
                    }
                }
                sio.to(String(roomId)).emit(SocketEvent.REMOVED_PLAYER, userInfo.username);
            }
        }
    }

    private async addUserToRoomCanal(roomCode: number, userId: string) {
        try {
            const docRef = await this.getDocRef(roomCode);
            await docRef.update({
                permittedUsers: this.fs.firebase.firestore.FieldValue.arrayUnion(userId),
            });
        } catch (error) {
            console.log(error)
        }
    }

    private async removeUserFromRoomCanal(roomCode: number, userId: string, roomManager: RoomManagingService) {
        try {
            const docRef = await this.getDocRef(roomCode);
            await docRef.update({
                permittedUsers: this.fs.firebase.firestore.FieldValue.arrayRemove(userId),
            });
            const teams = roomManager.getRoomById(roomCode).teams;
            if (teams) {
                for (const [teamId, _] of teams) {
                    const teamDocRef = await this.getTeamCanal(roomCode, teamId);
                    await teamDocRef.update({
                        permittedUsers: this.fs.firebase.firestore.FieldValue.arrayRemove(userId)
                    });
                }
            }
        } catch (error) {
            console.log(error);
        }
    }

    private async dispatchUpdateStats(userIdOrTeamId: string | number, game: Game, gameType: string, type: string, roomId: number, roomManager: RoomManagingService, amount: number) {
        if (gameType === "classic") {
            await this.updateStats(userIdOrTeamId.toString(), game, gameType, type, amount);
        } else {
            const teams = roomManager.getRoomById(roomId).teams;
            if (teams) {
                const members = teams.get(Number(userIdOrTeamId)).members
                if (members) for (const userId of members) await this.updateStats(userId, game, gameType, type, amount);
            }
        }
    }

    // Method that updates player stats online type is either winner, loser
    // Update money has to be done here also but some logic has to be made in the class game when joining
    // with a price
    private async updateStats(userId: string, game: Game, gameType: string, type: string, amount: number) {
        const score = game.players.get(userId);
        const finalResult = type === 'winner' ? 'win' : 'loss';
        const money = amount === 0 ? (type === 'winner' ? 10 : 1) : amount;
        let prestige = type === 'winner' ? 10 : type === 'loser' ? -10 : 0;
        const history = {
            result: finalResult,
            timestamp: game.gameHistoryInfo.startTime,
            score: score.points,
            gameMode: gameType,
        } as GameHistory
        const startTime = game.startTimeCalcul;
        const currentTime = new Date().getTime();
        const timeDifferenceInSeconds = Math.floor((currentTime - startTime) / 1000);
        try {
            const docRef = await this.getDocRefUsers(userId);
            const user = (await docRef.get()).data() as User;
            if (user.prestige === 0 && prestige === -10) prestige = 0;
            const newStats = this.calculateNewStats(user.stats, score, timeDifferenceInSeconds, type);
            const achievements = this.checkAchievements(newStats, prestige, user, gameType);
            user.achievements.forEach((value) => {
                if (!achievements.includes(value)) achievements.push(value)
                achievements.sort((a, b) => a - b)
            });
            await docRef.update({
                gameHistory: this.fs.firebase.firestore.FieldValue.arrayUnion(history),
                level: this.fs.firebase.firestore.FieldValue.increment(score.points),
                prestige: this.fs.firebase.firestore.FieldValue.increment(prestige),
                stats: newStats,
                achievements: achievements,
                currency: this.fs.firebase.firestore.FieldValue.increment(money)
            });
        } catch (error) {
            console.log(error);
        }
    }

    private async deleteRoomCanal(roomCode: number, roomManager: RoomManagingService) {
        try {
            const docRef = await this.getDocRef(roomCode);
            await docRef.delete();
            const teams = roomManager.getRoomById(roomCode).teams;
            if (teams) {
                for (const [teamId, _] of teams) {
                    const teamDocRef = await this.getTeamCanal(roomCode, teamId);
                    await teamDocRef.delete();
                }
            }
        } catch (error) {
            console.log(error);
        }
    }

    private async getDocRef(roomCode: number) {
        const querySnapshot = await this.fs.firestore
            .collection('canals')
            .where('name', '==', `room ${roomCode}`)
            .get();
        if (querySnapshot.empty) throw new Error(`No canal found with roomCode: ${roomCode}`);
        return querySnapshot.docs[0].ref;
    }

    private async getTeamCanal(roomCode: number, teamId: number) {
        const querySnapshot = await this.fs.firestore
            .collection('canals')
            .where('name', '==', `${roomCode} #${teamId}`)
            .get();
        if (querySnapshot.empty) throw new Error(`No canal found with roomCode: ${roomCode}`);
        return querySnapshot.docs[0].ref;
    }

    private async getDocRefUsers(userId: string) {
        const docRef = this.fs.firestore.collection('users').doc(userId);
        const docSnapshot = await docRef.get();
        if (!docSnapshot.exists) {
            throw new Error(`No User found with id: ${userId}`);
        }
        return docRef;
    }

    private calculateNewStats(oldStats: UserStats, score: Score, timeDifferenceInSeconds: number, type: string) {
        return {
            gamesPlayed: oldStats.gamesPlayed + 1,
            gamesWon: type === 'winner' ? oldStats.gamesWon + 1 : oldStats.gamesWon,
            correctAnswers: oldStats.correctAnswers + score.goodAnswerCounter,
            gameTime: oldStats.gameTime + timeDifferenceInSeconds,
            avgCorrectAnswers: parseFloat(((oldStats.correctAnswers + score.goodAnswerCounter) / (oldStats.gamesPlayed + 1)).toFixed(2)),
            avgGameTime: parseFloat(((oldStats.gameTime + timeDifferenceInSeconds) / (oldStats.gamesPlayed + 1)).toFixed(2)),
        } as UserStats
    }

    private getExtremeScoresClassicGame(players: Map<string, Score>) {
        let highestScore = -Infinity;
        let lowestScore = Infinity;
        const highestScorers: string[] = [];
        const lowestScorers: string[] = [];
        const nonExtremes: string[] = [];
        let total_score_sum = 0
        players.forEach((score: Score, userId: string) => {
            total_score_sum += score.points
            if (score.points > highestScore) {
                highestScore = score.points;
                highestScorers.length = 0;
                highestScorers.push(userId);
            } else if (score.points === highestScore) {
                highestScorers.push(userId);
            }

            if (score.points < lowestScore) {
                lowestScore = score.points;
                lowestScorers.length = 0;
                lowestScorers.push(userId);
            } else if (score.points === lowestScore) {
                lowestScorers.push(userId);
            }
        });

        if (total_score_sum == 0) {
            highestScorers.length = 0; nonExtremes.length = 0; lowestScorers.length = 0;
            players.forEach((score: Score, userId: string) => {
                lowestScorers.push(userId);
            });

        } else {
            players.forEach((score: Score, userId: string) => {
                if (!highestScorers.includes(userId) && !lowestScorers.includes(userId)) {
                    nonExtremes.push(userId);
                }
            });
            if (players.size === 1) {
                lowestScorers.length = 0
                nonExtremes.length = 0
            }
        }

        return {
            highestScorers,
            nonExtremes,
            lowestScorers,
        };
    }

    private getExtremeScoresTeamGame(teamsScore: Map<number, number>) {
        let highestScore = -Infinity;
        let lowestScore = Infinity;
        const highestScorers: number[] = [];
        const lowestScorers: number[] = [];
        const nonExtremes: number[] = [];
        let total_score_sum = 0;
        teamsScore.forEach((score, teamId) => {
            // Check for the highest scoring teams
            total_score_sum += score
            if (score > highestScore) {
                highestScore = score;
                highestScorers.length = 0;
                highestScorers.push(teamId);
            } else if (score === highestScore) {
                highestScorers.push(teamId);
            }

            // Check for the lowest scoring teams
            if (score < lowestScore) {
                lowestScore = score;
                lowestScorers.length = 0;
                lowestScorers.push(teamId);
            } else if (score === lowestScore) {
                lowestScorers.push(teamId);
            }
        });

        if (total_score_sum == 0) {
            highestScorers.length = 0; nonExtremes.length = 0; lowestScorers.length = 0;
            teamsScore.forEach((score, teamId) => {
                    lowestScorers.push(teamId);
            });
        } else {
            // Populate the non-extreme teams (those not in the highest or lowest scoring groups)
            teamsScore.forEach((score, teamId) => {
                if (!highestScorers.includes(teamId) && !lowestScorers.includes(teamId)) {
                    nonExtremes.push(teamId);
                }
            });

            // If there's only one team, there won't be any lowest or non-extreme teams
            if (teamsScore.size === 1) {
                lowestScorers.length = 0;
                nonExtremes.length = 0;
            }
        }
        return {
            highestScorers,
            nonExtremes,
            lowestScorers,
        };
    }

    private calculateTeamsFinalScore(roomId: number, roomManager: RoomManagingService, players: Map<string, Score>) {
        const teams = roomManager.getRoomById(roomId).teams;
        const teamsScore = new Map<number, number>(); // teamId as key and total point
        if (teams && players) {
            teams.forEach((team, teamId) => {
                let total = 0;
                team.members.forEach((userId) => {
                    const score = players.get(userId);
                    total += score.points;
                });
                teamsScore.set(teamId, total);
            });
        }
        return teamsScore ? teamsScore : new Map<number, number>();
    }

    // Two game types equipe or classic
    private checkAchievements(newStats: UserStats, prestige: number, user: User, gameType: string) {
        const achievements: number[] = []; // 1000 is a based number that allows to return an array of 1 with is usable in arrayUnion
        if (newStats.gamesWon >= 1) achievements.push(1);
        if (newStats.gamesWon > user.stats.gamesWon && gameType === 'equipe') achievements.push(2);
        if (newStats.gamesWon >= 5) achievements.push(3);
        if (newStats.gamesWon >= 10) achievements.push(4);
        if ((user.prestige + prestige) === 50) achievements.push(5);
        if ((user.prestige + prestige) === 100) achievements.push(6);
        if ((user.prestige + prestige) === 150) achievements.push(7);
        if ((user.prestige + prestige) === 200) achievements.push(8);
        return achievements
    }

    private debug_teams(when: string, roomId: number, roomManager: RoomManagingService) {
        const room = roomManager.getRoomById(roomId)
        if (room) {
            const teams = room.teams
            if (teams) {
                teams.forEach((team, id) => {
                });
            }
        }
    }
}
