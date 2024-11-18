import { Component, Input } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ConfirmationDialogComponent } from '@app/components/confirmation-dialog/confirmation-dialog.component';
import { PopUpMessage } from '@common/browser-message/displayable-message/pop-up-message';
import { HOME_PAGE } from '@common/page-url/page-url';
import {TranslateService} from "@ngx-translate/core";
import {GameService} from "@app/services/game.service/game.service";
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
@Component({
    selector: 'app-leave-boutton',
    templateUrl: './leave-boutton.component.html',
    styleUrls: ['./leave-boutton.component.scss'],
})
export class LeaveButtonComponent {
    @Input() isGame: boolean = true;
    constructor(
        private gameService: GameService,
        private socketService: SocketClientService,
        private dialog: MatDialog,
        private router: Router,
        private translate: TranslateService
    ) {}
    @Input() action: () => void = async () => this.router.navigate([`./${HOME_PAGE}`]);
    async openConfirmationDialog() {
        const messageKey = this.isGame ? PopUpMessage.LEAVE_MESSAGE : PopUpMessage.DELETE_MESSAGE;
        console.log('Popout window', this.gameService.observerMode, this.gameService.observedPlayerId);
        const observerMode = this.gameService.observerMode;

        // Fetch the translated message based on the key
        const message = await this.translate.get(messageKey).toPromise();
        const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
            width: '300px',
            data: { message },
        });

        dialogRef.afterClosed().subscribe((result) => {
            if (result) {
                if (observerMode)
                    this.socketService.send(SocketEvent.OBS_LEFT, {roomId: this.gameService.gameRealService.roomId, observedId: this.gameService.observedPlayerId});
                this.action();
            }
        });
    }
}
