import { Component, inject } from '@angular/core';
import { MatDialogRef } from "@angular/material/dialog";
import { UsersService } from "@app/services/users.service/users.service";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-username-modification-dialog',
    templateUrl: './username-modification-dialog.component.html',
    styleUrls: ['./username-modification-dialog.component.scss']
})
export class UsernameModificationDialogComponent {
    readonly dialogRef = inject(MatDialogRef<UsernameModificationDialogComponent>);
    private usersService = inject(UsersService);
    private snackbar = inject(SnackbarService);
    private translate = inject(TranslateService);
    newUsername: string = '';

    cancel() {
        this.dialogRef.close();
    }

    async confirm() {
        if (!this.newUsername) return;

        const usernameRegex = /^[a-zA-Z0-9]+$/;
        if (!usernameRegex.test(this.newUsername)) {
            this.snackbar.show(await this.translate.get('USERNAME_MODIFICATION.LETTERS_NUMBERS_ONLY').toPromise());
            this.newUsername = '';
            return;
        }

        if (this.newUsername.length>10) {
            this.snackbar.show(await this.translate.get('USERNAME_MODIFICATION.MAXIMUM_10_CHAR').toPromise());
            this.newUsername = '';
            return;
        }

        try {
            await this.usersService.updateUsername(this.newUsername);
            this.snackbar.show(await this.translate.get('USERNAME_MODIFICATION.SUCCESSFUL_MODIFICATION').toPromise());
            this.dialogRef.close({ updatedUsername: this.newUsername });
            return;
        } catch (error:any) {
            this.snackbar.show(error.message);
            return;
        }
    }
}
