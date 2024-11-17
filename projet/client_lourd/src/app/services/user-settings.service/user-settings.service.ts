import { Injectable } from '@angular/core';
import { UsersService } from '@app/services/users.service/users.service';
import {firstValueFrom, Observable} from 'rxjs';
import {User} from "@app/interfaces/user/user-data.interface";
import {map} from "rxjs/operators";
import {TranslateService} from "@ngx-translate/core";

@Injectable({
  providedIn: 'root'
})
export class UserSettingsService {
  currentLanguage: Observable<'en' | 'fr'>;

  constructor(private userService: UsersService,private translate: TranslateService) {
    this.currentLanguage = this.getCurrentLanguage().pipe(
        map((language) => language || 'fr')
    );
  }

  async switchLanguage(language: 'en' | 'fr') {
    const currentUser: User|null = await firstValueFrom(this.userService.currentUserProfile$);

    if (currentUser) {
      await this.userService.updateUser({
        settings: {
          ...currentUser.settings,
          language
        }
      });
    }
  }

  async switchTheme(theme: 'light' | 'dark') { //there will be more themes than light and dark, this is temporary
    const currentUser: User|null = await firstValueFrom(this.userService.currentUserProfile$);
    if (currentUser) {
      await this.userService.updateUser({
        settings: {
          ...currentUser.settings,
          theme
        }
      });
    }
  }

  setTranslationListener() {
    this.currentLanguage.subscribe(language => {
      this.translate.use(language);
    });
  }

  getCurrentLanguage(): Observable<'en' | 'fr' | undefined> {
    return this.userService.currentUserProfile$.pipe(
        map(user => user?.settings.language)
    );
  }

  async getCurrentTheme(): Promise<string | null> {
    const currentUser = await firstValueFrom(this.userService.currentUserProfile$);
    if (currentUser) return currentUser?.settings.theme;
    return null;
  }
}
