import { Component, OnDestroy, HostListener } from '@angular/core';
import { Router } from '@angular/router';
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";
import { AuthService } from "@app/services/auth.service/auth.service";
import { UsersService } from "@app/services/users.service/users.service";
import { UserSettingsService } from "@app/services/user-settings.service/user-settings.service";

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnDestroy {
    showChat: boolean = true;

    constructor(
        private socketService: SocketClientService,
        private authService: AuthService,
        public usersService: UsersService,
        public settings: UserSettingsService,
        private router: Router
    ) {
        this.router.events.subscribe(() => {
            const currentRoute = this.router.url;
            this.showChat = !(currentRoute.includes('/login') || currentRoute.includes('/register'));
        });
    }

    @HostListener('window:beforeunload')
    async removeToken() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        await this.authService.logout();
    }

    async ngOnDestroy() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        await this.authService.logout();
    }
}
