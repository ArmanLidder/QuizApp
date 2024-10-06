import { Component, OnInit } from '@angular/core';
import { ProfileService } from '@app/services/profile.service/profile.service';
import { UserProfile } from '@common/interfaces/user-data.interface';
import { ActivatedRoute } from '@angular/router'; // To get the username from the URL

@Component({
  selector: 'app-profile',
  templateUrl: './profile-page.component.html',
  styleUrls: ['./profile-page.component.scss'],
})
export class ProfilePageComponent implements OnInit {
  userProfile: UserProfile | null = null;
  username: string | null = null;

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
        },
        (error) => {
          console.error('Error fetching user profile:', error);
        }
    );
  }
}