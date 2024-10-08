import { Component, OnInit } from '@angular/core';
import { ProfileService } from '@app/services/profile.service/profile.service';
import { MatDialog } from "@angular/material/dialog";
import { UserModificationDialogComponent } from "@app/components/user-modification-dialog/user-modification-dialog.component";

@Component({
  selector: 'app-profile',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
})
export class ProfilePageComponent implements OnInit {
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

  constructor(
      public profileService: ProfileService,
      private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.userAchievements = this.profileService.userData?.achievements.map(achievement => Number(achievement));
  }

  hasAchievement(index: number): boolean {
    if (this.userAchievements) return this.userAchievements.includes(index+1);
    return false
  }

  getAchievementClass(index: number): string {
    return this.hasAchievement(index)
        ? 'bg-yellow-100 text-yellow-800'
        : 'bg-gray-100 text-gray-600';
  }

  getAchievementIcon(index: number): string {
    return this.hasAchievement(index) ? '🏆' : '☆';
  }

  getPrestigeLabel(prestige: any): string {
    if (prestige >= 200) return 'Platine';
    if (prestige >= 150) return 'Or';
    if (prestige >= 100) return 'Argent';
    if (prestige >= 50) return 'Bronze';
    return 'Aucun';
  }

  getPrestigeIcon(prestige: any): string {
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