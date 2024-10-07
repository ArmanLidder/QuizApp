import { Component, OnInit } from '@angular/core';
import { ProfileService } from "@app/services/profile.service/profile.service";
import { UserProfile } from "@common/interfaces/user-data.interface";
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import {environment} from "../../../environments/environment";

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  username: string | null = '';
  avatarUrl: string | null = '';

  constructor(
      private profileService: ProfileService,
      private router: Router
  ) {}

  ngOnInit(): void {
    this.router.events.pipe(
        filter(event => event instanceof NavigationEnd)
    ).subscribe(() => {
        this.get_user_data();
    });
  }

  resetData(value: void) {
    this.username = null;
    this.avatarUrl = null;
  }

  get_user_data(): void {
    this.profileService.getUserProfile().subscribe((profile: UserProfile) => {
      this.username = profile.username;
      this.avatarUrl = environment.serverUrl + '/images/' + profile.avatar;
    });
  }
}
