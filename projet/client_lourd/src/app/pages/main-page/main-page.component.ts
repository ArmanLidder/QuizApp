import { Component, HostListener } from '@angular/core';
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";
import {UsersService} from "@app/services/users.service/users.service";
import {UserSettingsService} from "@app/services/user-settings.service/user-settings.service";

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent {
    readonly title: string = 'Polyquiz';
    username: string;
    constructor(private socketService: SocketClientService, public usersService: UsersService, private settings: UserSettingsService) {
        this.usersService.currentUserProfile$.subscribe((user)=>{
            this.username = user?.username!;
        })

        window.onload = () => {
            localStorage.removeItem('token');
            this.socketService.disconnect();
        }

        this.settings.setTranslationListener();
    }

    @HostListener('window:beforeunload')
    removeToken() {
        localStorage.removeItem('token');
        this.socketService.disconnect();
    }

}
