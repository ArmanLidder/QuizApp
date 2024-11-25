import { Component, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { UserSettingsService } from '@app/services/user-settings.service/user-settings.service';
import { Observable } from 'rxjs';
import {TranslateService} from "@ngx-translate/core";

@Component({
  selector: 'app-settings-dialog',
  templateUrl: './settings-dialog.component.html',
  styleUrls: ['./settings-dialog.component.scss']
})
export class SettingsDialogComponent implements OnInit {
  currentLanguage: 'fr' | 'en';
  currentTheme: string;
  availableThemes$: Observable<{ name: string; source: string | null }[]>;

  constructor(
      public dialogRef: MatDialogRef<SettingsDialogComponent>,
      private settings: UserSettingsService,
      public translate: TranslateService
  ) {}

  async ngOnInit() {
    this.settings.currentLanguage.subscribe((language) => {
      this.currentLanguage = language;
    });
    this.settings.currentTheme.subscribe((theme) => {
      this.currentTheme = theme;
    });
    this.availableThemes$ = this.settings.availableThemes$;
  }

  async switchLanguage(event: Event) {
    const language = (event.target as HTMLSelectElement).value;
    await this.settings.switchLanguage(language as 'en' | 'fr');
  }

  async switchTheme(name: string) {
    await this.settings.switchTheme(name);
  }

  getThemeCircleColor(name: string, source: string | null): string {
    if (name === 'light') return 'white';
    if (name === 'dark') return 'black';
    return source ? `url(${source})` : 'transparent'; // Fallback for other themes
  }
}
