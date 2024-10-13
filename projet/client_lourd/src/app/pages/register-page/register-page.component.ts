import {Component, inject, OnInit} from '@angular/core';
import {AuthService} from "@app/services/auth.service/auth.service";
import {FormBuilder, FormGroup, Validators, AbstractControl} from '@angular/forms';
import {Router} from "@angular/router";
import {catchError, Observable, of, switchMap} from "rxjs";
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
        if (control.value && !usernameRegex.test(control.value)) {
            return {invalidUsername: true};
        }
        return null;
    }

    onAvatarSelected(avatar: string | File): void {
        console.log(typeof avatar)
        this.selectedAvatar = avatar; //(URL (defaultavatar) or File (uploaded)
    }

    ngOnInit(): void {
        this.avatarService.getDefaultAvatarUrls().subscribe((urls: string[]) => {
            this.defaultAvatars = urls;
            console.log(this.defaultAvatars);
        });
    }

    register() {
        if (this.authForm.valid && this.selectedAvatar !== null) {
            const { username, email, password } = this.authForm.value;

            this.authService
                .register(username, email, password)
                .pipe(
                    // After successful registration, add the user to Firestore
                    switchMap(({ user: { uid } }) =>
                        this.usersService.addUser({ uid, email, username }).pipe(
                            // Once the user is added, handle the avatar
                            switchMap(() => this.handleAvatar(uid))
                        )
                    ),
                    catchError((err) => {
                        console.log(err);
                        this.snackbarService.show(err.message || 'An error occurred');
                        return of(null);
                    })
                )
                .subscribe((result) => {
                    if (result !== null) {
                        this.snackbarService.show('Compte créé');
                        this.router.navigate(['/login']);
                    }
                });
        }
    }

    handleAvatar(uid: string): Observable<void> {
        if (typeof this.selectedAvatar === 'string') {
            console.log("1")
            return this.usersService.updateUserAvatar(uid, this.selectedAvatar);
        } else  { //File type
            return this.avatarService.uploadAvatar(uid, this.selectedAvatar as File).pipe(
                switchMap((avatarUrl) => this.usersService.updateUserAvatar(uid, avatarUrl))
            );
        }
    }
}
