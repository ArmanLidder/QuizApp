import {Component, Input, OnInit} from '@angular/core';
import {UsersService} from "@app/services/users.service/users.service";
import {FriendsComponent} from "@app/components/friends/friends.component";
import {MatDialog} from "@angular/material/dialog";
import {FriendService} from "@app/services/friend.service/friend.service";
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {UserSettingsService} from "@app/services/user-settings.service/user-settings.service";
import {SettingsDialogComponent} from "@app/components/settings-dialog/settings-dialog.component";
import {Router} from "@angular/router";
import {ConfirmationDialogComponent} from "@app/components/confirmation-dialog/confirmation-dialog.component";
import {TranslateService} from "@ngx-translate/core";
import {PopUpMessage} from "@common/browser-message/displayable-message/pop-up-message";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {GameService} from "@app/services/game.service/game.service";
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";


@Component({
    selector: 'app-header', templateUrl: './header.component.html', styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
    @Input() showMenu = true;
    @Input() observerMode = false;
    @Input() normalPlayer = false;
    @Input() showWarningPopUpOnLeave = false;

    currentUser$: Observable<User | null>
    pendingRequests$: Observable<User[]>;
    currentLanguage: 'fr' | 'en';

    constructor(public usersService: UsersService,
                private dialog: MatDialog,
                public friendsService: FriendService, private settings: UserSettingsService, private router: Router, private translate: TranslateService,
                private gameService: GameService,
                private socketService: SocketClientService,) {
    }

    ngOnInit() {
        this.currentUser$ = this.usersService.currentUserProfile$;
        this.pendingRequests$ = this.friendsService.friendRequests$;

        this.settings.currentLanguage.subscribe((language) => {
            this.currentLanguage = language;
        });
    }

    openFriendsDialog(): void {
        this.dialog.open(FriendsComponent, {
            width: '35%', height: '375px',
        });
    }

    openSettingsDialog() {
        this.dialog.open(SettingsDialogComponent, {
            width: '500px',
            height: '250px',
            panelClass: 'settingsDialogClass'
        });
    }
    async navigateToHome() {
        if (this.showWarningPopUpOnLeave) {
            const message = await this.translate.get(PopUpMessage.LEAVE_MESSAGE).toPromise();
            const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
                width: '300px',
                data: { message },
            });
            dialogRef.afterClosed().subscribe((result) => {
                if (result) {
                    const observerMode = this.gameService.observerMode;
                    if (observerMode)
                        this.socketService.send(SocketEvent.OBS_LEFT, {roomId: this.gameService.gameRealService.roomId, observedId: this.gameService.observedPlayerId});
                    this.router.navigate(['/home']);
                }
            });
        }
        else if (this.showMenu) {
            this.router.navigate(['/home']);
        }
    }
}
