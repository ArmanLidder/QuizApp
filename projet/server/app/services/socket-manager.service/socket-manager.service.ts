import { QuizService } from '@app/services/quiz.service/quiz.service';
import { RoomManagingService } from '@app/services/room-managing.service/room-managing.service';
import * as http from 'http';
import * as io from 'socket.io';
import { SocketEvent } from '@common/socket-event-name/socket-event-name';
import { HistoryService } from '@app/services/history.service/history.service';
import { GameCreationService } from '@app/services/game-creation.service/game-creation.service';
import { GameManagementService } from '@app/services/game-management.service/game-management.service';
import { ChatService } from '@app/services/chat.service/chat.service';
// import {PlayerUsername} from "@common/interfaces/socket-manager.interface";
// import {ErrorDictionary} from "@common/browser-message/error-message/error-message";


export class SocketManager {
    sio: io.Server;
    private roomManager: RoomManagingService;
    private gameCreationService: GameCreationService;
    private gameManagementService: GameManagementService;
    private chatService: ChatService;

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
        this.roomManager = new RoomManagingService();
        this.gameCreationService = new GameCreationService();
        this.gameManagementService = new GameManagementService(this.quizService, this.historyService);
        this.chatService = new ChatService();
    }

    handleSockets(): void {
        this.sio.on(SocketEvent.CONNECTION, (socket) => {
            const userId = socket.handshake.auth.userId;
            console.log(`New client socket connection: ${userId}`);
            this.gameCreationService.configureGameCreationSockets(this.roomManager, socket, this.sio);
            this.gameManagementService.configureGameManagingSockets(this.roomManager, socket, this.sio);
            this.chatService.configureChatSockets(this.roomManager, socket, this.sio);
            socket.on('disconnect', async () => {
                console.log('Client disconnected');
            });
        });
    }
}
