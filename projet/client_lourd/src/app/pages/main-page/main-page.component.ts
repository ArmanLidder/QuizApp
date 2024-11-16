import {Component, HostListener, OnInit} from '@angular/core';
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";
import {GameListService} from "@app/services/game-list.service/game-list.service";
import {
    HostInterfaceManagementService
} from "@app/services/host-interface-management.service/host-interface-management.service";
import {GameService} from "@app/services/game.service/game.service";
import {GameConfigService} from "@app/services/game-config.service/game-config.service";
import {ObservationService} from "@app/services/observation.service/observation.service";
import {
    GameInterfaceManagementService
} from "@app/services/game-interface-management.service/game-interface-management.service";
import {UsersService} from "@app/services/users.service/users.service";
import {
    InteractiveListSocketService
} from "@app/services/interactive-list-socket.service/interactive-list-socket.service";

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent implements OnInit {
    readonly title: string = 'Polyquiz';
    username: string;

    constructor(
        private socketService: SocketClientService,
        private activeGameListService: GameListService,
        private hostInterfaceService: HostInterfaceManagementService,
        private gameService: GameService,
        private gameInterfaceService: GameInterfaceManagementService,
        private gameConfigService: GameConfigService,
        private observationServices: ObservationService,
        private interactionService: InteractiveListSocketService,
        public usersService: UsersService, 
    ) {
        this.usersService.currentUserProfile$.subscribe((user)=>{
            this.username = user?.username!;
        })
        window.onload = () => {
            localStorage.removeItem('token');
            this.socketService.disconnect();
        }
    }

    @HostListener('window:beforeunload')
    removeToken() {
        localStorage.removeItem('token');
        this.socketService.disconnect();
    }

    ngOnInit() {
        this.resetAllServices();
    }

    private resetAllServices() {
        this.gameService.reset();
        this.gameInterfaceService.reset();
        this.hostInterfaceService.reset();
        this.observationServices.reset();
        this.gameConfigService.reset();
        this.activeGameListService.cleanup();
        this.interactionService['reset']();
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
    }
}
