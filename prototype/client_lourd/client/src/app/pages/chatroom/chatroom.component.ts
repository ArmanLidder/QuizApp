import {Component, OnInit, OnDestroy, AfterViewChecked, ViewChild, ElementRef, HostListener} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import { SocketService} from "../../services/socket.service";
import { Router } from '@angular/router';

@Component({
  selector: 'app-chatroom',
  templateUrl: './chatroom.component.html',
  styleUrls: ['./chatroom.component.scss']
})
export class ChatroomComponent implements OnInit, OnDestroy, AfterViewChecked {
  @ViewChild('messagesContainer') private messagesContainer!: ElementRef;
  messageForm: FormGroup;
  messages: { user: string, text: string, createdAt: Date }[] = [];
  public token= localStorage.getItem('token') || '';

  @HostListener('window:beforeunload')
  removeToken() {
    localStorage.removeItem('token');
    this.socketService.disconnect();
  }

  constructor(private fb: FormBuilder, private socketService: SocketService, private router: Router) {
    this.messageForm = this.fb.group({
      message: ['',  Validators.required]
    });
  }

  ngOnInit(): void {
    if (!this.token) {
      alert("Erreur, essayez de vous reconnecter");
      this.router.navigate(['/']);
    }
    this.socketService.connect(this.token);

    this.socketService.on<{ user: string, text: string, createdAt: Date }>('message', (msg) => {
      this.messages.push(msg);
      console.log(this.messages);
    });

    this.socketService.on<{ user: string, text: string, createdAt: Date }[]>('allMessages', (messages) => {
      this.messages = messages;
    });
  }

  ngAfterViewChecked(): void {
    this.scrollToBottom();
  }

  private scrollToBottom(): void {
    try {
      this.messagesContainer.nativeElement.scrollTop = this.messagesContainer.nativeElement.scrollHeight;
    } catch (err) {
      console.error('Scroll to bottom error:', err);
    }
  }

  sendMessage(): void {
    const message = this.messageForm.value.message;
    if (message) {
      this.socketService.send('chatMessage', message);
      this.messageForm.reset();
    }
  }

  logout(): void {
    this.socketService.disconnect();
    localStorage.removeItem('token');
    this.router.navigate(['/']);
  }

  ngOnDestroy(): void {
    localStorage.removeItem('token');
    this.socketService.disconnect();
  }

}
