import { Component, OnInit, OnDestroy } from '@angular/core';
import { CanalService } from "@app/services/canal.service/canal.service";
import { Message, Canal } from "@common/interfaces/message.interface";
import { Observable, Subscription } from 'rxjs';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-chat',
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.scss']
})
export class ChatComponent implements OnInit, OnDestroy {
  canals$: Observable<Canal[]>;
  currentCanal: Canal | null = null;
  messageForm: FormGroup;
  private canalSubscription: Subscription | null = null;

  constructor(
      private canalService: CanalService,
      private fb: FormBuilder
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
    if (this.canalSubscription) {
      this.canalSubscription.unsubscribe();
    }
  }

  loadCanal(canalId: string) {
    if (this.canalSubscription) this.canalSubscription.unsubscribe();
    this.canalSubscription = this.canalService.getCanal(canalId).subscribe(canal => {
      if (canal) this.currentCanal = canal;
    });
  }

  async sendMessage() {
    if (this.messageForm.valid && this.currentCanal) {
      const messageContent = this.messageForm.get('message')?.value;
      const newMessage: Message = {
        userUid: 'test', // Replace with actual user UID
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
        if (this.currentCanal?.id === canalId) {
          this.loadCanal('general');
        }
      } catch (error) {
        console.error('Error deleting canal:', error);
      }
    }
  }
}