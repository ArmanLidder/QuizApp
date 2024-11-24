import {Component, OnInit, Output, EventEmitter} from '@angular/core';
import {GameListService} from "@app/services/game-list.service/game-list.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {Observable, of, firstValueFrom} from 'rxjs';
import {QuizService} from "@app/services/quiz.service/quiz.service";
import {catchError, switchMap} from 'rxjs/operators';
import {RoomValidationService} from "@app/services/room-validation.service/room-validation.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";
import {User} from "@common/interfaces/user-data.interface";
import {UsersService} from "@app/services/users.service/users.service";
import {Router} from "@angular/router";
import {GameService} from "@app/services/game.service/game.service";
import {ObservationService} from "@app/services/observation.service/observation.service";
import {HOST_USERNAME} from "@common/names/host-username";
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-active-game-list',
    templateUrl: './active-game-list.component.html',
    styleUrls: ['./active-game-list.component.scss']
})
export class ActiveGameListComponent implements OnInit {
    @Output() sendRoomData: EventEmitter<number> = new EventEmitter<number>();
    @Output() sendUsernameData: EventEmitter<string> = new EventEmitter<string>();
    @Output() validationDone: EventEmitter<boolean> = new EventEmitter<boolean>();
    games$: Observable<GameListItem[]>;
    quizNameMap: Map<string, string> = new Map();
    joiningRoom = false;

    constructor(
        private gameListService: GameListService,
        private gameService: GameService,
        private quizService: QuizService,
        private roomValidationService: RoomValidationService,
        private snackbarService: SnackbarService,
        private userService: UsersService,
        private router: Router,
        private observationService: ObservationService,
        private translate: TranslateService,
    ) {}

    async ngOnInit() {
        this.games$ = this.gameListService.games$;
        await this.gameListService.initialize();
        this.prefetchQuizNames();
    }

    minimumPrestige(prestige: number) {
        if (prestige >= 200) return '🏅'; // Platinum medal
        if (prestige >= 150) return '🥇'; // Gold medal
        if (prestige >= 100) return '🥈'; // Silver medal
        if (prestige >= 50) return  '🥉';  // Bronze medal
        return '🚫';  // Default icon
    }

    sendRoomIdToWaitingRoom() {
        this.sendRoomData.emit(Number(this.roomValidationService.roomId));
    }

    sendUsernameToWaitingRoom() {
        this.sendUsernameData.emit(this.roomValidationService.username);
    }

    sendValidationDone() {
        this.validationDone.emit(this.roomValidationService.isActive);
    }

    prefetchQuizNames() {
        this.games$.pipe(
            switchMap(games =>
                of(games.filter(game => !game.private)) // Get only public games
            )
        ).subscribe(games => {
            games.forEach(game => {
                this.quizService.basicGetById(game.quizId).pipe(
                    catchError(() => of({title: 'Quiz Inconnu'})) // Handle errors gracefully
                ).subscribe((quiz: any) => {
                    this.quizNameMap.set(game?.quizId, quiz?.title);
                });
            });
        });
    }

    getQuizName(id: string): string {
        return this.quizNameMap.get(id) || 'Chargement...';
    }


    async joinRoom(game: GameListItem) {
        if (this.joiningRoom) return; // Exit if already processing a join request, fix for spam join
        this.joiningRoom = true;
        try {
            this.gameService.observerMode = false;
            this.roomValidationService.roomId = game.room as unknown as string;
            const isHostFriend = await this.validateFriendship(game);
            if (game.friendsOnly && !isHostFriend)  {
                this.snackbarService.show(await this.translate.get("ACTIVE_GAME_LIST.EXCLUSIVE_FRIENDS_GAME").toPromise());
            } else {
                const isPrestigeValid = await this.validatePrestige(game.prestige);
                const enoughMoney = await this.validateMoney(game.price);
                if (!isPrestigeValid) {
                    this.snackbarService.show(await this.translate.get("ACTIVE_GAME_LIST.INSUFFICIENT_PRESTIGE").toPromise());
                } else if (!enoughMoney){
                    this.snackbarService.show(await this.translate.get("ACTIVE_GAME_LIST.INSUFFICIENT_FUNDS").toPromise());
                } else {
                    await this.roomValidationService.verifyUsername();
                    if (!this.roomValidationService.isUsernameValid) {
                        this.snackbarService.show(await this.translate.get("ACTIVE_GAME_LIST.USER_BANNED").toPromise());
                    } else await this.roomValidationService.sendJoinRoomRequest();
                    if (this.roomValidationService.isLocked) {
                        this.snackbarService.show(await this.translate.get("ACTIVE_GAME_LIST.ROOM_LOCKED").toPromise());
                    }
                    const isValid = !this.roomValidationService.isLocked && this.roomValidationService.isUsernameValid;
                    if (isValid) this.sendAllDataToWaitingRoom();
                }
            }
        } catch(error:any) {
            console.error("Error joining room:", error);
        } finally {
            this.joiningRoom = false;
        }
    }

    async observeGame(game: GameListItem) {
        if (this.joiningRoom) return; // Exit if already processing a join request, fix for spam join
        this.joiningRoom = true;
        try {
            this.gameService.init(String(game.room), true);
            this.gameService.gameRealService.username = HOST_USERNAME;
            this.observationService.observeGame(game);
            await this.router.navigate([`game/${game.room}`]);
        }  catch(error:any) {
            console.error("Error joining room:", error);
        } finally {
            this.joiningRoom = false;
        }
    }

    private sendAllDataToWaitingRoom() {
        this.sendRoomIdToWaitingRoom();
        this.sendUsernameToWaitingRoom();
        this.roomValidationService.isActive = false;
        this.sendValidationDone();
    }

    private async validateFriendship(game: GameListItem) {
        const currentUserId = (await firstValueFrom(this.roomValidationService.user$) as User)?.uid;
        const hostProfile = await firstValueFrom(this.userService.getUser(game.hostUserId)) as User;
        return hostProfile.friends.includes(currentUserId);
    }

    private async validatePrestige(prestige: number) {
        const currentUserPrestige = (await firstValueFrom(this.roomValidationService.user$) as User)?.prestige;
        return currentUserPrestige >= prestige;
    }

    private async validateMoney(money: number) {
        const currentUserMoney = (await firstValueFrom(this.roomValidationService.user$) as User)?.currency;
        const isValid = currentUserMoney >= money;
        if (isValid) await this.userService.updateUser({currency: (currentUserMoney - money)});
        return isValid;
    }
}