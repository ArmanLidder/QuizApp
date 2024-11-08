import { Component, Optional } from '@angular/core';
import { MatDialogRef} from '@angular/material/dialog';
import { Observable } from "rxjs";
import { User } from "@common/interfaces/user-data.interface";
import { FriendService } from "@app/services/friend.service/friend.service";
import { ConfirmationDialogComponent } from "@app/components/confirmation-dialog/confirmation-dialog.component";
import { MatDialog } from "@angular/material/dialog";
import { PopUpMessage } from "@common/browser-message/displayable-message/pop-up-message";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
import {UserSearchDialogComponent} from "@app/components/user-search-dialog/user-search-dialog.component";

@Component({
    selector: 'app-friends',
    templateUrl: './friends.component.html',
    styleUrls: ['./friends.component.scss']
})
export class FriendsComponent {
    friends$: Observable<User[]>;
    pendingRequests$: Observable<User[]>;

    constructor(
        private friendService: FriendService,
        private dialog: MatDialog,
        private snackbar: SnackbarService,
        @Optional() private dialogRef?: MatDialogRef<FriendsComponent>
    ) {}

    ngOnInit(): void {
        this.friends$ = this.friendService.friends$;
        this.pendingRequests$ = this.friendService.friendRequests$;
    }

    closeDialog(): void {
        if (this.dialogRef) {
            this.dialogRef.close();
        }
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
            data: { message: PopUpMessage.DELETE_FRIEND_MESSAGE },
        });

        dialogRef.afterClosed().subscribe(async (result) => {
            if (result) await this.friendService.removeFriend(uid);
        });
    }

    openUserSearch() {
        this.dialog.open(UserSearchDialogComponent, {
            width:'30%',
            minWidth:'30%'
        });
    }
}
