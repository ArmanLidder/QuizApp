import { Component, HostListener } from '@angular/core';
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent {
    readonly title: string = 'OnlyQuiz';

    constructor(private socketService: SocketClientService) {
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

}
