import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { environment } from 'src/environments/environment';
import {Auth} from "@angular/fire/auth";

@Injectable({
    providedIn: 'root',
})
export class SocketClientService {
    socket: Socket;
    private isConnecting: boolean = false;

    constructor(private auth: Auth) {}

    isSocketAlive() {
        return this.socket && this.socket.connected;
    }

    connect() {
        if (this.isConnecting) return;
        this.isConnecting = true;
        const serverUrlWithoutApi = environment.serverUrl.replace('/api', '');
        console.log(`UserId: ${this.auth.currentUser?.uid}`)
        this.socket = io(serverUrlWithoutApi, {
            transports: ['websocket'],
            upgrade: false,
            auth: {
                userId: this.auth.currentUser?.uid
            },
        });
        this.socket.on('connect', () => {
            this.isConnecting = false;
        });
        this.socket.on('connect_error', (error) => {
            this.isConnecting = false;
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
}
