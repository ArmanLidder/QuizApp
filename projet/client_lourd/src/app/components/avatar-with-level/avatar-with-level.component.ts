import {Component, Input} from '@angular/core';
import {User} from "@common/interfaces/user-data.interface";

@Component({
  selector: 'app-avatar-with-level',
  templateUrl: './avatar-with-level.component.html',
  styleUrls: ['./avatar-with-level.component.scss']
})
export class AvatarWithLevelComponent {
  @Input() user!: User; // Expecting a User input to be passed to this component
}
