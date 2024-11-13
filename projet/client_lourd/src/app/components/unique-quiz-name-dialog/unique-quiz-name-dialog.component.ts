import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-unique-quiz-name-dialog',
  templateUrl: './unique-quiz-name-dialog.component.html',
  styleUrls: ['./unique-quiz-name-dialog.component.scss'],
})
export class UniqueQuizNameDialogComponent {
  newQuizName: string = this.data.quizName;
  nameError: string | null = null;
  constructor(
      public dialogRef: MatDialogRef<UniqueQuizNameDialogComponent>,
      @Inject(MAT_DIALOG_DATA) public data: { quizName: string }
  ) {}

  onConfirmClick(): void {
    if (this.isValidName()) {
      this.dialogRef.close(this.newQuizName.trim());
    }
  }

  onCloseClick(): void {
    this.dialogRef.close(null);
  }

  isValidName(): boolean {
    if (!this.newQuizName.trim()) {
      this.nameError = 'Le nom ne doit pas être vide ou composé uniquement d\'espaces.';
      return false;
    }

    if (this.newQuizName.length > 100) {
      this.nameError = 'Le nom ne doit pas dépasser 100 caractères.';
      return false;
    }

    this.nameError = null;
    return true;
  }
}
