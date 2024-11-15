import {Component, ViewEncapsulation} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {AuthService} from "@app/services/auth.service/auth.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {Router} from "@angular/router";
import {TranslateService} from "@ngx-translate/core";


@Component({
    selector: 'app-login.page',
    templateUrl: './login-page.component.html',
    styleUrls: ['./login-page.component.scss'],
    encapsulation: ViewEncapsulation.None
})
export class LoginPageComponent {
    authForm: FormGroup;
    passwordVisible: boolean = false;
    language: string;
    constructor(
        private fb: FormBuilder,
        private authService: AuthService,
        private snackbarService: SnackbarService,
        private router: Router,
        private translate: TranslateService) {
        this.authForm = this.fb.group({
            email: ['', [Validators.required, Validators.pattern('^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$')]],
            password: ['', [Validators.required,Validators.minLength(6)]]
        });
        this.language = this.translate.currentLang;
    }

    async login() {
        const { email, password } = this.authForm.value;
        if (this.authForm.valid) {
            try {
                await this.authService.login(email, password);
                this.snackbarService.show('Connexion réussie');
                this.router.navigate(['/home']);
            } catch (error:any) {
                this.snackbarService.show(error.message || 'Erreur lors de la connexion');
            }
        }
    }

    togglePasswordVisibility() {
        this.passwordVisible = !this.passwordVisible;
    }

    switchLanguage(event: Event) {
        const language = (event.target as HTMLSelectElement).value;
        this.translate.use(language);
    }
}
