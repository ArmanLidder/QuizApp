import {Injectable} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {BehaviorSubject} from "rxjs";
import {GameService} from "@app/services/game.service/game.service";

@Injectable({
    providedIn: 'root'
})
export class ObserverCounterService {
    private obsCountSubject = new BehaviorSubject<number>(0);
    public obsCounter$ = this.obsCountSubject.asObservable();

    constructor(private socketService: SocketClientService, private gameService: GameService) {
        this.initialize();
    }

    initialize() {
        // Send initial request
        this.socketService.send(SocketEvent.GET_OBS_COUNT, this.gameService.gameRealService.roomId);

        // Listen for updates
        if (this.socketService.isSocketAlive()) {
            this.handleUpdateCounter();
        }
    }

    private handleUpdateCounter() {
        this.socketService.on(SocketEvent.UPDATE_OBS_COUNT, (count: number) => {
            this.obsCountSubject.next(0);
            this.obsCountSubject.next(count);
            console.log(count);
        });
    }
}
