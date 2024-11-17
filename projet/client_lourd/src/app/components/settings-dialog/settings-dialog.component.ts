import {Component, OnInit,} from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import {UserSettingsService} from "@app/services/user-settings.service/user-settings.service";
import {UsersService} from "@app/services/users.service/users.service";

@Component({
  selector: 'app-settings-dialog',
  templateUrl: './settings-dialog.component.html',
  styleUrls: ['./settings-dialog.component.scss']
})
export class SettingsDialogComponent implements OnInit{
  currentLanguage: 'fr' | 'en';
  currentTheme: string;
  availableThemes: string[];

  constructor(
      public dialogRef: MatDialogRef<SettingsDialogComponent>,
      private settings: UserSettingsService,
      private usersService: UsersService,
  ) {}

  async ngOnInit() {
    this.settings.currentLanguage.subscribe((language) => {
      this.currentLanguage = language;
    });
    this.settings.currentTheme.subscribe((theme) => {
      this.currentTheme = theme;
    });
    this.availableThemes = await this.usersService.getAvailableThemes();
  }

  async switchLanguage(event: Event) {
    const language = (event.target as HTMLSelectElement).value;
    await this.settings.switchLanguage(language as 'en'|'fr');
  }

  async switchTheme(event: Event) {
    const theme = (event.target as HTMLSelectElement).value;
    await this.settings.switchTheme(theme);
  }
}
