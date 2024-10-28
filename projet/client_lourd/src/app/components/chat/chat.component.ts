import {ApplicationRef, Component, ElementRef, inject, OnInit, ViewChild} from '@angular/core';
import {CanalService} from "@app/services/canal.service/canal.service";
import {Message, Canal} from "@common/interfaces/message.interface";
import {
    BehaviorSubject,
    combineLatest,
    filter,
    firstValueFrom,
    map,
    Observable,
    startWith,
    Subscription,
    switchMap
} from 'rxjs';
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
    @ViewChild('chatscrollable') private scrollContainer!: ElementRef;
    messageForm: FormGroup;

    // Observables from firestore
    canals$: Observable<Canal[]>;
    user$: Observable<User>;
    currentCanal$: Observable<Canal | undefined>;
    canalSubscription!: Subscription;
    private canalId$ = new BehaviorSubject<string | null>(null);

    isCreateCanal: boolean;
    isJoiningCanal: boolean;
    isDeleteCanal: boolean = false;
    canalIdToDelete: string = '';
    canalNameToDelete: string = '';
    canalHasBeenDeleted: boolean = false;

    canalNameForm: FormGroup;
    searchControl = new FormControl('');
    canalsSearch$: Observable<Canal[]>;
    feedback: string = '';

    // properties to control Chat component state => opened, closed or contextual
    state: State = State.closed;
    isChatFocused: boolean = false;


    constructor() {
        this.setUp();
    }

    async ngOnInit() {
        await this.canalService.ensureGeneralCanal();
    }

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

    // integrated or contextual UI
    toggleChatState() {
        if (this.state === State.closed) {
            this.state = State.opened;
        } else if (this.state === State.opened) {
            this.state = State.closed;
        }
    }

    // In chat room or not
    toggleIsChat() {
        this.isChatFocused = !this.isChatFocused;
        if (!this.isChatFocused) this.messageForm.reset('');
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
        if (canalName.toLowerCase().includes("room")) {
            this.feedback = "Le nom de canal ne peut pas contenir: room. Veuillez choisir un autre nom."
            return;
        }
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

    async loadCanal(canalId: string) {
        this.toggleIsChat();
        const uid = (await firstValueFrom(this.user$)).uid;
        console.log(uid);
        this.currentCanal$ = this.canalService.getCanal(canalId);
        this.canalId$.next(canalId);
        this.canalSubscription = this.canalId$
            .pipe(
                filter(id => !!id), // Only proceed if canal ID is valid
                switchMap(id => this.canalService.getCanal(id!)) // Fetch canal details
            )
            .subscribe(canal => {
                if (!canal) this.canalHasBeenDeleted = true
                else if (canal?.name !== 'general' && !(canal?.permittedUsers.includes(uid))) {
                    this.toggleIsChat();
                    this.appRef.tick();
                    this.canalSubscription.unsubscribe();
                    console.log('returnToMenu');
                }
            });
        this.focusOnForm('input_message');
    }

    async deleteCanal(canalId: string) {
        try {
            await this.canalService.deleteCanal(canalId);
            this.returnToMenu();
        } catch (error) {
            this.returnToMenu();
        }
    }

    async sendMessage(message?: string) {
        const messageContent = message || this.messageForm.get('message')?.value;
        const uid = (await firstValueFrom(this.user$)).uid;
        const canalId = (await firstValueFrom(this.currentCanal$))?.id as string;
        if (!canalId) {
            this.canalHasBeenDeleted = true;
        }
        if (messageContent && this.currentCanal$) {
            const newMessage: Message = {
                userUid: uid,
                message: messageContent,
            };
            try {
                await this.canalService.addMessage(canalId, newMessage)
                this.messageForm.reset();
                this.scrollDown();
            } catch (error) {
                this.returnToMenu();
            }
        }
    }

    // triggers move to creation page
    createNewCanal() {
        this.isCreateCanal = true;
        this.focusOnForm('input_canal');
    }

    // trigers move to join page
    joinNewCanal() {
        this.isJoiningCanal = true;
    }

    returnToMenu() {
        this.canalNameForm.reset('');
        this.messageForm.reset('');
        this.searchControl.reset('');
        this.feedback = '';
        this.isCreateCanal = false;
        this.isJoiningCanal = false;
        this.isDeleteCanal = false;
        this.canalIdToDelete = '';
        this.canalNameToDelete = '';
        if (this.canalSubscription) this.canalSubscription.unsubscribe();
        this.canalId$.next(null);
        this.canalHasBeenDeleted = false;
    }

    // trigger move to warning page
    accessDeleteCanal(canaId: string, canalName: string) {
        this.isDeleteCanal = true;
        this.canalIdToDelete = canaId;
        this.canalNameToDelete = canalName;
    }

    // help for assigning css class
    checkCanalType(canalName: string) {
        if (canalName === "general") return true;
        if (canalName.includes("room")) return true;
        return canalName.includes("#");
    }

    private setUp() {
        this.canals$ = this.canalService.canals$;
        this.user$ = this.usersService.currentUserProfile$ as Observable<User>;
        this.messageForm = this.fb.group({
            message: ['', [Validators.required, Validators.maxLength(200)]]
        });
        this.canalNameForm = this.fb.group({
            canalName: ['', [Validators.required, Validators.pattern(/^[a-zA-Z0-9]+$/), Validators.maxLength(20)]]
        });
        this.canalsSearch$ = combineLatest([
            this.canalService.canals$,
            this.searchControl.valueChanges.pipe(startWith('')),
            this.usersService.currentUserProfile$,
        ]).pipe(
            map(([canals, search, user]) => {
                const str = (search ?? '').toLowerCase();
                return canals.filter(canal => canal.name.toLowerCase().includes(str) && canal.name !== 'general' && !canal.name.includes('room') && !canal.name.includes('#') && !canal.permittedUsers.includes((user as User).uid));
            }),
            map(canals => canals || []),
        );
        this.canals$ = this.canals$.pipe(map(canals => this.sortCanal(canals)))
    }

    private scrollDown() {
        const chat = this.scrollContainer.nativeElement;
        const shouldScroll = (chat.scrollTop + chat.clientHeight) < chat.scrollHeight;
        setTimeout(() => {
            if (shouldScroll) chat.scrollTop = chat.scrollHeight + 300
        }, 500)
    }

    private sortCanal(canals: Canal[]) {
        return canals.sort((a, b) => {
            // Order: general first, then channels containing '*', then channels containing '#', then all others
            if (a.name === 'general') return -1; // General first
            if (b.name === 'general') return 1;

            const aContainsStar = a.name.includes('room');
            const bContainsStar = b.name.includes('room');
            if (aContainsStar && !bContainsStar) return -1; // a comes before b
            if (!aContainsStar && bContainsStar) return 1; // b comes before a

            const aContainsHash = a.name.includes('#');
            const bContainsHash = b.name.includes('#');
            if (aContainsHash && !bContainsHash) return -1; // a comes before b
            if (!aContainsHash && bContainsHash) return 1; // b comes before a
            return 0;
        });
    }

    private focusOnForm(id: string) {
        setTimeout(() => {
            const input = document.getElementById(id) as HTMLElement;
            input?.focus();
        }, 400);
    }

    protected readonly console = console;
}