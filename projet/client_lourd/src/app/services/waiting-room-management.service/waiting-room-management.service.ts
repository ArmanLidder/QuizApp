import { inject, Injectable } from '@angular/core';
import { SocketEvent } from '@common/socket-event-name/socket-event-name';
import { DELETE_NUMBER, START_TRANSITION_DELAY } from '@common/constants/waiting-room.component.const';
import { SocketClientService } from '@app/services/socket-client.service/socket-client.service';
import { Router } from '@angular/router';
import { GAME_PAGE, HOME_PAGE } from '@common/page-url/page-url';
import {GameConfig} from "@common/interfaces/game-info.interface";
import {JoinTeamData} from "@common/interfaces/socket-manager.interface";

type Team = any;
type TeamId = string;
type Teams = Map<TeamId, Team>;

@Injectable({
    providedIn: 'root',
})
export class WaitingRoomManagementService {
    roomId: number = 0;
    isRoomLocked: boolean = false;
    isGameStarting: boolean = false;
    isTransition: boolean = false;
    players: string[] = [];
    time: number = 0;
    gameType: 'classic' | 'equipe' = 'classic';
    teams: Teams;
    teamsForInterface: any;
    private router: Router = inject(Router);

    constructor(private socketService: SocketClientService) {}

    setUpService() {
        this.roomId = 0;
        this.isRoomLocked = false;
        this.isGameStarting = false;
        this.isTransition = false;
        this.players = [];
        this.teams = new Map<TeamId, Team>();
        this.teamsForInterface = [];
        this.time = 0;
    }

    async sendRoomCreation(quizId: string | null, gameConfig: GameConfig) {
        const data = {
            quizId: quizId,
            gameConfig: gameConfig,
        }
        return new Promise<number>((resolve) => {
            this.socketService.send(SocketEvent.CREATE_ROOM, data, (roomCode: number) => {
                this.roomId = roomCode;
                resolve(roomCode);
            });
        });
    }

    sendBanPlayer(username: string) {
        this.socketService.send(SocketEvent.BAN_PLAYER, { roomId: this.roomId, username });
    }

    sendToggleRoomLock() {
        this.socketService.send(SocketEvent.TOGGLE_ROOM_LOCK, this.roomId);
    }

    sendStartSignal() {
        this.socketService.send(SocketEvent.START, { roomId: this.roomId, time: START_TRANSITION_DELAY });
    }

    sendCreateTeam() {
        setTimeout(() => {
            if (!this.isRoomLocked) this.socketService.send(SocketEvent.CREATE_TEAM, this.roomId);
        }, 500)
    }

    joinTeam(newTeamId: string) {
        setTimeout(() => {
            if (!this.isRoomLocked) {
                const joinTeamData = {roomId: this.roomId, newTeamId: newTeamId as unknown as number} as JoinTeamData
                this.socketService.send(SocketEvent.JOIN_TEAM, joinTeamData);
            }
        }, 500)
    }

    removePlayer(username: string) {
        const index = this.players.indexOf(username);
        this.players.splice(index, DELETE_NUMBER);
    }

    gatherPlayers() {
        this.socketService.send(SocketEvent.GET_GAME_TYPE, this.roomId, (gameType: 'classic' | 'equipe') => {
            this.gameType = gameType;
        });
        this.socketService.send(SocketEvent.GATHER_PLAYERS_USERNAME, this.roomId, (players: string[]) => {
            this.players = players;
        });
    }

    configureBaseSocketFeatures() {
        this.handleNewPlayer();
        this.handleRemovedFromGame();
        this.handleRemovedPlayer();
        this.handleTime();
        this.handleFinalTransition();
        this.handleGetTeams();
        this.handleRoomLockUpdate();
    }

    private handleNewPlayer() {
        this.socketService.on(SocketEvent.NEW_PLAYER, (players: string[]) => {
            this.players = players;
        });
    }

    private handleGetTeams() {
        this.socketService.on(SocketEvent.GET_TEAMS, (teams: Object) => {
            this.teams = new Map(Object.entries(teams));
            this.teamsForInterface = Array.from(this.teams.entries()).map(([teamName, userIds]) => ({
                name: teamName,
                userIds: userIds,
            }));
        });
    }

    private handleRemovedFromGame() {
        this.socketService.on(SocketEvent.REMOVED_FROM_GAME, () => {
            this.router.navigate([`/${HOME_PAGE}`]);
        });
    }

    private handleRemovedPlayer() {
        this.socketService.on(SocketEvent.REMOVED_PLAYER, (username: string) => {
            if (this.players.includes(username)) {
                this.removePlayer(username);
            }
        });
    }

    private handleTime() {
        this.socketService.on(SocketEvent.TIME, (timeValue: number) => {
            this.isTransition = true;
            this.time = timeValue;
            if (this.time === 0) {
                this.router.navigate([`${GAME_PAGE}`, this.roomId]);
                this.isGameStarting = true;
            }
        });
    }

    private handleFinalTransition() {
        this.socketService.on(SocketEvent.FINAL_TIME_TRANSITION, () => {
            if (this.isTransition) {
                this.router.navigate(['/']);
            }
        });
    }

    private handleRoomLockUpdate() {
        this.socketService.on(SocketEvent.GET_ROOM_LOCK_UPDATE, (isLocked: boolean) => {
            this.isRoomLocked = isLocked;
        });
    }
}
