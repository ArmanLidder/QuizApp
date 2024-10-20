import {RoomManagingService} from '@app/services/room-managing.service/room-managing.service';
import {TRANSITION_QUESTIONS_DELAY} from '@common/constants/socket-manager.service.const';
import {TimerService} from '@app/services/timer.service/timer.service';
import {ErrorDictionary} from '@common/browser-message/error-message/error-message';
import {PlayerUsername} from '@common/interfaces/socket-manager.interface';
import {HOST_USERNAME} from '@common/names/host-username';
import {SocketEvent} from '@common/socket-event-name/socket-event-name';
import * as io from 'socket.io';
import {Service} from 'typedi';
import {FirebaseService} from "@app/services/firebase.service/firebase.service";
import {Canal} from "@common/interfaces/message.interface";
import {GameConfig} from "@common/interfaces/game-info.interface";

@Service()
export class GameCreationService {
    private timerService: TimerService;
    private fs: FirebaseService;

    constructor() {
        this.fs = new FirebaseService();
    }

    configureGameCreationSockets(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        this.timerService = new TimerService(roomManager, sio);
        this.handleRoomCreation(roomManager, socket);
        this.handleJoinGame(roomManager, socket, sio);
        this.handleBanPlayer(roomManager, socket, sio);
        this.handleToggleRoomLock(roomManager, socket);
        this.handleValidateUsername(roomManager, socket);
        this.handleGatherPlayersUsername(roomManager, socket);
        this.handleValidateRoomId(roomManager, socket);
        this.handlePlayerLeft(roomManager, socket, sio);
        this.handleHostLeft(roomManager, socket, sio);
    }

    private handleRoomCreation(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.CREATE_ROOM, async (data: { quizId: string, gameConfig: GameConfig }, callback) => {
            const userId = socket.handshake.auth.userId;
            const roomCode = roomManager.addRoom(data.quizId, data.gameConfig);
            await this.fs.firestore.collection('canals').add(this.generateRoomCanal(roomCode, userId))
            roomManager.addUser(roomCode, HOST_USERNAME, socket.id);
            socket.join(String(roomCode));
            callback(roomCode);
        });
    }

    private handleJoinGame(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.JOIN_GAME, async (data: PlayerUsername, callback) => {
            const isLocked = roomManager.isRoomLocked(data.roomId);
            if (!isLocked) {
                const roomCode = data.roomId;
                const userId = socket.handshake.auth.userId;
                console.log(`userId joining game: ${userId}`);
                roomManager.addUser(roomCode, data.username, socket.id);
                const players = roomManager.getUsernamesArray(roomCode);
                socket.join(String(roomCode));
                await this.addUserToRoomCanal(roomCode, userId);
                sio.to(String(data.roomId)).emit(SocketEvent.NEW_PLAYER, players);
            }
            callback(isLocked);
        });
    }

    private handleBanPlayer(roomManager: RoomManagingService, socket: io.Socket, sio: io.Server) {
        socket.on(SocketEvent.BAN_PLAYER, async (data: PlayerUsername) => {
            const bannedID = roomManager.getSocketIdByUsername(data.roomId, data.username);
            const banned_socket = sio.sockets.sockets.get(bannedID)
            roomManager.banUser(data.roomId, data.username);
            await this.removeUserFromRoomCanal(data.roomId, banned_socket.handshake.auth.userId);
            sio.to(bannedID).emit(SocketEvent.REMOVED_FROM_GAME);
            sio.to(String(data.roomId)).emit(SocketEvent.REMOVED_PLAYER, data.username);
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

    private handleGatherPlayersUsername(roomManager: RoomManagingService, socket: io.Socket) {
        socket.on(SocketEvent.GATHER_PLAYERS_USERNAME, (roomId: number, callback) => {
            const players = roomManager.getUsernamesArray(roomId);
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
            await this.removeUserFromRoomCanal(roomId, socket.handshake.auth.userId);
            const userInfo = roomManager.removeUserBySocketId(socket.id);
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
            socket.to(String(roomId)).emit(SocketEvent.REMOVED_FROM_GAME);
            roomManager.deleteRoom(roomId);
            await this.deleteRoomCanal(roomId);
            sio.to(String(roomId)).disconnectSockets(true);
        });
    }

    private generateRoomCanal(roomId: number, userId: string): Canal {
        return {
            name: `room ${roomId}`,
            isPrivate: false,
            permittedUsers: [userId],
            messages: []
        } as Canal;
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

    private async removeUserFromRoomCanal(roomCode: number, userId: string) {
       try {
           const docRef = await this.getDocRef(roomCode);
           await docRef.update({
               permittedUsers: this.fs.firebase.firestore.FieldValue.arrayRemove(userId),
           });
       } catch(error) {
           console.log(error);
       }
    }

    private async deleteRoomCanal(roomCode: number) {
        try {
            const docRef = await this.getDocRef(roomCode);
            await docRef.delete()
        } catch(error) {
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
}
