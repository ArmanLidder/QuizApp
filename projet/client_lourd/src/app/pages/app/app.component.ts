import {Component, OnDestroy, HostListener} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {AuthService} from "@app/services/auth.service/auth.service";


@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnDestroy {

    constructor(private socketService: SocketClientService,
                private authService: AuthService) {}



    @HostListener('window:beforeunload')
    removeToken() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        this.authService.logout();
        console.log('app disonnect')
    }

    async ngOnDestroy() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        await this.authService.logout();
    }
}
