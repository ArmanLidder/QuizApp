import { Component, OnInit } from '@angular/core';
import { StoreService } from "@app/services/store.service/store.service";
import {Observable} from "rxjs";
import { StoreItem } from "@common/interfaces/store.interface";
import { map } from 'rxjs/operators';
import { UsersService } from "@app/services/users.service/users.service";
import { User } from "@common/interfaces/user-data.interface";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
import { TranslateService } from "@ngx-translate/core";

type StoreItemWithOwnership = StoreItem & { isOwned: boolean };

@Component({
  selector: 'app-shopping-page',
  templateUrl: './shopping-page.component.html',
  styleUrls: ['./shopping-page.component.scss']
})
export class ShoppingPageComponent implements OnInit {
  imageItems$: Observable<StoreItemWithOwnership[]>;
  themeItems$: Observable<StoreItemWithOwnership[]>;
  rewardItems$: Observable<StoreItemWithOwnership[]>;
  rewardCurrencyItems$: Observable<StoreItemWithOwnership[]>;
  userCurrency$: Observable<number>;
  currentUser$: Observable<User | null>;
  currentUser: User | null = null;
  userCurrency: number = 0;
  allAchievements: string[] = [];

  constructor(
      public storeService: StoreService,
      private usersService: UsersService,
      private snackbar: SnackbarService,
      private translate: TranslateService
  ) {}

  ngOnInit() {
    const allItems$ = this.storeService.allStoreItemsWithOwnership;

    this.imageItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'image'))
    );

    this.themeItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'theme'))
    );

    this.rewardItems$ = allItems$.pipe(
        map(items => items.filter(item =>
            item.itemType === 'rewardImage' || item.itemType === 'rewardTheme'
        ))
    );

    this.rewardCurrencyItems$ = allItems$.pipe(
        map(items =>
            items
                .filter(item => item.itemType === 'rewardCurrency')
                .sort((a, b) => (a.achievement || 0) - (b.achievement || 0)) // Sort by achievement field
        )
    );


    this.userCurrency$ = this.usersService.currentUserProfile$.pipe(
        map(user => user?.currency ?? 0)
    );

    this.currentUser$ = this.usersService.currentUserProfile$;

    this.currentUser$.subscribe(user => (this.currentUser = user));
    this.userCurrency$.subscribe(currency => (this.userCurrency = currency));

    this.loadAchievements();
    this.translate.onLangChange.subscribe(() => {
      this.loadAchievements();
    });
  }

  loadAchievements() {
    this.allAchievements = this.translate.instant('PROFILE.ALL_ACHIEVEMENTS');
  }

  getRequirementMessage(item: StoreItemWithOwnership): string {
    if (item.minLevel) {
      return this.translate.instant('SHOPPING.UNLOCKED_AT_LEVEL') + item.minLevel.toString();
    }
    if (item.achievement && this.allAchievements[item.achievement - 1]) {
      return this.translate.instant('SHOPPING.UNLOCKED_AT_ACHIEVEMENT') + this.allAchievements[item.achievement - 1];
    }
    return '';
  }

  meetsRequirements(item: StoreItemWithOwnership): boolean {
    if (!this.currentUser) return false;

    const currentLevel = Math.floor((this.currentUser.level || 0) / 10);
    if (item.minLevel) return currentLevel >= item.minLevel;
    if (item.achievement) return this.currentUser.achievements.includes(item.achievement);
    return true;
  }

  hasEnoughCurrency(item: StoreItemWithOwnership): boolean {
    return this.userCurrency >= item.cost;
  }

  async buyItem(id: string) {
    try {
      await this.storeService.buyItem(id);
    } catch (error: any) {
      this.snackbar.show(error.message);
    }
  }
}