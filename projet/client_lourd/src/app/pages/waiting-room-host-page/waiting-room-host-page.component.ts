import { Component } from '@angular/core';
import {
    WaitingRoomManagementService
} from "@app/services/waiting-room-management.service/waiting-room-management.service";

@Component({
    selector: 'app-waiting-room-host-page',
    templateUrl: './waiting-room-host-page.component.html',
    styleUrls: ['./waiting-room-host-page.component.scss'],
})
export class WaitingRoomHostPageComponent {
    constructor(public waitingRoomManagementService: WaitingRoomManagementService,) {
    }
}
