import { Component, OnInit } from '@angular/core';
import { ProfileService } from '@app/services/profile.service/profile.service';
import { UserProfile } from '@common/interfaces/user-data.interface';
import { ActivatedRoute } from '@angular/router';
import { environment } from "../../../environments/environment";

@Component({
  selector: 'app-profile',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
})
export class ProfilePageComponent implements OnInit {
  userProfile: UserProfile | null = null;
  username: string | null = null;
  avatarUrl: string;
  userAchievements: number[];

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
      private profileService: ProfileService,
      private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe(params => {
      this.username = params.get('username');
      if (this.username) {
        this.loadUserProfile(this.username);
      }
    });
  }

  loadUserProfile(username: string): void {
    this.profileService.getUserProfileWithUsername(username).subscribe(
        (profile: UserProfile) => {
          this.userProfile = profile;
          this.avatarUrl = `${environment.serverUrl}/images/${profile.avatar}`;
          this.userAchievements = profile.achievements.map(achievement => Number(achievement));
        },
        (error) => {
          console.error('Error fetching user profile:', error);
        }
    );
  }

  hasAchievement(index: number): boolean {
    return this.userAchievements.includes(index+1);
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
    console.log(this.userProfile?.playerPrestige)
    if (prestige >= 200) return 'Platine';
    if (prestige >= 150) return 'Or';
    if (prestige >= 100) return 'Argent';
    if (prestige >= 50) return 'Bronze';
    return 'Aucun';
  }
}