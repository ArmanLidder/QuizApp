import {Component} from '@angular/core';
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {FriendService} from "@app/services/friend.service/friend.service";
import {ConfirmationDialogComponent} from "@app/components/confirmation-dialog/confirmation-dialog.component";
import {MatDialog} from "@angular/material/dialog";
import {PopUpMessage} from "@common/browser-message/displayable-message/pop-up-message";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";

@Component({
    selector: 'app-friends',
    templateUrl: './friends.component.html',
    styleUrls: ['./friends.component.scss']
})
export class FriendsComponent {
    friends$: Observable<User[]>;
    pendingRequests$: Observable<User[]>;

    constructor(private friendService: FriendService, private dialog: MatDialog, private snackbar: SnackbarService) {
    }

    ngOnInit(): void {
        this.friends$ = this.friendService.friends$;
        this.pendingRequests$ = this.friendService.friendRequests$;
    }

    acceptFriendRequest(userId: string): void {
        this.friendService.acceptFriendRequest(userId).then(() => {}).catch(err => {
            this.snackbar.show(err.message);
        });
    }

    denyFriendRequest(userId: string): void {
        this.friendService.denyFriendRequest(userId).then(() => {}).catch(err => {
            this.snackbar.show(err.message);
        });
    }

    async removeConfirmDialog(uid: string) {
        const dialogRef = this.dialog.open(ConfirmationDialogComponent, {
            data: {message: PopUpMessage.DELETE_FRIEND_MESSAGE},
        });

        dialogRef.afterClosed().subscribe(async (result) => {
            if (result) await this.friendService.removeFriend(uid);
        });
    }
}
