import { Component } from '@angular/core';
import {UsersService} from "@app/services/users.service/users.service";


@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {
  currentUser$ = this.usersService.currentUserProfile$;

  constructor(
      public usersService: UsersService
  ) {}

}
