import {Component, inject, OnInit} from '@angular/core';
import {AuthService} from "@app/services/auth.service/auth.service";
import {FormBuilder, FormGroup, Validators, AbstractControl} from '@angular/forms';
import {Router} from "@angular/router";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {AvatarService} from "@app/services/avatar.service/avatar.service";
import {TranslateService} from "@ngx-translate/core";

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
    language: string;

    private authService = inject(AuthService);
    private snackbarService = inject(SnackbarService);
    private avatarService = inject(AvatarService)
    private fb = inject(FormBuilder);
    private router = inject(Router);
    private translate = inject(TranslateService)
    isLogging: boolean = false;
    constructor() {
        this.authForm = this.fb.group({
            username: ['', [Validators.required, this.usernameValidator, Validators.maxLength(10)]],
            email: ['', [Validators.required, Validators.email]],
            password: ['', [Validators.required, Validators.minLength(6)]],
        });
        this.language = this.translate.currentLang;
    }


    ngOnInit(): void {
        this.avatarService.getDefaultAvatarUrls().subscribe((urls: string[]) => {
            this.defaultAvatars = urls;
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


    async register(): Promise<void> {
        if (this.authForm.valid && this.selectedAvatar !== null) {
            this.isLogging = true;
            const { username, email, password } = this.authForm.value;
            try {
                await this.authService.register(username, email, password, this.selectedAvatar);
                this.snackbarService.show(this.translate.instant('REGISTER_PAGE.SUCCESS_REGISTER_POPUP'));
                this.router.navigate(['/home']);
            } catch (error: any) {
                this.snackbarService.show(error.message);
            } finally {
                this.isLogging = false;
            }
        }
    }

    switchLanguage(event: Event) {
        const language = (event.target as HTMLSelectElement).value;
        this.translate.use(language);
    }
}
