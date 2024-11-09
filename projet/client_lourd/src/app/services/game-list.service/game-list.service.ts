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

  async initialize() {
    if (!this.socketService.isSocketAlive()) {
      await this.socketService.asyncConnect();
    }
    this.configureBaseSocket();
    this.fetchGameList();
  }

  cleanup(): void {
    if(this.socketService.isSocketAlive()) this.socketService.socket.off(SocketEvent.UPDATE_GAME_LIST);
    this.gamesSubject.next([]);
  }

  fetchGameList(): void {
    this.socketService.send(SocketEvent.GET_GAME_LIST);
  }

  private configureBaseSocket(): void {
    this.socketService.on(SocketEvent.UPDATE_GAME_LIST, (games: GameListItem[]) => {
      const currentGames = this.gamesSubject.getValue();
      const updatedGames = currentGames.filter(game => games.some(updatedGame => updatedGame.room !== game.room));
      games.forEach(updatedGame => {
        const existingGameIndex = updatedGames.findIndex(game => game.room === updatedGame.room);
        if (existingGameIndex === -1) {
          updatedGames.push(updatedGame);  // Add the new game
        }
      });
      this.gamesSubject.next(updatedGames);
    });
  }
}