import { Component } from '@angular/core';
import { AuthService } from "../../services/auth.service";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from "@angular/material/snack-bar";

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent {
  authForm: FormGroup;

  constructor(private fb: FormBuilder, private authService: AuthService, private snackBar: MatSnackBar) {
    this.authForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  register() {
    if (this.authForm.valid) {
      const loginData = this.authForm.value;
      this.authService.register(loginData).subscribe(
        (res) => {
          this.snackBar.open("Compte crée", 'Fermer', {
            duration: 5000,
            verticalPosition: 'bottom',
            horizontalPosition: 'center',
            panelClass : "my-snack-bar",
          });
        },
        (err) => {
          console.log(err)
          this.snackBar.open(`Erreur de création : ${err.statusText} (${err.status})`, 'Fermer', {
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
