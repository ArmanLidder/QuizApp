import {Component} from '@angular/core';
import {Observable} from "rxjs";
import {User} from "@common/interfaces/user-data.interface";
import {FriendService} from "@app/services/friend.service/friend.service";

@Component({
    selector: 'app-friends',
    templateUrl: './friends.component.html',
    styleUrls: ['./friends.component.scss']
})
export class FriendsComponent {
    friends$: Observable<User[]>;
    pendingRequests$: Observable<User[]>;

    constructor(private friendService: FriendService) {
    }

    ngOnInit(): void {
        this.friends$ = this.friendService.friends$;
        this.pendingRequests$ = this.friendService.friendRequests$;
    }

    acceptFriendRequest(userId: string): void {
        this.friendService.acceptFriendRequest(userId).then(() => {
            console.log('Friend request accepted.');
        }).catch(err => {
            console.error('Error accepting friend request:', err);
        });
    }

    denyFriendRequest(userId: string): void {
        this.friendService.denyFriendRequest(userId).then(() => {
            console.log('Friend request denied.');
        }).catch(err => {
            console.error('Error denying friend request:', err);
        });
    }

}
