import {Injectable} from '@angular/core';
import {UsersService} from '@app/services/users.service/users.service';
import {BehaviorSubject, firstValueFrom, from, Observable, of, switchMap, take, tap} from 'rxjs';
import {map} from 'rxjs/operators';
import {TranslateService} from '@ngx-translate/core';
import {collection, doc, getDoc, getDocs, Firestore} from '@angular/fire/firestore';
import {StoreItem} from '@common/interfaces/store.interface';
import {User} from "@common/interfaces/user-data.interface";

@Injectable({
    providedIn: 'root',
})
export class UserSettingsService {
    currentLanguage: Observable<'en' | 'fr'>;
    currentTheme: Observable<string>;
    activeTheme: string = 'theme-light';
    private availableThemesSubject: BehaviorSubject<{ name: string; source: string | null }[] | null> = new BehaviorSubject<{ name: string; source: string | null }[] | null>(null);

    availableThemes$: Observable<{ name: string; source: string | null }[]> = this.availableThemesSubject.asObservable().pipe(switchMap((cachedThemes) => {
        if (cachedThemes) return of(cachedThemes);
        return this.loadAvailableThemes().pipe(tap((themes) => this.availableThemesSubject.next(themes)));
    }));

    constructor(private firestore: Firestore, private userService: UsersService, private translate: TranslateService) {
        this.currentLanguage = this.getCurrentLanguage().pipe(map((language) => language || 'fr'));
        this.currentTheme = this.getCurrentTheme().pipe(map((theme) => theme || 'light'));
        this.currentTheme.subscribe((theme) => {
            this.setTheme(theme);
        });
    }

    resetStateVariables(): void {
        this.setTheme('light');
        this.availableThemesSubject.next(null);
    }

    async switchLanguage(language: 'en' | 'fr') {
        const currentUser: User | null = await firstValueFrom(this.userService.currentUserProfile$);

        if (currentUser) {
            await this.userService.updateUser({
                settings: {
                    ...currentUser.settings, language,
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
                    ...currentUser.settings, theme,
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

    loadAvailableThemes(): Observable<{ name: string; source: string | null }[]> {
        const defaultThemes = [{name: 'light', source: null}, {name: 'dark', source: null},];

        return this.userService.currentUserProfile$.pipe(take(1), // Only take the first emitted value to prevent repeated reads
            switchMap((currentUser) => {
                if (!currentUser) return of(defaultThemes);

                const storeProfileRef = doc(this.firestore, 'storeProfiles', currentUser.uid);

                return from(getDoc(storeProfileRef)).pipe(switchMap((storeProfileSnapshot) => {
                    if (!storeProfileSnapshot.exists()) return of(defaultThemes);

                    const storeProfileData = storeProfileSnapshot.data() as { ownedItems: string[] };
                    const ownedItemIds = storeProfileData.ownedItems || [];

                    if (ownedItemIds.length === 0) return of(defaultThemes);

                    const storeItemsRef = collection(this.firestore, 'storeItems');
                    return from(getDocs(storeItemsRef)).pipe(map((querySnapshot) => {
                        const ownedThemes = querySnapshot.docs
                            .filter((doc) => ownedItemIds.includes(doc.id))
                            .map((doc) => {
                                const data = doc.data() as StoreItem;
                                return data;
                            })
                            .filter((item) => item.itemType === 'theme' || item.itemType === 'rewardTheme')
                            .map((item) => ({
                                name: item.name, source: item.source || null,
                            }));
                        return [...defaultThemes, ...ownedThemes];
                    }));
                }));
            }));
    }


    async refreshAvailableThemes(): Promise<void> {
        const themes = await firstValueFrom(this.loadAvailableThemes());
        this.availableThemesSubject.next(themes);
    }
}
