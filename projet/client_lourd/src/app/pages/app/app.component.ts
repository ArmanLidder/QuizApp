import {Component, HostListener,OnDestroy} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnDestroy {

    constructor(private socketService: SocketClientService) {
    }

    @HostListener('window:beforeunload')
    removeToken() {
        localStorage.removeItem('token');
        this.socketService.disconnect();
    }

    ngOnDestroy() {
        localStorage.removeItem('token');
        this.socketService.disconnect();
    }
}
