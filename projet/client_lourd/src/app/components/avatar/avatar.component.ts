import {Component, Input, Output, EventEmitter} from '@angular/core';
import { Router } from '@angular/router';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";

@Component({
  selector: 'app-avatar',
  templateUrl: './avatar.component.html',
  styleUrls: ['./avatar.component.scss']
})
export class AvatarComponent {
  @Input() avatarUrl: string | null = '';
  @Input() username: string | null = '';
  @Input() isChat: boolean;
  @Output() disconnectUser = new EventEmitter<void>();

  isMenuOpen: boolean = false;
  menuEnabled: boolean = false;

  constructor(private router: Router, private socketService: SocketClientService) {}

  toggleMenu() {
    if (!this.isChat) {
      this.menuEnabled = !this.menuEnabled;
    }
  }

  goToProfile() {
    this.toggleMenu()
    this.router.navigate([`/profile/${this.username}`]);
  }

  logout() {
    this.toggleMenu()
    this.username = null;
    this.avatarUrl = null;
    this.disconnectUser.emit();
    this.socketService.disconnect();
    this.router.navigate(['/login']);
  }
}
