import { Injectable } from '@angular/core';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material/snack-bar';

@Injectable({
  providedIn: 'root',
})
export class SnackbarService {
  constructor(private snackBar: MatSnackBar) {}

  show(message: string, action: string = 'Fermer', config: MatSnackBarConfig = {}) {
    this.snackBar.open(message, action, {
      duration: 5000, // default duration
      verticalPosition: 'bottom',
      horizontalPosition: 'center',
      // panelClass: ['my-snack-bar'],
      ...config, // additional config if you need
    });
  }
}
