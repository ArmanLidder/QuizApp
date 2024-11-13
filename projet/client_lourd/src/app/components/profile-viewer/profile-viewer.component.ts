import { Component, Inject, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { UsersService } from '@app/services/users.service/users.service';
import {combineLatest, firstValueFrom, Observable} from 'rxjs';
import { User } from '@app/interfaces/user/user-data.interface';
import {FriendService} from "@app/services/friend.service/friend.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {map} from "rxjs/operators";

@Component({
  selector: 'app-profile-viewer',
  templateUrl: './profile-viewer.component.html',
  styleUrls: ['./profile-viewer.component.scss'],
})
export class ProfileViewerComponent implements OnInit {
  viewedUser$: Observable<User>;
  userAchievements: number[] | undefined;
  hasPendingRequest$: Observable<boolean>;
  isFriend$: Observable<boolean>;

  hideFriendButtons: boolean = false;

  allAchievements: string[] = [
    "Gagner une partie en ligne",
    "Gagner une partie en équipe",
    "Gagner 5 parties",
    "Gagner 10 parties",
    "Atteindre le prestige bronze",
    "Atteindre le prestige argent",
    "Atteindre le prestige or",
    "Atteindre le prestige platine"
  ];

  constructor(
      private dialogRef: MatDialogRef<ProfileViewerComponent>,
      private usersService: UsersService,
      private friendService: FriendService,
      private snackbar: SnackbarService,
      @Inject(MAT_DIALOG_DATA) public data: { uid: string }
  ) {}

  async ngOnInit(): Promise<void> {
    this.viewedUser$ = this.usersService.getUser(this.data.uid) as Observable<User>;
    this.viewedUser$.subscribe((viewedUser) => {
      if (viewedUser) {
        this.userAchievements = viewedUser.achievements.map((achievement) => Number(achievement));
      }
    });

    this.hideFriendButtons = await firstValueFrom(combineLatest([this.viewedUser$, this.usersService.currentUserProfile$]).pipe(
        map(([viewedUser, currentUser]) => viewedUser.uid === currentUser?.uid)
    ));

    this.hasPendingRequest$ = this.friendService.hasPendingRequest(this.viewedUser$);
    this.isFriend$ = this.friendService.isFriend(this.viewedUser$);
  }

  closeDialog(): void {
    this.dialogRef.close();
  }

  getPrestigeLabel(prestige: number): string {
    if (prestige >= 200) return 'Platine';
    if (prestige >= 150) return 'Or';
    if (prestige >= 100) return 'Argent';
    if (prestige >= 50) return 'Bronze';
    return 'Aucun';
  }

  getPrestigeIcon(prestige: number): string {
    if (prestige >= 200) return '🏅';
    if (prestige >= 150) return '🥇';
    if (prestige >= 100) return '🥈';
    if (prestige >= 50) return '🥉';
    return '🚫';
  }

  hasAchievement(index: number): boolean {
    if (this.userAchievements) return this.userAchievements.includes(index + 1);
    return false;
  }

  getAchievementClass(index: number): string {
    return this.hasAchievement(index) ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600';
  }

  getAchievementIcon(index: number): string {
    return this.hasAchievement(index) ? '🏆' : '☆';
  }

  async sendFriendRequest(user: User) {
    try {
      await this.friendService.sendFriendRequest(user.uid);
    } catch (error: any) {
      this.snackbar.show(error.message);
    }
  }
}
