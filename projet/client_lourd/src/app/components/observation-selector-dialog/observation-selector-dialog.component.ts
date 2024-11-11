import {Component, Inject, OnInit} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {SocketEvent} from "@common/socket-event-name/socket-event-name";
import {ObservationService} from "@app/services/observation.service/observation.service";
import {MAT_DIALOG_DATA, MatDialogRef} from "@angular/material/dialog";

@Component({
  selector: 'app-observation-selector-dialog',
  templateUrl: './observation-selector-dialog.component.html',
  styleUrls: ['./observation-selector-dialog.component.scss']
})
export class ObservationSelectorDialogComponent implements OnInit {
  playerObserved: string;

  constructor(
      private socketService: SocketClientService,
      public observationService: ObservationService,
      public dialogRef: MatDialogRef<ObservationSelectorDialogComponent>,
      @Inject(MAT_DIALOG_DATA) public data: { playerObserved: string }
  ) {}

  ngOnInit() {
    this.playerObserved = this.data.playerObserved;
    this.observationService.playersList = [];
    this.observationService.playersList.push(this.observationService.gameConfigs.hostUserId);
    this.receivePlayerList();
    this.getPlayerList();
  }

  closeDialog(): void {
    this.dialogRef.close();
  }

  observe(userId: string): void {
    console.log("observe UserID", userId)
    console.log("current UserId", this.playerObserved)
    this.observationService.observeOtherPlayer(this.playerObserved, userId);
    this.socketService.socket.off(SocketEvent.SENDING_OBSERVER_PLAYER_LIST);
    this.dialogRef.close(userId);
  }

  private getPlayerList() {
    this.socketService.send(SocketEvent.GET_OBSERVER_PLAYER_LIST, this.observationService.gameConfigs.room)
  }

  private receivePlayerList() {
    this.socketService.on(SocketEvent.SENDING_OBSERVER_PLAYER_LIST, (data: string[]) => {
      this.observationService.playersList = [];
      this.observationService.playersList.push(this.observationService.gameConfigs.hostUserId);
      this.observationService.playersList.push(...data);
      console.log(this.observationService.playersList);
    })
  }

}
