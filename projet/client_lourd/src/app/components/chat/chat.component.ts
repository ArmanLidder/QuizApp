import {ApplicationRef, Component, inject, OnInit, ViewChild} from '@angular/core';
import {CanalService} from "@app/services/canal.service/canal.service";
import {Message, Canal} from "@common/interfaces/message.interface";
import {combineLatest, firstValueFrom, map, Observable, startWith} from 'rxjs';
import {FormBuilder, FormControl, FormGroup, Validators} from '@angular/forms';
import {UsersService} from "@app/services/users.service/users.service";
import {User} from "@app/interfaces/user/user-data.interface";
import {PopoutWindowComponent} from "angular-popout-window";

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
    private canalService: CanalService = inject(CanalService)
    private fb: FormBuilder = inject(FormBuilder)
    private appRef: ApplicationRef = inject(ApplicationRef)
    public usersService: UsersService = inject(UsersService)

    @ViewChild('popupWindow') popWindow: PopoutWindowComponent;
    messageForm: FormGroup;

    // Observables from firestore
    canals$: Observable<Canal[]>;
    user$: Observable<User>;
    currentCanal$: Observable<Canal | undefined>;

    isCreateCanal: boolean;
    isJoiningCanal: boolean;
    canalNameForm: FormGroup;
    searchControl = new FormControl('');
    canalsSearch$: Observable<Canal[]>;
    feedback: string = '';

    // properties to control Chat component state => opened, closed or contextual
    state: State = State.closed;
    isChatFocused: boolean = false;


    constructor() { this.setUp();}

    async ngOnInit() { await this.canalService.ensureGeneralCanal(); }

    // Pop out Window methods
    closingPopOut(isClosed: boolean) {
        if (isClosed) {
            this.state = State.closed;
            this.popWindow.popIn();
            this.appRef.tick(); // This triggers a cycle of change detection for rendering back the component
        }
    }

    popOut() {
        this.state = State.outside;
        this.popWindow.popOut();
    }

    // Methods for UI
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

    toggleIsChat() {
        this.isChatFocused = !this.isChatFocused;
    }

    // Check who is the sender for css style
    getMessageClass(msg: Message, user: User): string {
        return user.uid === msg.userUid ? 'sent' : 'received';
    }

    // Chat logic method calling appropiate services
    async joinChat(canalId: any) {
        const user = await firstValueFrom(this.user$);
        await this.canalService.addUser(canalId, user.uid);
        this.returnToMenu();
    }

    async leaveChat(canalId: any) {
        const user = await firstValueFrom(this.user$);
        await this.canalService.removeUser(canalId, user.uid);
    }

    async createCanal() {
        const canalName = this.canalNameForm.get('canalName')?.value;
        const userId = (await firstValueFrom(this.usersService.currentUserProfile$) as User).uid;
        if (canalName) {
            try {
                this.feedback = '';
                const docRef: string = await this.canalService.createCanal(canalName, false, [userId]);
                if (docRef === '') this.feedback = `Le nom ${canalName} est déjà utilisé. Veuillez choisir un autre nom.`;
                else this.returnToMenu();
            } catch (error) {
                this.feedback = `Le nom ${canalName} est déjà utilisé. Veuillez choisir un autre nom.`;
            }
        }
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

    createNewCanal() {
        this.isCreateCanal = true;
    }

    joinNewCanal() {
       this.isJoiningCanal = true;
    }

    returnToMenu() {
        this.canalNameForm.reset('');
        this.feedback = '';
        this.isCreateCanal = false;
        this.isJoiningCanal = false;
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

    private setUp() {
        this.canals$ = this.canalService.canals$;
        this.user$ = this.usersService.currentUserProfile$ as Observable<User>;
        this.messageForm = this.fb.group({
            message: ['', Validators.required]
        });
        this.canalNameForm = this.fb.group({
            canalName: ['', [Validators.required, Validators.pattern(/^[a-zA-Z0-9]+$/)]]
        });
        this.canalsSearch$ = combineLatest([
            this.canalService.canals$,
            this.searchControl.valueChanges.pipe(startWith('')),
            this.usersService.currentUserProfile$,
        ]).pipe(
            map(([canals, search, user]) => {
                const str = (search ?? '').toLowerCase();
                return canals.filter(canal => canal.name.toLowerCase().includes(str) && canal.name !== 'general' && !canal.permittedUsers.includes((user as User).uid));
            }),
            map(canals => canals || []),
        );
    }

    protected readonly console = console;
}