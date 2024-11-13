import {Component, inject, OnDestroy, OnInit} from '@angular/core';
import { Router } from '@angular/router';
import { GameService } from '@app/services/game.service/game.service';
import { SocketClientService } from '@app/services/socket-client.service/socket-client.service';
import { SocketEvent } from '@common/socket-event-name/socket-event-name';
import { HOST_USERNAME } from '@common/names/host-username';
import { InteractiveListSocketService } from '@app/services/interactive-list-socket.service/interactive-list-socket.service';
import {ObservationService} from "@app/services/observation.service/observation.service";

@Component({
    selector: 'app-game-page',
    templateUrl: './game-page.component.html',
    styleUrls: ['./game-page.component.scss'],
})
export class GamePageComponent implements OnDestroy, OnInit {
    isHost: boolean;
    private route: Router = inject(Router);

    constructor(
        public gameService: GameService,
        private readonly socketService: SocketClientService,
        private interactiveListService: InteractiveListSocketService,
        public observationService: ObservationService,
    ) {}

     ngOnInit() {
        if (this.observationService.isHost) this.isHost = this.observationService.isHost;
        else this.isHost = this.gameService.gameRealService.username === HOST_USERNAME;
        if (this.socketService.isSocketAlive()) {
            this.interactiveListService.configureBaseSocketFeatures();
        }
        window.onbeforeunload = () => this.ngOnDestroy();
        window.onload = async () => this.route.navigate(['/']);
    }

    ngOnDestroy() {
        const messageType = this.isHost ? SocketEvent.HOST_LEFT : SocketEvent.PLAYER_LEFT;
        if (this.socketService.isSocketAlive() && !this.gameService.observerMode) {
            this.socketService.send(messageType, this.gameService.gameRealService.roomId);
        }
        this.gameService.destroy();
        this.gameService.audio.pause();
        this.observationService.isHost = false;
    }
}
