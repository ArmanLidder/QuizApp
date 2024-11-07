import { Component, inject, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { UsersService } from '@app/services/users.service/users.service';
import {Observable, combineLatest, of, switchMap} from 'rxjs';
import { map, startWith, debounceTime, distinctUntilChanged,} from 'rxjs/operators';
import { User } from '@app/interfaces/user/user-data.interface';
import { FormControl } from '@angular/forms';
import { FriendService } from '@app/services/friend.service/friend.service';
import { SnackbarService } from '@app/services/snackbar.service/snack-bar.service';

@Component({
    selector: 'app-user-search-dialog',
    templateUrl: './user-search-dialog.component.html',
    styleUrls: ['./user-search-dialog.component.scss'],
})
export class UserSearchDialogComponent implements OnInit {
    readonly dialogRef = inject(MatDialogRef<UserSearchDialogComponent>);
    private usersService = inject(UsersService);
    private friendService = inject(FriendService);
    private snackbar = inject(SnackbarService);

    searchControl = new FormControl('');
    filteredUsers$: any;
    currentUser$: Observable<User | null>;
    hasPendingRequest$: Observable<boolean>;

    ngOnInit() {
        this.currentUser$ = this.usersService.currentUserProfile$;
        const allUsers$ = this.usersService.getAllUsers();

        this.filteredUsers$ = combineLatest([
            this.searchControl.valueChanges.pipe(
                startWith(''),
                debounceTime(300),
                distinctUntilChanged()
            ),
            this.currentUser$,
            allUsers$,
        ]).pipe(
            switchMap(([searchTerm, currentUser, allUsers]) => {
                if (!allUsers || !currentUser) return of([]);

                const filteredUsers = allUsers.filter(
                    (user) =>
                        user.uid !== currentUser.uid &&
                        !currentUser.friends.includes(user.uid)
                );

                const searchedUsers = !searchTerm
                    ? filteredUsers
                    : filteredUsers.filter((user) =>
                        user.username.toLowerCase().includes(searchTerm.toLowerCase())
                    );

                // Check pending status for each user using FriendService's hasPendingRequest function
                return combineLatest(
                    searchedUsers.map((user) =>
                        this.friendService
                            .hasPendingRequest(of(user))
                            .pipe(map((hasPending) => ({ user, hasPending })))
                    )
                );
            })
        );
    }

    close() {
        this.dialogRef.close();
    }

    async sendFriendRequest(user: User) {
        try {
            await this.friendService.sendFriendRequest(user.uid);
        } catch (error: any) {
            this.snackbar.show(error.message);
        }
    }

    hasPendingRequest(user: User, pendingUser: User | null): boolean {
        if (!pendingUser) return false;
        return user.friendRequests.some(
            (request) =>
                request.fromUserId === pendingUser.uid &&
                request.toUserId === user.uid
        );
    }
}
