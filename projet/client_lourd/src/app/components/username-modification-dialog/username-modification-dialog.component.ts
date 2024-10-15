import { Component, inject } from '@angular/core';
import { MatDialogRef } from "@angular/material/dialog";
import { UsersService } from "@app/services/users.service/users.service";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";

@Component({
    selector: 'app-username-modification-dialog',
    templateUrl: './username-modification-dialog.component.html',
    styleUrls: ['./username-modification-dialog.component.scss']
})
export class UsernameModificationDialogComponent {
    readonly dialogRef = inject(MatDialogRef<UsernameModificationDialogComponent>);
    private usersService = inject(UsersService);
    private snackbar = inject(SnackbarService);

    newUsername: string = '';
    isSubmitting: boolean = false;

    cancel() {
        this.dialogRef.close();
    }

    async confirm() {
        if (!this.newUsername) return;

        const usernameRegex = /^[a-zA-Z0-9]+$/;
        if (!usernameRegex.test(this.newUsername)) {
            this.snackbar.show("Le nom d'utilisateur ne peut contenir que des lettres et des chiffres.");
            this.newUsername = '';
            return;
        }

        this.isSubmitting = true;
        try {
            await this.usersService.updateUsername(this.newUsername); // Call the service to update the username
            this.snackbar.show('Nom d’utilisateur modifié avec succès');
            this.dialogRef.close({ updatedUsername: this.newUsername });
        } catch (error:any) {
            this.snackbar.show(error.message);
        } finally {
            this.isSubmitting = false;
        }
    }
}
