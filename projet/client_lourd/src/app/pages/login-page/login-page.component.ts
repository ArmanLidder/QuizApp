import {Component} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {AuthService} from "@app/services/auth.service/auth.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {catchError, of} from "rxjs";
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

    login() {
        const { email, password } = this.authForm.value;
        if (this.authForm.valid) {
            this.authService.login(email, password).pipe(
                catchError((err) => {
                    this.snackbarService.show(err.message || 'Courriel et/ou mot de passe incorrect');
                    return of(null); // Return a null observable to ensure the subscription can continue without crashing
                })
            ).subscribe(result => {
                if (result !== null) { // Ensure result is not null (successful login)
                    this.snackbarService.show('Connexion réussie');
                    this.router.navigate(['/home']); // Navigate to the home page after successful login
                }
            });
        }
    }
}
