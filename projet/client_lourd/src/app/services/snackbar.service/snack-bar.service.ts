import { Injectable } from '@angular/core';
import { MatSnackBar, MatSnackBarConfig } from '@angular/material/snack-bar';
import {TranslateService} from "@ngx-translate/core";

@Injectable({
  providedIn: 'root',
})
export class SnackbarService {
  constructor(private snackBar: MatSnackBar,private translate: TranslateService) {}

  show(message: string, action: string = this.translate.instant('POP_UP_MESSAGE.CLOSE'), config: MatSnackBarConfig = {}) {
    this.snackBar.open(message, action, {
      duration: 5000, // default duration
      verticalPosition: 'bottom',
      horizontalPosition: 'center',
      // panelClass: ['my-snack-bar'],
      ...config,
    });
  }
}
