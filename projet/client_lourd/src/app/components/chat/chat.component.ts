import { Component, OnInit, OnDestroy } from '@angular/core';
import { CanalService } from "@app/services/canal.service/canal.service";
import { Message, Canal } from "@common/interfaces/message.interface";
import {firstValueFrom, Observable, Subscription} from 'rxjs';
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
export class ChatComponent implements OnInit, OnDestroy {
  canals$: Observable<Canal[]>;
  currentCanal: Canal | null = null;
  messageForm: FormGroup;
  isChatFocused: boolean = false;
  state: State = State.closed;
  currentUser: User | null = null;
  private userSubscription!: Subscription;
  private canalSubscription: Subscription | null = null;


  constructor(
      private canalService: CanalService,
      private fb: FormBuilder,
      public usersService: UsersService,
  ) {
    this.canals$ = this.canalService.canals$;
    this.messageForm = this.fb.group({
      message: ['', Validators.required]
    });
  }

  async ngOnInit() {
    await this.canalService.ensureGeneralCanal();
  }

  ngOnDestroy() {
    if (this.canalSubscription) this.canalSubscription.unsubscribe();
    if (this.userSubscription) this.userSubscription.unsubscribe();
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

  // en attendant l'integration avec le composant avater
  async getUsernameById(uid:string) {
    if (!this.currentUser) {
      this.currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
      this.userSubscription = this.usersService.currentUserProfile$.subscribe(
          (user) => {
            this.currentUser = user;
          });
    }
    if (this.currentUser?.uid === uid) return this.currentUser?.username;
    else return (await firstValueFrom(this.usersService.getUser(uid)))?.username
  }

  loadCanal(canalId: string) {
    if (this.canalSubscription) this.canalSubscription.unsubscribe();
    this.toggleIsChat();
    this.canalSubscription = this.canalService.getCanal(canalId).subscribe(canal => {
      if (canal) this.currentCanal = canal;
      setTimeout(() => {
        const input = document.querySelector('input[formControlName="message"]') as HTMLElement;
        input?.focus();
      }, 0);
    });
  }

  async sendMessage(message?: string) {
    const messageContent = message || this.messageForm.get('message')?.value;
    if (!this.currentUser) {
      this.currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
      this.userSubscription = this.usersService.currentUserProfile$.subscribe(
          (user) => {
            this.currentUser = user;
          });
    }
    if (messageContent && this.currentCanal) {
      const newMessage: Message = {
        userUid: this.currentUser?.uid ?? "test", // Replace with actual user UID
        message: messageContent,
      };
      try {
        await this.canalService.addMessage(this.currentCanal.id!, newMessage);
        this.messageForm.reset();
      } catch (error) {
        console.error('Error sending message:', error);
      }
    }
  }

  async createNewCanal() {
    const canalName = prompt('Enter new canal name:');
    if (canalName) {
      try {
        await this.canalService.createCanal(canalName, false, []);
      } catch (error) {
        console.error('Error creating canal:', error);
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