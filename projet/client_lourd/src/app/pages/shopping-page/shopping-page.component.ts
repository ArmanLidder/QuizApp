import { Component, OnInit } from '@angular/core';
import { StoreService } from "@app/services/store.service/store.service";
import { Observable} from "rxjs";
import { StoreItem } from "@common/interfaces/store.interface";
import { map } from 'rxjs/operators';
import { UsersService } from "@app/services/users.service/users.service";
import { User } from "@common/interfaces/user-data.interface";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
import {TranslateService} from "@ngx-translate/core";
type StoreItemWithOwnership = StoreItem & { isOwned: boolean };
@Component({
  selector: 'app-shopping-page',
  templateUrl: './shopping-page.component.html',
  styleUrls: ['./shopping-page.component.scss']
})
export class ShoppingPageComponent implements OnInit {
  imageItems$: Observable<StoreItemWithOwnership[]>;
  themeItems$: Observable<StoreItemWithOwnership[]>;
  rewardImageItems$: Observable<StoreItemWithOwnership[]>;
  rewardThemeItems$: Observable<StoreItemWithOwnership[]>;

  userCurrency$: Observable<number>;
  currentUser$: Observable<User | null>;
  currentUser: User | null = null;
  userCurrency: number = 0;

  constructor(private storeService: StoreService, private usersService: UsersService, private snackbar: SnackbarService, private translate: TranslateService) {}

  ngOnInit() {
    const allItems$ = this.storeService.allStoreItemsWithOwnership;

    this.imageItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'image'))
    );

    this.themeItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'theme'))
    );

    this.rewardImageItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'rewardImage'))
    );

    this.rewardThemeItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'rewardTheme'))
    );

    this.userCurrency$ = this.usersService.currentUserProfile$.pipe(
        map(user => user?.currency ?? 0)
    );

    this.currentUser$ = this.usersService.currentUserProfile$;

    this.currentUser$.subscribe(user => (this.currentUser = user));
    this.userCurrency$.subscribe(currency => (this.userCurrency = currency));
  }

  canBuyRewardItem(item: StoreItemWithOwnership): boolean {
    return this.meetsRequirements(item) && this.hasEnoughCurrency(item);
  }

  meetsRequirements(item: StoreItemWithOwnership): boolean {
    if (!this.currentUser) {
      return false;
    }

    return (!item.minLevel || this.currentUser.level >= item.minLevel) &&
        (!item.minPrestige || this.currentUser.prestige >= item.minPrestige);
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


  getPrestigeLabel(prestige: number) {
    let prestigeLabel: string;
    let prestigeIcon: string;

    if (prestige >= 200) {
      prestigeLabel = (this.translate.instant('PROFILE.PLATINUM'));
      prestigeIcon = '🏅';
    } else if (prestige >= 150) {
      prestigeLabel = (this.translate.instant('PROFILE.GOLD'));
      prestigeIcon = '🥇';
    } else if (prestige >= 100) {
      prestigeLabel = (this.translate.instant('PROFILE.SILVER'));
      prestigeIcon = '🥈';
    } else if (prestige >= 50) {
      prestigeLabel = (this.translate.instant('PROFILE.BRONZE'));
      prestigeIcon = '🥉';
    } else {
      prestigeLabel = (this.translate.instant('PROFILE.NONE'));
      prestigeIcon = '🚫';
    }

    return prestigeIcon + prestigeLabel;
  }
}

