import { Component, OnDestroy, OnInit } from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
    selector: 'app-waiting-room-player-page',
    templateUrl: './waiting-room-player-page.component.html',
    styleUrls: ['./waiting-room-player-page.component.scss'],
})
export class WaitingRoomPlayerPageComponent implements OnDestroy, OnInit{
    roomId: number;
    isValidation: boolean = true;
    isPrivate: boolean = false;

    constructor(private socketService: SocketClientService) {
        if (!this.socketService.isSocketAlive()) this.socketService.connect()
    }

    ngOnInit() {
        this.isPrivate = false;
    }

    ngOnDestroy() {
        this.isPrivate = false;
    }

    togglePrivate() {
        this.isPrivate = !this.isPrivate
    }

    receiveRoomId(roomId: number) {
        this.roomId = roomId;
    }

    receiveValidation(isValid: boolean) {
        this.isValidation = isValid;
    }
}
