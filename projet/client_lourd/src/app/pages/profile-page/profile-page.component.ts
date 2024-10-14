import { Component, OnInit } from '@angular/core';
import { UsersService} from "@app/services/users.service/users.service";
import { MatDialog } from "@angular/material/dialog";
import { UserModificationDialogComponent } from "@app/components/user-modification-dialog/user-modification-dialog.component";
import { Observable } from 'rxjs';
import { User } from '@common/interfaces/user-data.interface';

@Component({
  selector: 'app-profile',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
})
export class ProfilePageComponent implements OnInit {
  currentUser$: Observable<User | null>; // Using an observable to get user data
  userAchievements: number[] | undefined;

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

  constructor(private usersService: UsersService, private dialog: MatDialog) {
    // Get the current user profile observable from UsersService
    this.currentUser$ = this.usersService.currentUserProfile$;
  }

  ngOnInit(): void {
    // Fetch user achievements when the component is initialized
    this.currentUser$.subscribe((user) => {
      if (user) {
        this.userAchievements = user.achievements.map((achievement) => Number(achievement));
      }
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
    return '🔘';  // Default icon
  }

  openDialog() {
    this.dialog.open(UserModificationDialogComponent);
  }
}
