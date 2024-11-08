import {Component, OnInit} from '@angular/core';
import {UsersService} from "@app/services/users.service/users.service";
import {FriendsComponent} from "@app/components/friends/friends.component";
import {MatDialog} from "@angular/material/dialog";
import {FriendService} from "@app/services/friend.service/friend.service";
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";


@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit{
  currentUser$: Observable<User | null>
  pendingRequests$: Observable<User[]>;

  constructor(
      public usersService: UsersService,
      private dialog: MatDialog,
      public friendsService: FriendService,
  ) {}
  
  ngOnInit() {
    this.currentUser$ = this.usersService.currentUserProfile$;
    this.pendingRequests$ = this.friendsService.friendRequests$;
  }

  openFriendsDialog(): void {
    this.dialog.open(FriendsComponent, {
      width: '35%',
      height: '375px',
    });
  }
}
