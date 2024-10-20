import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { environment } from 'src/environments/environment';
import { UsersService } from "@app/services/users.service/users.service";
import {firstValueFrom} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";

@Injectable({
    providedIn: 'root',
})
export class SocketClientService {
    private userID: string;
    socket: Socket;

    constructor(private usersService: UsersService) {}

    isSocketAlive() {
        return this.socket && this.socket.connected;
    }

    connect() {
        this.fetchUserID().then(() => {
            console.log('Connection du socket client')
            const serverUrlWithoutApi = environment.serverUrl.replace('/api', '');
            console.log(`UserId: ${this.userID}`)
            this.socket = io(serverUrlWithoutApi, {
                transports: ['websocket'],
                upgrade: false,
                auth: {
                    userId: this.userID
                },
            });
        });
    }

    async asyncConnect() {
        await this.fetchUserID();
        const serverUrlWithoutApi = environment.serverUrl.replace('/api', '');
        console.log(`UserId: ${this.userID}`)
        this.socket = io(serverUrlWithoutApi, {
            transports: ['websocket'],
            upgrade: false,
            auth: {
                userId: this.userID
            },
        });
    }

    disconnect() {
        localStorage.clear();
        this.socket.disconnect();
    }

    on<T>(event: string, action: (data: T) => void): void {
        this.socket.on(event, action);
    }

    send<T, A>(event: string, data?: T, callback?: (data: A) => void): void {
        this.socket.emit(event, ...[data, callback].filter((x) => x));
    }

    private async fetchUserID() {
        const user: User | null = await firstValueFrom(this.usersService.currentUserProfile$)
        console.log(`Fetch userId: ${user?.uid}`)
        if (user) this.userID = user.uid;
        else throw new Error("User Id not fetch since user is null or undefined");
    }
}
