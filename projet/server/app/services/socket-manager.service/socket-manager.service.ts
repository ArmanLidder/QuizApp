import { QuizService } from '@app/services/quiz.service/quiz.service';
import { RoomManagingService } from '@app/services/room-managing.service/room-managing.service';
import * as http from 'http';
import * as io from 'socket.io';
import { SocketEvent } from '@common/socket-event-name/socket-event-name';
import { HistoryService } from '@app/services/history.service/history.service';
import { GameCreationService } from '@app/services/game-creation.service/game-creation.service';
import { GameManagementService } from '@app/services/game-management.service/game-management.service';
import {FirebaseService} from "@app/services/firebase.service/firebase.service";

export class SocketManager {
    sio: io.Server;
    private roomManager: RoomManagingService;
    private gameCreationService: GameCreationService;
    private gameManagementService: GameManagementService;
    private fs: FirebaseService;

    constructor(
        private quizService: QuizService,
        private historyService: HistoryService,
        server: http.Server,
    ) {
        this.sio = new io.Server(server, {
            cors: {
                origin: '*',
                methods: ['GET', 'POST'],
                allowedHeaders: ["my-custom-header"], // added
                credentials: true // added
            }
        });
        this.fs = new FirebaseService();
        this.roomManager = new RoomManagingService();
        this.gameCreationService = new GameCreationService(this.fs);
        this.gameManagementService = new GameManagementService(this.quizService, this.historyService, this.fs);
    }

    handleSockets(): void {
        this.sio.on(SocketEvent.CONNECTION, async (socket) => {
            const userId = socket.handshake.auth.userId;
            console.log(`New client socket connection: ${userId}`);
            this.gameCreationService.configureGameCreationSockets(this.roomManager, socket, this.sio);
            this.gameManagementService.configureGameManagingSockets(this.roomManager, socket, this.sio);
            socket.on('disconnect', async () => {
                console.log(`Client disconnected ${socket.handshake.auth.userId}`);
                await this.gameCreationService.handleUserDisconnection(this.roomManager,socket.id,socket, this.sio);
            });
        });
    }
}
