import {Component, inject, OnInit} from '@angular/core';
import {AuthService} from "@app/services/auth.service/auth.service";
import {FormBuilder, FormGroup, Validators, AbstractControl} from '@angular/forms';
import {Router} from "@angular/router";
import { firstValueFrom} from "rxjs";
import {UsersService} from "@app/services/users.service/users.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {AvatarService} from "@app/services/avatar.service/avatar.service";

@Component({
    selector: 'app-register-page',
    templateUrl: './register-page.component.html',
    styleUrls: ['./register-page.component.scss']
})
export class RegisterPageComponent implements OnInit {
    authForm: FormGroup;
    defaultAvatars: string[] = [];
    passwordVisible: boolean = false;
    selectedAvatar: string | File | null = null;


    private usersService = inject(UsersService);
    private authService = inject(AuthService);
    private snackbarService = inject(SnackbarService);
    private avatarService = inject(AvatarService)
    private fb = inject(FormBuilder);
    private router = inject(Router);

    constructor() {
        this.authForm = this.fb.group({
            username: ['', [Validators.required, this.usernameValidator]],
            email: ['', [Validators.required, Validators.pattern('^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$')]],
            password: ['', [Validators.required, Validators.minLength(6)]],
        });
    }

    togglePasswordVisibility() {
        this.passwordVisible = !this.passwordVisible;
    }

    usernameValidator(control: AbstractControl): { [key: string]: boolean } | null {
        const usernameRegex = /^[a-zA-Z0-9]+$/;
        if (control.value && !usernameRegex.test(control.value)) return {invalidUsername: true};
        return null;
    }

    onAvatarSelected(avatar: string | File): void {
        this.selectedAvatar = avatar;
    }

    ngOnInit(): void {
        this.avatarService.getDefaultAvatarUrls().subscribe((urls: string[]) => {
            this.defaultAvatars = urls;
        });
    }

    async register(): Promise<void> {
        if (this.authForm.valid && this.selectedAvatar !== null) {
            const { username, email, password } = this.authForm.value;
            try {
                const { user } = await this.authService.register(username, email, password);

                await this.usersService.addUser({ uid: user.uid, email, username });

                await this.handleAvatar(user.uid);

                this.snackbarService.show('Compte créé');
                this.router.navigate(['/login']);

            } catch (error: any) {
                console.log(error);
                this.snackbarService.show(error.message || 'Une erreur est survenue');
            }
        }
    }


    async handleAvatar(uid: string): Promise<void> {
        if (typeof this.selectedAvatar === 'string') {
            await this.usersService.updateUserAvatar(uid, this.selectedAvatar);
        } else if (this.selectedAvatar instanceof File) {
            const avatarUrl = await firstValueFrom(this.avatarService.uploadAvatar(uid, this.selectedAvatar));
            await this.usersService.updateUserAvatar(uid, avatarUrl);
        } else {
            this.snackbarService.show('Aucun avatar sélectionné');
        }
    }
}
