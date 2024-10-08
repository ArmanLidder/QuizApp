import {Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {ProfileService} from "@app/services/profile.service/profile.service";
import {environment} from "../../../environments/environment";

@Component({
  selector: 'app-avatar',
  templateUrl: './avatar.component.html',
  styleUrls: ['./avatar.component.scss']
})
export class AvatarComponent {
  // @Input() avatarUrl: string | null = '';
  // @Input() username: string | null = '';
  @Input() isChat: boolean;
  // @Output() disconnectUser = new EventEmitter<void>();

  isMenuOpen: boolean = false;
  menuEnabled: boolean = false;

  constructor(
      private router: Router,
      private socketService: SocketClientService,
      public profileService: ProfileService,
  ) {
    this.profileService.fetchUserProfile();
  }

  toggleMenu() {
    if (!this.isChat) {
      this.menuEnabled = !this.menuEnabled;
    }
  }

  goToProfile() {
    this.toggleMenu()
    this.router.navigate([`/profile`]);
  }

  logout() {
    this.toggleMenu()
    // this.username = null;
    // this.avatarUrl = null;
    // this.disconnectUser.emit();
    this.socketService.disconnect();
    this.profileService.clear();
    this.router.navigate(['/login']);
  }

  protected readonly environment = environment;
}
