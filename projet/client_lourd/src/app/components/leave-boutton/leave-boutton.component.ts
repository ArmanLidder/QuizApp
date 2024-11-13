import { Component, Input } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { ConfirmationDialogComponent } from '@app/components/confirmation-dialog/confirmation-dialog.component';
import { PopUpMessage } from '@common/browser-message/displayable-message/pop-up-message';
import { HOME_PAGE } from '@common/page-url/page-url';
import {TranslateService} from "@ngx-translate/core";
@Component({
    selector: 'app-leave-boutton',
    templateUrl: './leave-boutton.component.html',
    styleUrls: ['./leave-boutton.component.scss'],
})
export class LeaveButtonComponent {
    @Input() isGame: boolean = true;
    constructor(
        private dialog: MatDialog,
        private router: Router,
        private translate: TranslateService
    ) {}
    @Input() action: () => void = async () => this.router.navigate([`./${HOME_PAGE}`]);
    openConfirmationDialog(): void {
        const messageKey = this.isGame ? PopUpMessage.LEAVE_MESSAGE : PopUpMessage.DELETE_MESSAGE;

        // Fetch the translated message based on the key
        const message = this.translate.instant(messageKey);
        const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
            width: '300px',
            data: { message },
        });

        dialogRef.afterClosed().subscribe((result) => {
            if (result) {
                this.action();
            }
        });
    }
}
