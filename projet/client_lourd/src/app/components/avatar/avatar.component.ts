import {Component, Input} from '@angular/core';
import { Router } from '@angular/router';
import {UsersService} from "@app/services/users.service/users.service";
import { environment } from "../../../environments/environment";
import { Observable } from 'rxjs';
import { User } from "@app/interfaces/user/user-data.interface";
import {AuthService} from "@app/services/auth.service/auth.service";

@Component({
  selector: 'app-avatar',
  templateUrl: './avatar.component.html',
  styleUrls: ['./avatar.component.scss']
})
export class AvatarComponent {
  @Input() isChat: boolean;
  @Input() uid: string;

  currentUser$: Observable<User | undefined>;

  isMenuOpen: boolean = false;
  menuEnabled: boolean = false;

  constructor(
      private router: Router,
      private authService: AuthService,
      private usersService: UsersService,
  ) {}

  ngOnInit(): void {
    if (this.uid) {
      this.loadUserProfile(this.uid);
    } else if (!this.isChat) {
      this.currentUser$ = this.usersService.currentUserProfile$ as Observable<User>;
    }
  }

  private loadUserProfile(uid: string): void {
    this.currentUser$ = this.usersService.getUser(uid) as Observable<User>;
  }


  toggleMenu() {
    if (!this.isChat) {
      this.menuEnabled = !this.menuEnabled;
    }
  }

  goToProfile() {
    this.toggleMenu();
    this.router.navigate([`/profile`]);
  }

  async logout() {
    this.toggleMenu();
    await this.authService.logout();
    this.router.navigate(['/login']);
    console.log("navigation done")
  }


  protected readonly environment = environment;
}
