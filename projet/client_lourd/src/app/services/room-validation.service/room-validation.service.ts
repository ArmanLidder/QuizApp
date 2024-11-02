import { Injectable } from '@angular/core';
import { SocketClientService } from '@app/services/socket-client.service/socket-client.service';
import { ErrorDictionary } from '@common/browser-message/error-message/error-message';
// import { RoomValidationResult, UsernameValidation } from '@common/interfaces/socket-manager.interface';
// import { HOST_USERNAME } from '@common/names/host-username';
import {RoomValidationResult, UsernameValidation} from '@common/interfaces/socket-manager.interface';
import { SocketEvent } from '@common/socket-event-name/socket-event-name';
import {UsersService} from "@app/services/users.service/users.service";
import {firstValueFrom, Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";

@Injectable({
    providedIn: 'root',
})
export class RoomValidationService {
    user$: Observable<User | null>;
    isActive: boolean = true;
    isLocked: boolean = false;
    isRoomIdValid: boolean = false;
    roomId: string | undefined = '';
    username: string | undefined;
    isUsernameValid: boolean = false

    constructor(private socketService: SocketClientService, private usersService: UsersService) {
        this.user$ = this.usersService.currentUserProfile$
        this.user$.subscribe((user: User | null) => {
            this.username = user?.uid;
        })
    }

    resetService() {
        this.isActive = true;
        this.isLocked = false;
        this.isRoomIdValid = false;
        this.roomId = '';
        this.username = '';
        this.isUsernameValid = false;
    }


    async verifyRoomId() {
        return this.isOnlyDigit() ? await this.sendRoomId() : ErrorDictionary.VALIDATION_CODE_ERROR;
    }

    async getCurrentUser() {
        return ((await firstValueFrom(this.usersService.currentUserProfile$)) as User);
    }

    async verifyUsername() {
        // const whitespacePattern = /^\s*$/;
        // const isFormatValid = this.username === undefined || whitespacePattern.test(this.username);
        // const isHost = this.username?.toLowerCase() === HOST_USERNAME.toLowerCase();
        // if (isFormatValid) return ErrorDictionary.CHAR_NUM_ERROR;
        // else if (isHost) return ErrorDictionary.ORGANISER_NAME_ERROR;
        return await this.sendUsername();
    }

    async sendJoinRoomRequest() {
        const user = await this.getCurrentUser();
        return new Promise<string>((resolve) => {
            const usernameData = { roomId: Number(this.roomId), username: user.uid };
            this.socketService.send(SocketEvent.JOIN_GAME, usernameData, (isLocked: boolean) => {
                resolve(this.handleJoiningRoomValidation(isLocked));
            });
        });
    }

    private async sendUsername() {
        const user = await this.getCurrentUser();
        return new Promise<string>((resolve) => {
            const usernameData = { roomId: Number(this.roomId), username: user.uid };
            this.socketService.send(SocketEvent.VALIDATE_USERNAME, usernameData, (data: UsernameValidation) => {
                resolve(this.handleUsernameValidation(data));
            });
        });
    }

    private async sendRoomId() {
        return new Promise<string>((resolve) => {
            this.socketService.send(SocketEvent.VALIDATE_ROOM_ID, Number(this.roomId), (data: RoomValidationResult) => {
                resolve(this.handleRoomIdValidation(data));
            });
        });
    }

    private handleJoiningRoomValidation(isLocked: boolean) {
        this.isLocked = isLocked;
        return isLocked ? this.handleErrors(ErrorDictionary.ROOM_LOCKED) : '';
    }

    private handleUsernameValidation(data: UsernameValidation) {
        this.isUsernameValid = data.isValid;
        return data.isValid ? '' : data.error;
    }

    private handleRoomIdValidation(data: RoomValidationResult) {
        let error = '';
        if (!data.isRoom) error = this.handleErrors(ErrorDictionary.ROOM_CODE_EXPIRED);
        else if (data.isLocked) error = this.handleErrors(ErrorDictionary.ROOM_LOCKED);
        else this.isRoomIdValid = true;
        return error;
    }

    private handleErrors(errorType: string) {
        this.isRoomIdValid = false;
        this.isUsernameValid = false;
        return errorType;
    }

    private isOnlyDigit() {
        return this.roomId?.match('[0-9]{4}');
    }
}
