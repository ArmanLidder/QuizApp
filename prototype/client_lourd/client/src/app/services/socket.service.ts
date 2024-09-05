import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';

@Injectable({
  providedIn: 'root'
})
export class SocketService {
  socket!: Socket;

  get() {
    return this.socket;
  }
  connect(token: string) {
    this.socket = io('http://localhost:8000', { transports: ['websocket'], upgrade: false, auth: {
        token: token
      }, });
  }

  isSocketAlive() {
    return this.socket && this.socket.connected;
  }

  disconnect() {
    this.socket.disconnect();
  }

  on<T>(event: string, action: (data: T) => void): void {
    this.socket.on(event, action);
  }

  send<T, A>(event: string, data?: T, callback?: (data: A) => void): void {
    this.socket.emit(event, ...[data, callback].filter((x) => x));
  }
}
