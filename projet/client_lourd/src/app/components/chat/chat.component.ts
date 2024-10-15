import { Component, OnInit } from '@angular/core';
import { CanalService } from "@app/services/canal.service/canal.service";
import { Message, Canal } from "@common/interfaces/message.interface";
import {firstValueFrom, Observable } from 'rxjs';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import {UsersService} from "@app/services/users.service/users.service";
import {User} from "@app/interfaces/user/user-data.interface";

export enum State {
  closed,
  opened,
  outside,
}

@Component({
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit {
  canals$: Observable<Canal[]>;
  user$: Observable<User>;
  currentCanal$: Observable<Canal | undefined>;
  messageForm: FormGroup;
  isChatFocused: boolean = false;
  state: State = State.closed;

  constructor(
      private canalService: CanalService,
      private fb: FormBuilder,
      public usersService: UsersService,
  ) {
    this.canals$ = this.canalService.canals$;
    this.user$ = this.usersService.currentUserProfile$ as Observable<User>;
    this.messageForm = this.fb.group({
      message: ['', Validators.required]
    });
  }

  async ngOnInit() {
    await this.canalService.ensureGeneralCanal();
  }

  trackById(index: number, canal: Canal): string {
    return canal.id!;
  }

  toggleChatState() {
    if (this.state === State.closed) {
      this.state = State.opened;
    } else if (this.state === State.opened) {
      this.state = State.closed;
    }
  }

  // Check who is the sender for css style
  getMessageClass(msg: Message, user: User): string {
    return user.uid === msg.userUid ? 'sent' : 'received';
  }

  loadCanal(canalId: string) {
    this.toggleIsChat();
    this.currentCanal$ = this.canalService.getCanal(canalId);
    setTimeout(() => {
      const input = document.querySelector('input[formControlName="message"]') as HTMLElement;
      input?.focus();
    }, 0);
  }

  async sendMessage(message?: string) {
    const messageContent = message || this.messageForm.get('message')?.value;
    const uid = (await firstValueFrom(this.user$)).uid;
    const canalId = (await firstValueFrom(this.currentCanal$))?.id as string;
    if (messageContent && this.currentCanal$) {
      const newMessage: Message = {
        userUid: uid, // Replace with actual user UID
        message: messageContent,
      };
      try {
        await this.canalService.addMessage(canalId, newMessage);
        this.messageForm.reset();
      } catch (error) {
        // console.error('Error sending message:', error);
      }
    }
  }

  async createNewCanal() {
    const canalName = prompt('Enter new canal name:');
    const userId = (await firstValueFrom(this.user$)).uid;
    if (canalName) {
      try {
        await this.canalService.createCanal(canalName, false, [userId]);
      } catch (error) {
        // console.error('Error creating canal:', error);
      }
    }
  }

  async deleteCanal(canalId: string) {
    if (confirm('Are you sure you want to delete this canal?')) {
      try {
        await this.canalService.deleteCanal(canalId);
      } catch (error) {
        console.error('Error deleting canal:', error);
      }
    }
  }

  toggleIsChat() {
    this.isChatFocused = !this.isChatFocused;
  }

  protected readonly console = console;
}