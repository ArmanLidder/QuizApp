import {Component, HostListener,OnDestroy} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {AuthService} from "@app/services/auth.service/auth.service";

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnDestroy {

    constructor(private socketService: SocketClientService, private authService: AuthService) {
    }

    @HostListener('window:beforeunload')
    removeToken() {
        this.socketService.disconnect();
        this.authService.logout();
    }

    ngOnDestroy() {
        this.socketService.disconnect();
        this.authService.logout();
    }
}
