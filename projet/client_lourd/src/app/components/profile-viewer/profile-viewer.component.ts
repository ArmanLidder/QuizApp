import {Component, Inject, OnDestroy, OnInit} from '@angular/core';
import { MAT_DIALOG_DATA } from '@angular/material/dialog';
import { UsersService } from '@app/services/users.service/users.service';
import {combineLatest, firstValueFrom, Observable, Subscription} from 'rxjs';
import { User } from '@app/interfaces/user/user-data.interface';
import {FriendService} from "@app/services/friend.service/friend.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {map} from "rxjs/operators";
import {TranslateService} from "@ngx-translate/core";

@Component({
  selector: 'app-profile-viewer',
  templateUrl: './profile-viewer.component.html',
  styleUrls: ['./profile-viewer.component.scss'],
})
export class ProfileViewerComponent implements OnInit, OnDestroy {
  viewedUser$: Observable<User>;
  userAchievements: number[] | undefined;
  hasPendingRequest$: Observable<boolean>;
  isFriend$: Observable<boolean>;

  hideFriendButtons: boolean = false;

  allAchievements: string[] = [];

  achievementClasses: string[] = [];
  achievementIcons: string[] = [];
  prestigeLabel: string = '';
  prestigeIcon: string = '';


  languageSubscription: Subscription;

  constructor(
      private usersService: UsersService,
      private friendService: FriendService,
      private snackbar: SnackbarService,
      private translate: TranslateService,
      @Inject(MAT_DIALOG_DATA) public data: { uid: string }
  ) {}

  async ngOnInit(): Promise<void> {
    this.viewedUser$ = this.usersService.getUser(this.data.uid) as Observable<User>;

    this.viewedUser$.subscribe((viewedUser) => {
      if (viewedUser) {
        this.userAchievements = viewedUser.achievements.map((achievement) => Number(achievement));
        this.updateAchievements();
        this.updatePrestige(viewedUser.prestige);
      }
    });

    this.hideFriendButtons = await firstValueFrom(combineLatest([this.viewedUser$, this.usersService.currentUserProfile$]).pipe(
        map(([viewedUser, currentUser]) => viewedUser.uid === currentUser?.uid)
    ));

    this.hasPendingRequest$ = this.friendService.hasPendingRequest(this.viewedUser$);
    this.isFriend$ = this.friendService.isFriend(this.viewedUser$);
    this.loadAchievements();
    this.languageSubscription = this.translate.onLangChange.subscribe(() => {
      this.loadAchievements();
    });
  }

  ngOnDestroy() {
    this.languageSubscription.unsubscribe();
  }

  loadAchievements() {
    this.translate.get('PROFILE.ALL_ACHIEVEMENTS').subscribe((translatedAchievements: string[]) => {
      this.allAchievements = translatedAchievements;
      this.updateAchievements();
    });
  }

  updateAchievements(): void {
    this.achievementClasses = [];
    this.achievementIcons = [];
    this.allAchievements.forEach((_, i) => {
      const hasAchievement = this.userAchievements ? this.userAchievements.includes(i + 1) : false;
      this.achievementClasses[i] = hasAchievement ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600';
      this.achievementIcons[i] = hasAchievement ? '🏆' : '☆';
    });
  }

  async updatePrestige(prestige: number): Promise<void> {
    if (prestige >= 200) {
      this.prestigeLabel = await firstValueFrom(this.translate.get('PROFILE.PLATINUM'));
      this.prestigeIcon = '🏅';
    } else if (prestige >= 150) {
      this.prestigeLabel = await firstValueFrom(this.translate.get('PROFILE.GOLD'));
      this.prestigeIcon = '🥇';
    } else if (prestige >= 100) {
      this.prestigeLabel = await firstValueFrom(this.translate.get('PROFILE.SILVER'));
      this.prestigeIcon = '🥈';
    } else if (prestige >= 50) {
      this.prestigeLabel = await firstValueFrom(this.translate.get('PROFILE.BRONZE'));
      this.prestigeIcon = '🥉';
    } else {
      this.prestigeLabel = await firstValueFrom(this.translate.get('PROFILE.NONE'));
      this.prestigeIcon = '🚫';
    }
  }

  async sendFriendRequest(user: User) {
    try {
      await this.friendService.sendFriendRequest(user.uid);
    } catch (error: any) {
      this.snackbar.show(error.message);
    }
  }
}
