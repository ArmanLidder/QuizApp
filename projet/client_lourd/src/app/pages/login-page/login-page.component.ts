import {Component} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {AuthService} from "@app/services/auth.service/auth.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {Router} from "@angular/router";


@Component({
    selector: 'app-login.page',
    templateUrl: './login-page.component.html',
    styleUrls: ['./login-page.component.scss']
})
export class LoginPageComponent {
    authForm: FormGroup;

    constructor(
        private fb: FormBuilder,
        private authService: AuthService,
        private snackbarService: SnackbarService,
        private router: Router) {
        this.authForm = this.fb.group({
            email: ['', Validators.required],
            password: ['', Validators.required]
        });
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

}
