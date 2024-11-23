import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialogRef } from '@angular/material/dialog';
import { UsersService } from '@app/services/users.service/users.service';
import { SnackbarService } from '@app/services/snackbar.service/snack-bar.service';
import { TranslateService } from '@ngx-translate/core';

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

    usernameForm: FormGroup;

    constructor(private fb: FormBuilder) {
        this.usernameForm = this.fb.group({
            username: [
                '',
                [
                    Validators.required,
                    Validators.maxLength(10),
                    Validators.pattern(/^[a-zA-Z0-9]+$/)
                ]
            ]
        });
    }

    cancel() {
        this.dialogRef.close();
    }

    async confirm() {
        if (this.usernameForm.invalid) return;

        const newUsername = this.usernameForm.value.username;

        try {
            await this.usersService.updateUsername(newUsername);
            this.snackbar.show(await this.translate.get('USERNAME_MODIFICATION.SUCCESSFUL_MODIFICATION').toPromise());
            this.dialogRef.close({ updatedUsername: newUsername });
        } catch (error: any) {
            this.snackbar.show(error.message);
        }
    }
}
