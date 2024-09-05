import { Component } from '@angular/core';
import { AuthService } from "../../services/auth.service";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from "@angular/material/snack-bar";

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  authForm: FormGroup;

  constructor(private fb: FormBuilder, private authService: AuthService, private snackBar: MatSnackBar) {
    this.authForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  login() {
    if (this.authForm.valid) {
      const loginData = this.authForm.value;
      this.authService.login(loginData).subscribe(
        (res) => {
          this.snackBar.open("Connexion réussie", 'Fermer', {
            duration: 5000,
            verticalPosition: 'bottom',
            horizontalPosition: 'center',
            panelClass : "my-snack-bar",
          });
        },
        (err) => {
          console.log(err)
          this.snackBar.open(err.error.msg, 'Fermer', {
            duration: 5000,
            verticalPosition: 'bottom',
            horizontalPosition: 'center',
            panelClass : "my-snack-bar",
          });
        }
      );
    } else {
      console.log('Form is invalid');
    }
  }
}
