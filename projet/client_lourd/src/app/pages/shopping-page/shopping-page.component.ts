import { Component, OnInit } from '@angular/core';
import { StoreService } from "@app/services/store.service/store.service";
import { Observable } from "rxjs";
import { StoreItem } from "@common/interfaces/store.interface";
import { map } from 'rxjs/operators';
import { UsersService } from "@app/services/users.service/users.service";
import { User } from "@common/interfaces/user-data.interface";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
type StoreItemWithOwnership = StoreItem & { isOwned: boolean };
@Component({
  selector: 'app-shopping-page',
  templateUrl: './shopping-page.component.html',
  styleUrls: ['./shopping-page.component.scss']
})
export class ShoppingPageComponent implements OnInit {
  imageItems$: Observable<StoreItemWithOwnership[]>;
  themeItems$: Observable<StoreItemWithOwnership[]>;
  userCurrency$: Observable<number>;
  currentUser$: Observable<User | null>;

  constructor(private storeService: StoreService, private usersService: UsersService, private snackbar: SnackbarService) {}

  ngOnInit() {
    const allItems$ = this.storeService.allStoreItemsWithOwnership;

    this.imageItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'image'))
    );

    this.themeItems$ = allItems$.pipe(
        map(items => items.filter(item => item.itemType === 'theme'))
    );

    this.userCurrency$ = this.usersService.currentUserProfile$.pipe(
        map(user => user?.currency ?? 0)
    );

    this.currentUser$ = this.usersService.currentUserProfile$;
  }

  async buyItem(id: string) {
    try {
      await this.storeService.buyItem(id);
      this.snackbar.show('Le item a été acheté');
    } catch (error: any) {
      this.snackbar.show(error.message);
    }
  }
}

