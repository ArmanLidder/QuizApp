import { Component, HostListener } from '@angular/core';
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";
import {UsersService} from "@app/services/users.service/users.service";

@Component({
    selector: 'app-main-page',
    templateUrl: './main-page.component.html',
    styleUrls: ['./main-page.component.scss'],
})
export class MainPageComponent {
    readonly title: string = 'Polyquiz';
    username: string;
    constructor(private socketService: SocketClientService, public usersService: UsersService) {
        this.usersService.currentUserProfile$.subscribe((user)=>{
            this.username = user?.username!;
        })

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
