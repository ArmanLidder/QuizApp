import {Component, OnInit} from '@angular/core';
import { AuthService } from "../../services/auth.service";
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatSnackBar } from "@angular/material/snack-bar";
import {SocketService} from "../../services/socket.service";
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  authForm: FormGroup;

  constructor(private fb: FormBuilder, private authService: AuthService, private snackBar: MatSnackBar, private socketService: SocketService, private router: Router) {
    this.authForm = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }
  ngOnInit(): void {
    // Check if token exists and redirect to chatroom if already logged in
    if (localStorage.getItem('token')) {
      this.router.navigate(['chatroom']);
    }
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
          this.router.navigate(['chatroom']);
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
