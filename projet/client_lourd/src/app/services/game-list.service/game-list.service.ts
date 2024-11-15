import { Injectable } from '@angular/core';
import { SocketEvent } from "@common/socket-event-name/socket-event-name";
import { SocketClientService } from "@app/services/socket-client.service/socket-client.service";
import { GameListItem } from "@common/interfaces/room-interface";
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class GameListService {
  private gamesSubject = new BehaviorSubject<GameListItem[]>([]);
  public games$ = this.gamesSubject.asObservable();

  constructor(private socketService: SocketClientService) {}

  initialize() {
    if (!this.socketService.isSocketAlive()) this.socketService.connect()
    this.configureBaseSocket();
    this.fetchGameList();
  }

  cleanup(): void {
    this.socketService.socket.off(SocketEvent.UPDATE_GAME_LIST);
  }

  fetchGameList(): void {
    this.socketService.send(SocketEvent.GET_GAME_LIST);
  }

  private configureBaseSocket(): void {
    this.socketService.on(SocketEvent.UPDATE_GAME_LIST, (games: GameListItem[]) => {
      console.log('Received Update GameList:', games);
      this.gamesSubject.next(games);
    });
  }
}