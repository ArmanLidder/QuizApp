import {Component, EventEmitter, OnInit, Output} from '@angular/core';
import {SocketClientService} from '@app/services/socket-client.service/socket-client.service';
import {RoomValidationService} from '@app/services/room-validation.service/room-validation.service';
import {NO_COLOR} from '@common/style/style';
import {GameListService} from "@app/services/game-list.service/game-list.service";
import {UsersService} from "@app/services/users.service/users.service";
import {GameListItem} from "@common/interfaces/room-interface";
import {firstValueFrom} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";

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
        private socketService: SocketClientService,
        private gameListService: GameListService,
        private userService: UsersService,
    ) {
    }

    ngOnInit() {
        this.connect();
        this.roomValidationService.resetService();
    }

    connect() {
        if (!this.socketService.isSocketAlive()) {
            this.socketService.connect();
        }
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
        const game = (await this.getGame()) as GameListItem;
        const isHostFriend = await this.validateFriendship(game);
        if (game.friendsOnly && !isHostFriend) {
            this.error = "Cette partie est exclusive aux amis de l'hôte."
            this.handleError();
        } else {
            const isPrestigeValid = await this.validatePrestige(game.prestige);
            const enoughMoney = await this.validateMoney(game.price);
            if (!isPrestigeValid) {
                this.error = "Vous n'avez pas le prestige minimum pour rejoindre cette partie.";
                this.handleError();
            } else if (!enoughMoney) {
                this.error = "Vous n'avez pas assez d'argent pour rejoindre cette partie.";
                this.handleError();
            } else {
                this.error = await this.roomValidationService.verifyRoomId();
                this.handleError();
                if (!this.error) await this.validateUsername();
            }
        }
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
