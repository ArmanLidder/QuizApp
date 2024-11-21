import { Injectable } from '@angular/core';
import { UsersService } from '@app/services/users.service/users.service';
import { firstValueFrom, from, Observable, of, switchMap} from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { TranslateService } from '@ngx-translate/core';
import { collection, doc, getDoc, getDocs, Firestore } from '@angular/fire/firestore';
import { StoreItem } from '@common/interfaces/store.interface';
import {User} from "@common/interfaces/user-data.interface";

@Injectable({
  providedIn: 'root',
})
export class UserSettingsService {
  currentLanguage: Observable<'en' | 'fr'>;
  currentTheme: Observable<string>;
  activeTheme: string = 'theme-light';
  availableThemes$: Observable<string[]>; // Cached observable for available themes

  constructor(private firestore: Firestore, private userService: UsersService, private translate: TranslateService) {
    this.currentLanguage = this.getCurrentLanguage().pipe(
        map((language) => language || 'fr')
    );
    this.currentTheme = this.getCurrentTheme().pipe(
        map((theme) => theme || 'light')
    );
    this.currentTheme.subscribe((theme) => {
      this.setTheme(theme);
    });

    // Initialize the cached available themes observable
    this.availableThemes$ = this.createAvailableThemesObservable();
  }


  async switchLanguage(language: 'en' | 'fr') {
    const currentUser: User | null = await firstValueFrom(this.userService.currentUserProfile$);

    if (currentUser) {
      await this.userService.updateUser({
        settings: {
          ...currentUser.settings,
          language,
        },
      });
    }
  }

  async switchTheme(theme: string) {
    const currentUser: User | null = await firstValueFrom(this.userService.currentUserProfile$);
    if (currentUser) {
      this.setTheme(theme);
      await this.userService.updateUser({
        settings: {
          ...currentUser.settings,
          theme,
        },
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
    this.currentLanguage.subscribe((language) => {
      this.translate.use(language);
    });
  }

  getCurrentLanguage(): Observable<'en' | 'fr' | undefined> {
    return this.userService.currentUserProfile$.pipe(map((user) => user?.settings.language));
  }

  getCurrentTheme(): Observable<string | undefined> {
    return this.userService.currentUserProfile$.pipe(map((user) => user?.settings.theme));
  }

  private createAvailableThemesObservable(): Observable<string[]> {
    const defaultThemes = ['light', 'dark'];

    return this.userService.currentUserProfile$.pipe(
        switchMap((currentUser) => {
          if (!currentUser) return of(defaultThemes);

          const storeProfileRef = doc(this.firestore, 'storeProfiles', currentUser.uid);

          return from(getDoc(storeProfileRef)).pipe(
              switchMap((storeProfileSnapshot) => {
                if (!storeProfileSnapshot.exists()) return of(defaultThemes);

                const storeProfileData = storeProfileSnapshot.data() as { ownedItems: string[] };
                const ownedItemIds = storeProfileData.ownedItems || [];

                if (ownedItemIds.length === 0) return of(defaultThemes);

                const storeItemsRef = collection(this.firestore, 'storeItems');
                console.log('lots of reads');
                return from(getDocs(storeItemsRef)).pipe(
                    map((querySnapshot) => {
                      const ownedThemes = querySnapshot.docs
                          .filter((doc) => ownedItemIds.includes(doc.id))
                          .map((doc) => {
                            const data = doc.data() as StoreItem;
                            return data;
                          })
                          .filter((item) => item.itemType === 'theme' || item.itemType === 'rewardTheme')
                          .map((item) => item.name);

                      return Array.from(new Set([...defaultThemes, ...ownedThemes]));
                    })
                );
              })
          );
        }),
        shareReplay(1) // Cache the result and replay the last emitted value to new subscribers
    );
  }
}
