import { Component } from '@angular/core';
import { ProfileService } from "@app/services/profile.service/profile.service";
// import { UserProfile } from "@common/interfaces/user-data.interface";
// import { Router, NavigationEnd } from '@angular/router';
// import { filter } from 'rxjs/operators';
// import {environment} from "../../../environments/environment";
// import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {
  // username: string | null = '';
  // avatarUrl: string | null = '';

  constructor(
      public profileService: ProfileService,
      // private router: Router,
      // private socketService: SocketClientService
  ) {
  }

  // ngOnInit(): void {
  //   this.router.events.pipe(
  //       filter(event => event instanceof NavigationEnd)
  //   ).subscribe(() => {
  //     this.get_user_data();
  //   });
  // }

  // resetData(value: void) {
  //   this.username = null;
  //   this.avatarUrl = null;
  // }

  // get_user_data(): void {
  //   console.log("Getting user data")
  //   if (this.socketService.isSocketAlive()) {
  //     this.profileService.fetchUserProfile().subscribe((profile: UserProfile) => {
  //       console.log(`Received user data: ${profile}`)
  //       this.username = profile.username;
  //       this.avatarUrl = environment.serverUrl + '/images/' + profile.avatar;
  //     });
  //   }

  //}
}
