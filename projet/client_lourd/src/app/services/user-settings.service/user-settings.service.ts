import {Injectable} from '@angular/core';
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
  currentTheme: Observable<string>;
  activeTheme: string = 'theme-default';

  constructor(private userService: UsersService,private translate: TranslateService) {
    this.currentLanguage = this.getCurrentLanguage().pipe(
        map((language) => language || 'fr')
    );
    this.currentTheme = this.getCurrentTheme().pipe(
        map((theme) => theme || 'light')
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

  async switchTheme(theme: string) {
    const currentUser: User|null = await firstValueFrom(this.userService.currentUserProfile$);
    if (currentUser) {
      this.setTheme(theme);
      await this.userService.updateUser({
        settings: {
          ...currentUser.settings,
          theme
        }
      });
    }
  }

  setTheme(theme: string): void {
    const className = `theme-${theme}`;
    document.documentElement.classList.remove(this.activeTheme);
    this.activeTheme = className;
    document.documentElement.classList.add(this.activeTheme);
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

  getCurrentTheme(): Observable<string | undefined> {
    return this.userService.currentUserProfile$.pipe(
        map(user => user?.settings.theme)
    );
  }
}
