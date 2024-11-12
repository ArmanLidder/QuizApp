import {Component, inject, OnDestroy, OnInit} from '@angular/core';
import { UsersService} from "@app/services/users.service/users.service";
import { MatDialog } from "@angular/material/dialog";
import {Observable, Subscription} from 'rxjs';
import { User } from '@app/interfaces/user/user-data.interface';
import {
  AvatarModificationDialogComponent
} from "@app/components/avatar-modification-dialog/avatar-modification-dialog.component";
import {AvatarService} from "@app/services/avatar.service/avatar.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {
  UsernameModificationDialogComponent
} from "@app/components/username-modification-dialog/username-modification-dialog.component";
import {UserSearchDialogComponent} from "@app/components/user-search-dialog/user-search-dialog.component";
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
  private avatarService= inject(AvatarService);
  private snackbar = inject(SnackbarService);

  currentUser$: Observable<User | null>; // Using an observable to get user data
  userAchievements: number[] | undefined;
  allAchievements: string[] = [];
  private languageSubscription: Subscription;

  ngOnInit(): void {
    // Fetch user achievements when the component is initialized
    this.currentUser$ = this.usersService.currentUserProfile$;
    this.currentUser$.subscribe((user) => {
      if (user) {
        this.userAchievements = user.achievements.map((achievement) => Number(achievement));
      }
    });
    this.loadAchievements();

    // Subscribe to language changes to reload achievements on language switch
    this.languageSubscription = this.translate.onLangChange.subscribe(() => {
      this.loadAchievements();
    });
  }

  ngOnDestroy(): void {
    if (this.languageSubscription) {
      this.languageSubscription.unsubscribe();
    }
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

  getAchievementClass(index: number): string {
    return this.hasAchievement(index) ? 'bg-yellow-100 text-yellow-800' : 'bg-gray-100 text-gray-600';
  }

  getAchievementIcon(index: number): string {
    return this.hasAchievement(index) ? '🏆' : '☆';
  }

  getPrestigeLabel(prestige: number): string {
    if (prestige >= 200) return 'Platine';
    if (prestige >= 150) return 'Or';
    if (prestige >= 100) return 'Argent';
    if (prestige >= 50) return 'Bronze';
    return 'Aucun';
  }

  getPrestigeIcon(prestige: number): string {
    if (prestige >= 200) return '🏅'; // Platinum medal
    if (prestige >= 150) return '🥇'; // Gold medal
    if (prestige >= 100) return '🥈'; // Silver medal
    if (prestige >= 50) return '🥉';  // Bronze medal
    return '🚫';  // Default icon
  }

  avatarModificationDialog() {
    const dialogRef = this.dialog.open(AvatarModificationDialogComponent);

    dialogRef.afterClosed().subscribe(async (res) => {
      if (res) {
        try {
          await this.avatarService.handleAvatarModification(res.data);
          this.snackbar.show('Avatar modifié avec succès');
        } catch {
          this.snackbar.show('Erreur de modification');
        }
      }
    });
  }

  usernameModificationDialog() {
    this.dialog.open(UsernameModificationDialogComponent);
  }

  openUserSearch() {
    this.dialog.open(UserSearchDialogComponent, {
      width:'30%',
      maxWidth:'80vw'
    });
  }
}
