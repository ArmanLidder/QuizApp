import {Component, Input, OnInit} from '@angular/core';
import { Router } from '@angular/router';
import {UsersService} from "@app/services/users.service/users.service";
import { Observable } from 'rxjs';
import { User } from "@app/interfaces/user/user-data.interface";
import {AuthService} from "@app/services/auth.service/auth.service";
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {MatDialog} from "@angular/material/dialog";
import {ProfileViewerComponent} from "@app/components/profile-viewer/profile-viewer.component";

@Component({
  selector: 'app-avatar',
  templateUrl: './avatar.component.html',
  styleUrls: ['./avatar.component.scss']
})
export class AvatarComponent implements OnInit{
  @Input() isChat: boolean = false;
  @Input() showProfileOnClick = true;
  @Input() showMoney: boolean = false;
  @Input() showMenu: boolean = false;
  @Input() size: 'small' | 'medium' | 'large' = 'medium';
  @Input() hideLevel: boolean = false;

  @Input() uid: string; //imporant to pass in

  currentUser$: Observable<User | undefined>;

  isMenuOpen: boolean = false;
  menuEnabled: boolean = false;
  isLoading: boolean = true;

  constructor(
      private router: Router,
      private authService: AuthService,
      private usersService: UsersService,
      private socketService: SocketClientService,
      private dialog: MatDialog,
  ) {}

  ngOnInit(): void {
    if (this.uid) {
      this.loadUserProfile(this.uid);
    } else {
      this.currentUser$ = this.usersService.currentUserProfile$ as Observable<User>;
    }
  }

  openProfileDialog(): void {
    if (this.uid && this.showProfileOnClick) {
      this.dialog.open(ProfileViewerComponent, {
        data: { uid: this.uid },
        height: 'auto', // Let the height adjust based on content
        width: '80%',   // Adjust width to ensure it takes up more space
        maxWidth: '600px' // Optional: set a max width for better control
      });
    }
  }

  private loadUserProfile(uid: string): void {
    this.currentUser$ = this.usersService.getUser(uid) as Observable<User>;
  }


  async goToProfile() {
    await this.router.navigate([`/profile`]);
  }

  async logout() {
    await this.authService.logout();
    await this.router.navigate(['/login']);
    if (this.socketService.isSocketAlive()) this.socketService.disconnect();
  }

  onImageLoad(): void {
    this.isLoading = false;
  }
}
