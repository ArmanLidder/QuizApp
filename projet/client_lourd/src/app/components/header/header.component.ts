import {Component, OnInit} from '@angular/core';
import {UsersService} from "@app/services/users.service/users.service";
import {FriendsComponent} from "@app/components/friends/friends.component";
import {MatDialog} from "@angular/material/dialog";
import {FriendService} from "@app/services/friend.service/friend.service";
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {UserSettingsService} from "@app/services/user-settings.service/user-settings.service";


@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit{
  currentUser$: Observable<User | null>
  pendingRequests$: Observable<User[]>;
  currentLanguage: 'fr' | 'en';

  constructor(
      public usersService: UsersService,
      private dialog: MatDialog,
      public friendsService: FriendService,
      private settings: UserSettingsService
  ) {}

  ngOnInit() {
    this.currentUser$ = this.usersService.currentUserProfile$;
    this.pendingRequests$ = this.friendsService.friendRequests$;

    this.settings.currentLanguage.subscribe((language) => {
      this.currentLanguage = language;
    });
  }

  openFriendsDialog(): void {
    this.dialog.open(FriendsComponent, {
      width: '35%',
      height: '375px',
    });
  }

  async switchLanguage(event: Event) {
    const language = (event.target as HTMLSelectElement).value;
    await this.settings.switchLanguage(language as 'en'|'fr');
  }
}
