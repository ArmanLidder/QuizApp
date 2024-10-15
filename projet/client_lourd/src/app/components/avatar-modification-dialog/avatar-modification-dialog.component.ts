import {Component, inject} from '@angular/core';
import { MatDialogRef} from "@angular/material/dialog";
import {AvatarService} from "@app/services/avatar.service/avatar.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";

@Component({
  selector: 'app-avatar-modification-dialog',
  templateUrl: './avatar-modification-dialog.component.html',
  styleUrls: ['./avatar-modification-dialog.component.scss']
})
export class AvatarModificationDialogComponent {
  readonly dialogRef = inject(MatDialogRef<AvatarModificationDialogComponent>)
  private avatarService = inject(AvatarService);
  private snackbar = inject(SnackbarService);
  public isUploading: boolean = false;

  selectedAvatar: string | File | null = null;

  onAvatarSelected(avatar: string | File): void {
    this.selectedAvatar = avatar;
  }

  cancel() {
    this.dialogRef.close();
  }

  async confirm() {
    if (this.selectedAvatar) {
      try {
        this.isUploading = true;
        await this.avatarService.handleAvatarModification(this.selectedAvatar);
        this.snackbar.show('Avatar modifié avec succès');
      } catch {
        this.snackbar.show('Erreur de modification');
      } finally {
        this.isUploading = false;
      }
    }
    this.dialogRef.close();
  }
}
