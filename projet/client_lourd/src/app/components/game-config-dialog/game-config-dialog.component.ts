import {Component} from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { GameConfigService } from '@app/services/game-config.service/game-config.service';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-game-config-dialog',
  templateUrl: './game-config-dialog.component.html',
  styleUrls: ['./game-config-dialog.component.scss']
})
export class GameConfigDialogComponent {
  gameConfigForm: FormGroup;

  constructor(
      public dialogRef: MatDialogRef<GameConfigDialogComponent>,
      private fb: FormBuilder,
      private gameConfigService: GameConfigService
  ) {
    // Initialize the form with the current config values or defaults
    this.gameConfigForm = this.fb.group({
      gameType: ['', Validators.required],
      price: [0, [Validators.required, Validators.min(0), Validators.pattern(/^[0-9]\d*$/)]],
      friendsOnly: [false],
      private: [false]
    });
  }

  // Submit form and send data to the service
  saveConfig(): void {
    if (this.gameConfigForm.valid) {
      const { gameType, price, friendsOnly, private: isPrivate } = this.gameConfigForm.value;
      console.log({ gameType, price, friendsOnly, private: isPrivate });
      this.gameConfigService.setGameType(gameType);
      this.gameConfigService.setPrice(price);
      this.gameConfigService.setFriendsOnly(friendsOnly);
      this.gameConfigService.setPrivacy(isPrivate);
      this.dialogRef.close(true);
    }
  }

  // Close dialog without saving
  closeDialog(): void {
    this.dialogRef.close();
  }
}
