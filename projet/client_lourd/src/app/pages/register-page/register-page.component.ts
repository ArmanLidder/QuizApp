import { Component, OnInit } from '@angular/core';
import { AuthService } from "@app/services/auth.service/auth.service";
import { FormBuilder, FormGroup, Validators, AbstractControl} from '@angular/forms';
import { MatSnackBar } from "@angular/material/snack-bar";
import { AvatarService } from "@app/services/avatar.service/avatar.service";
import { environment } from "../../../environments/environment";
import {Router} from "@angular/router";


interface AvatarData {
    name: string,
    url: string,
}

@Component({
    selector: 'app-register-page',
    templateUrl: './register-page.component.html',
    styleUrls: ['./register-page.component.scss']
})
export class RegisterPageComponent implements OnInit {
    authForm: FormGroup;
    defaultAvatars: AvatarData[] = [];
    selectedAvatar: AvatarData;
    selectedAvatarIndex: number | null = null;
    customAvatarUrl: string | ArrayBuffer | null = null;
    passwordVisible: boolean = false;

    constructor(private fb: FormBuilder, private authService: AuthService, private snackBar: MatSnackBar, private avatarService: AvatarService, private router: Router) {
        this.authForm = this.fb.group({
            username: ['', [Validators.required,this.usernameValidator]],
            email: ['', [Validators.required, Validators.pattern('^[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,4}$')]],
            password: ['', Validators.required],
            avatar: [null],
        });
    }

    togglePasswordVisibility() {
        this.passwordVisible = !this.passwordVisible;
    }

    usernameValidator(control: AbstractControl): { [key: string]: boolean } | null {
        const usernameRegex = /^[a-zA-Z0-9]+$/;
        if (control.value && !usernameRegex.test(control.value)) {
            return { invalidUsername: true };
        }
        return null;
    }

    selectAvatar(index: number) {
        if (index == -1) {
            this.selectedAvatarIndex = null;
            return;
        }
        this.selectedAvatar = this.defaultAvatars[index];
        this.selectedAvatarIndex = index;
        this.authForm.patchValue({ avatar: this.selectedAvatar.name });
    }

    onFileSelected(event: Event) {
        const file = (event.target as HTMLInputElement).files?.[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                this.customAvatarUrl = e.target?.result as string;
                this.selectedAvatarIndex = null;
                this.authForm.patchValue({ avatar: file });
            };
            reader.readAsDataURL(file);
        }
    }

    ngOnInit() {
        this.avatarService.getDefaultAvatars().subscribe(
            (res: any) => {
                for (let avatar of res.defaultAvatars) {
                    this.defaultAvatars.push({
                        name: avatar,
                        url: `${environment.serverUrl}/images/${avatar}`
                    });
                }
            },
            (error: Error) => {
                console.error('Error fetching avatars:', error);
            }
        );
    }

    register() {
        if (!this.selectedAvatar && !this.customAvatarUrl) {
            this.snackBar.open('Aucun avatar sélectionné', 'Fermer', {
                duration: 5000,
                verticalPosition: 'bottom',
                horizontalPosition: 'center',
                panelClass: "my-snack-bar",
            });
            return;
        }
        if (this.authForm.valid) {
            const formData = new FormData();

            formData.set('username', this.authForm.controls['username'].value);
            formData.set('email', this.authForm.controls['email'].value);
            formData.set('password', this.authForm.controls['password'].value);
            if (this.customAvatarUrl && this.authForm.controls['avatar'].value instanceof File) {
                formData.set('file', this.authForm.controls['avatar'].value);
                const file = this.authForm.controls['avatar'].value;
                const fileExt = file.name.split('.').pop();
                const fileName = this.authForm.controls['username'].value + '.' + fileExt
                formData.set('avatar', fileName);
                this.authForm.patchValue({ avatar: fileName });
            } else {
                formData.set('avatar', this.authForm.controls['avatar'].value)
            }

            this.authService.register(formData).subscribe(
                () => {
                    this.snackBar.open("Compte crée", 'Fermer', {
                        duration: 5000,
                        verticalPosition: 'bottom',
                        horizontalPosition: 'center',
                        panelClass: "my-snack-bar",
                    });
                    this.router.navigate(['/login']);
                },
                (err: { error: { msg: string; }; }) => {
                    console.log(err);
                    this.snackBar.open(err.error.msg, 'Fermer', {
                        duration: 5000,
                        verticalPosition: 'bottom',
                        horizontalPosition: 'center',
                        panelClass: "my-snack-bar",
                    });
                }
            );
        } else {
            console.log('Form is invalid');
        }
    }
}
