import { Component } from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
    selector: 'app-game-creation-page',
    templateUrl: './game-creation-page.component.html',
    styleUrls: ['./game-creation-page.component.scss'],
})
export class GameCreationPageComponent {
    constructor(private socketService: SocketClientService) {
        if (!this.socketService.isSocketAlive()) this.socketService.connect()
    }
}
