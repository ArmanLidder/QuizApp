import { Injectable } from '@angular/core';
import {GameConfig} from "@common/interfaces/game-info.interface";
import {UsersService} from "@app/services/users.service/users.service";
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";

@Injectable({
  providedIn: 'root'
})
export class GameConfigService {
  user$: Observable<User | null>;
  hostId: string | undefined;
  gameType: string;
  price: number;
  firendsOnly: boolean;
  private: boolean;
  prestige: number;


  constructor(private usersService: UsersService) {
    this.user$ = this.usersService.currentUserProfile$;
    this.user$.subscribe((user: User | null) => {
      this.hostId = user?.uid;
    });
  }

  setGameType(gameType: string) {
    this.gameType = gameType;
  }

  setPrice(price: number) {
    this.price = price;
  }

  setFriendsOnly(isFriends: boolean) {
    this.firendsOnly = isFriends;
  }

  setPrivacy(isPrivate: boolean) {
    this.private = isPrivate;
  }

  setPrestige(prestige: string) {
    this.prestige = Number(prestige);
  }

  getGameConfig() {
    return {
      hostUserId: this.hostId,
      gameType: this.gameType,
      private: this.private,
      onGoing: false, // this will change to true when sent in server
      price: this.price,
      friendsOnly: this.firendsOnly,
      prestige: this.prestige
    } as unknown as GameConfig;
  }

  reset() {
    this.gameType = '';
    this.price = 0;
    this.firendsOnly = false;
  }
}
