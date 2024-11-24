import {Component, inject, OnDestroy, OnInit} from '@angular/core';
import { UsersService} from "@app/services/users.service/users.service";
import { MatDialog } from "@angular/material/dialog";
import {Observable, Subscription} from 'rxjs';
import { User } from '@app/interfaces/user/user-data.interface';
import {
  AvatarModificationDialogComponent
} from "@app/components/avatar-modification-dialog/avatar-modification-dialog.component";
import {
  UsernameModificationDialogComponent
} from "@app/components/username-modification-dialog/username-modification-dialog.component";
import {TranslateService} from "@ngx-translate/core";

@Component({
  selector: 'app-profile',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
})
export class ProfilePageComponent implements OnInit, OnDestroy {
  private translate = inject(TranslateService);
  private usersService = inject(UsersService);
  private dialog = inject(MatDialog);

  currentUser$: Observable<User | null>; // Using an observable to get user data
  userAchievements: number[] | undefined;
  allAchievements: string[] = [];

  prestigeLabel: string = '';
  prestigeIcon: string = '';
  achievementClasses: string[] = [];
  achievementIcons: string[] = [];


  private languageSubscription: Subscription;

  ngOnInit() {
    this.currentUser$ = this.usersService.currentUserProfile$;
    this.currentUser$.subscribe(async (user) => {
      if (user) {
        this.userAchievements = user.achievements.map((achievement) => Number(achievement));
        await this.updatePrestige(user.prestige);
        this.updateAchievements();
      }
    });
    this.loadAchievements();

    this.languageSubscription = this.translate.onLangChange.subscribe(() => {
      this.loadAchievements();
    });
  }

  ngOnDestroy(): void {
    if (this.languageSubscription) {
      this.languageSubscription.unsubscribe();
    }
  }

  async updatePrestige(prestige: number) {
    if (prestige >= 200) {
      this.prestigeLabel = await this.translate.get('PROFILE.PLATINUM').toPromise();
      this.prestigeIcon = '🏅';
    } else if (prestige >= 150) {
      this.prestigeLabel = await this.translate.get('PROFILE.GOLD').toPromise();
      this.prestigeIcon = '🥇';
    } else if (prestige >= 100) {
      this.prestigeLabel = await this.translate.get('PROFILE.SILVER').toPromise();
      this.prestigeIcon = '🥈';
    } else if (prestige >= 50) {
      this.prestigeLabel = await this.translate.get('PROFILE.BRONZE').toPromise();
      this.prestigeIcon = '🥉';
    } else {
      this.prestigeLabel = await this.translate.get('PROFILE.NONE').toPromise();
      this.prestigeIcon = '🚫';
    }
  }

  updateAchievements(): void {
    this.allAchievements.forEach((_, i) => {
      const hasAchievement = this.hasAchievement(i);
      this.achievementClasses[i] = hasAchievement ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600';
      this.achievementIcons[i] = hasAchievement ? '🏆' : '☆';
    });
  }


  loadAchievements() {
    this.translate.get('PROFILE.ALL_ACHIEVEMENTS').subscribe((translatedAchievements: string[]) => {
      this.allAchievements = translatedAchievements;
    });
  }

  hasAchievement(index: number): boolean {
    if (this.userAchievements) return this.userAchievements.includes(index + 1);
    return false;
  }

  async avatarModificationDialog() {
    this.dialog.open(AvatarModificationDialogComponent);
  }

  usernameModificationDialog() {
    this.dialog.open(UsernameModificationDialogComponent);
  }

    protected readonly Math = Math;
}
