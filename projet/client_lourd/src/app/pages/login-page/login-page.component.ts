import {Component, OnInit} from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from "@angular/material/snack-bar";
import { Router } from '@angular/router';
import {AuthService} from "@app/services/auth.service/auth.service";

@Component({
  selector: 'app-login.page',
  templateUrl: './login-page.component.html',
  styleUrls: ['./login-page.component.scss']
})
export class LoginPageComponent implements OnInit {
  authForm: FormGroup;

  constructor(private fb: FormBuilder, private authService: AuthService, private snackBar: MatSnackBar, private router: Router) {
    this.authForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }
  ngOnInit(): void {
    // Check if token exists and redirect to chatroom if already logged in
    // if (localStorage.getItem('token')) {
    //   this.router.navigate(['chatroom']);
    // }
    console.log("hi")
  }

  login() {
    if (this.authForm.valid) {
      const loginData = this.authForm.value;
      this.authService.login(loginData).subscribe(
          (res) => {
            this.snackBar.open("Connexion réussie", 'Fermer', {
              duration: 2500,
              verticalPosition: 'bottom',
              horizontalPosition: 'center',
              panelClass : "my-snack-bar",
            });
            this.router.navigate(['/home']);
          },
          (err) => {
            console.log(err)
            this.snackBar.open(err.error.msg, 'Fermer', {
              duration: 2500,
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
