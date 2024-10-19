import { Component } from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
    selector: 'app-waiting-room-player-page',
    templateUrl: './waiting-room-player-page.component.html',
    styleUrls: ['./waiting-room-player-page.component.scss'],
})
export class WaitingRoomPlayerPageComponent {
    roomId: number;
    isValidation: boolean = true;

    constructor(private socketService: SocketClientService) {
        if (!this.socketService.isSocketAlive()) this.socketService.connect()
    }

    receiveRoomId(roomId: number) {
        this.roomId = roomId;
    }

    receiveValidation(isValid: boolean) {
        this.isValidation = isValid;
    }
}
