import { Component } from '@angular/core';
import {firstValueFrom, Observable} from "rxjs";
import {FriendRequest, User} from "@common/interfaces/user-data.interface";
import { FriendService } from "@app/services/friend.service/friend.service";
import { ConfirmationDialogComponent } from "@app/components/confirmation-dialog/confirmation-dialog.component";
import { MatDialog } from "@angular/material/dialog";
import { PopUpMessage } from "@common/browser-message/displayable-message/pop-up-message";
import { SnackbarService } from "@app/services/snackbar.service/snack-bar.service";
import {UserSearchDialogComponent} from "@app/components/user-search-dialog/user-search-dialog.component";
import {TranslateService} from "@ngx-translate/core";
import {UsersService} from "@app/services/users.service/users.service";

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
        private translate: TranslateService,
        private usersService: UsersService
    ) {}

    async ngOnInit() {
        this.friends$ = this.friendService.friends$;
        this.pendingRequests$ = this.friendService.friendRequests$;

        let currentUser = await firstValueFrom(this.usersService.currentUserProfile$);

        //If for some reason the person who sent me a friendRequest has me in their incoming FriendRequests, accept it automatically
        if (currentUser) {
            this.pendingRequests$.subscribe((pendingRequests: User[]) => {
                const matchingRequest = pendingRequests.find((request: User) =>
                    request.friendRequests.some((friendRequest: FriendRequest) => friendRequest.fromUserId === currentUser?.uid)
                );

                if (matchingRequest) {
                    this.acceptFriendRequest(matchingRequest.uid);
                }
            });
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
            data: { message: this.translate.instant( PopUpMessage.DELETE_FRIEND_MESSAGE) },
        });

        dialogRef.afterClosed().subscribe(async (result) => {
            if (result) await this.friendService.removeFriend(uid);
        });
    }

    openUserSearch() {
        this.dialog.open(UserSearchDialogComponent, {
            width: 'auto',
            minWidth:'30%'
        });
    }
}
