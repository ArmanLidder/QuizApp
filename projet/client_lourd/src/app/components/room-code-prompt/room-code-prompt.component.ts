import {Component, EventEmitter, OnInit, Output} from '@angular/core';
import {RoomValidationService} from '@app/services/room-validation.service/room-validation.service';
import {NO_COLOR} from '@common/style/style';
import {GameListService} from "@app/services/game-list.service/game-list.service";
import {UsersService} from "@app/services/users.service/users.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {firstValueFrom} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-room-code-prompt',
    templateUrl: './room-code-prompt.component.html',
    styleUrls: ['./room-code-prompt.component.scss'],
})
export class RoomCodePromptComponent implements OnInit {
    @Output() sendRoomData: EventEmitter<number> = new EventEmitter<number>();
    @Output() sendUsernameData: EventEmitter<string> = new EventEmitter<string>();
    @Output() validationDone: EventEmitter<boolean> = new EventEmitter<boolean>();
    inputBorderColor: string = 'black';
    error: string | undefined = '';
    textColor: string = '';

    constructor(
        public roomValidationService: RoomValidationService,
        private gameListService: GameListService,
        private userService: UsersService,
        private translate: TranslateService,
    ) {
    }

    ngOnInit() {
        this.roomValidationService.resetService();
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

    async validateRoomId() {
        this.error = '';
        const game = (await this.getGame()) as GameListItem;
        const isHostFriend = game && await this.validateFriendship(game);

        if (game) {
            if (game.friendsOnly && !isHostFriend) {
                this.error = await this.translate.get('PLAYER_WAITING_PAGE.ROOM_CODE_PROMPT_ERRORS.FRIENDS_ONLY').toPromise();
            } else if (!(await this.validatePrestige(game.prestige))) {
                this.error = await this.translate.get('PLAYER_WAITING_PAGE.ROOM_CODE_PROMPT_ERRORS.INSUFFICIENT_PRESTIGE').toPromise();
            } else if (!(await this.validateMoney(game.price))) {
                this.error = await this.translate.get('PLAYER_WAITING_PAGE.ROOM_CODE_PROMPT_ERRORS.INSUFFICIENT_FUNDS').toPromise();
            } else {
                this.error = await this.roomValidationService.verifyRoomId();
                if (!this.error) await this.validateUsername();
            }
        } else {
            this.error = await this.roomValidationService.verifyRoomId();
            if (!this.error) await this.validateUsername();
        }
        this.handleError();
        if (!this.error) await this.joinRoom();
    }


    async validateUsername() {
        this.error = await this.roomValidationService.verifyUsername();
        this.handleError();
    }

    async joinRoom() {
        this.error = await this.roomValidationService.sendJoinRoomRequest();
        const isValid =
            !this.roomValidationService.isLocked && this.roomValidationService.isRoomIdValid && this.roomValidationService.isUsernameValid;
        if (isValid) this.sendAllDataToWaitingRoom();
        else this.handleError();
    }

    private sendAllDataToWaitingRoom() {
        this.sendRoomIdToWaitingRoom();
        this.sendUsernameToWaitingRoom();
        this.roomValidationService.isActive = false;
        this.sendValidationDone();
    }

    private handleError() {
        if (this.error === '') this.reset();
        else this.showErrorFeedback();
    }

    private reset() {
        this.textColor = NO_COLOR;
        this.inputBorderColor = 'black';
        this.error = '';
    }

    private showErrorFeedback() {
        this.textColor = 'red-text';
        this.inputBorderColor = 'red-border';
    }

    private async getGame() {
        const games: GameListItem[] = (await firstValueFrom(this.gameListService.games$));
        for (let game of games)
            if (game.room === Number(this.roomValidationService.roomId)) return game;
        return undefined;
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
