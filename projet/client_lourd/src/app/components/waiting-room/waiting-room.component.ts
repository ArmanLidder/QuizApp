import {Component, inject, Input, OnDestroy, OnInit, HostListener} from '@angular/core';
import {SocketClientService} from '@app/services/socket-client.service/socket-client.service';
import {SocketEvent} from '@common/socket-event-name/socket-event-name';
import {
    WaitingRoomManagementService
} from '@app/services/waiting-room-management.service/waiting-room-management.service';
import {ActivatedRoute} from '@angular/router';
import {GameService} from '@app/services/game.service/game.service';
import {HOST_USERNAME} from '@common/names/host-username';
import {GameConfigService} from "@app/services/game-config.service/game-config.service";
import {GameConfig} from "@common/interfaces/game-info.interface";
import {UsersService} from "@app/services/users.service/users.service";
import {firstValueFrom, Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {TranslateService} from "@ngx-translate/core";


@Component({
    selector: 'app-waiting-room',
    templateUrl: './waiting-room.component.html',
    styleUrls: ['./waiting-room.component.scss'],
})
export class WaitingRoomComponent implements OnInit, OnDestroy {
    @Input() isHost: boolean;
    @Input() roomId: number;
    @Input() isActive: boolean;
    currentUser$: Observable<User | null> ;
    currentUserId : string;
    private readonly route: ActivatedRoute = inject(ActivatedRoute);
    // private router: Router = inject(Router);

    constructor(
        public waitingRoomManagementService: WaitingRoomManagementService,
        public gameService: GameService,
        public usersService: UsersService,
        private socketService: SocketClientService,
        private gameConfigService: GameConfigService,
        private translate: TranslateService
    ) {
        // this.connect();
        this.currentUser$ = this.usersService.currentUserProfile$;
    }

    // Since beforeunload automatically reconstruct the component, we need a way to go back to main page with service
    // property on initialization
    @HostListener('window:beforeunload')
    removeToken() {
        const messageType = this.isHost ? SocketEvent.HOST_LEFT : SocketEvent.PLAYER_LEFT;
        this.socketService.send(messageType, this.roomId);
    }

    async ngOnInit() {
        this.waitingRoomManagementService.setUpService();
        if (!this.socketService.isSocketAlive()) {
            this.socketService.connect();
        }
        this.waitingRoomManagementService.configureBaseSocketFeatures();
        if (this.isHost) await this.setUpHost();
        else this.setUpPlayer();
        this.currentUserId = (await firstValueFrom(this.currentUser$) as User).uid
        window.onbeforeunload = () => this.ngOnDestroy();
    }

    ngOnDestroy() {
        if (!this.waitingRoomManagementService.isGameStarting) {
            const messageType = this.isHost ? SocketEvent.HOST_LEFT : SocketEvent.PLAYER_LEFT;
            this.socketService.send(messageType, this.roomId);
            this.gameService.destroy();
        }
        this.socketService.socket.removeAllListeners();
    }

    // async connect() {
    //     if (!this.socketService.isSocketAlive()) {
    //          this.socketService.asyncConnect();
    //     }
    // }

    banPlayer(username: string) {
        this.waitingRoomManagementService.sendBanPlayer(username);
    }

    toggleRoomLocked() {
        this.waitingRoomManagementService.isRoomLocked = !this.waitingRoomManagementService.isRoomLocked;
        this.waitingRoomManagementService.sendToggleRoomLock();
    }

    setLockActionMessage() {
        return this.waitingRoomManagementService.isRoomLocked
            ? this.translate.instant('WAITING_ROOM_PAGE.STATUS_LOCKED')
            : this.translate.instant('WAITING_ROOM_PAGE.STATUS_UNLOCKED');
    }

    startGame() {
        this.waitingRoomManagementService.sendStartSignal();
    }

    onlyOneMember() {
        let result = false;
        this.waitingRoomManagementService.teamsForInterface.forEach((team: any) => {
            if (team.userIds.members.includes(this.currentUserId) && team.userIds.members.length < 2) result = true;
        });
        return result;
    }

    // Has to be changed to teams.siza < 2 for prod
    validationBeforeEntry() {
        if (this.waitingRoomManagementService.gameType === 'classic')
            return this.waitingRoomManagementService.players.length===0||!this.waitingRoomManagementService.isRoomLocked;
        let moreThanTwoMembers = 0;
        this.waitingRoomManagementService.teamsForInterface.forEach((team: any) => {
            if (team.userIds.members.length > 1) moreThanTwoMembers += 1;
        });
        return moreThanTwoMembers < 1 || this.waitingRoomManagementService.teams.size < 1 || !this.waitingRoomManagementService.isRoomLocked

    }

    private async setUpHost() {
        const quizId = this.route.snapshot.paramMap.get('id');
        this.roomId = await this.waitingRoomManagementService.sendRoomCreation(quizId, (this.gameConfigService.getGameConfig() as GameConfig));
        this.gameService.gameRealService.username = HOST_USERNAME;
        this.waitingRoomManagementService.gameType = this.gameConfigService.gameType as unknown as "classic" | "equipe";
    }

    private setUpPlayer() {
        this.waitingRoomManagementService.roomId = this.roomId;
        this.waitingRoomManagementService.gatherPlayers();
    }
}
