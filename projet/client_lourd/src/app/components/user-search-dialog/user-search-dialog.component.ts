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

    allUsers: { user: User; hasPending: boolean }[] = []; // Pre-loaded users
    searchTerm: string = ''; // Add this property to store the search term


    ngOnInit() {
        this.currentUser$ = this.usersService.currentUserProfile$;

        combineLatest([this.usersService.getAllUsers(), this.currentUser$])
            .pipe(
                switchMap(([allUsers, currentUser]) => {
                    if (!allUsers || !currentUser) return of([]);

                    const preFilteredUsers = allUsers.filter(
                        (user) =>

                            user.uid !== currentUser.uid &&
                            !currentUser.friends.includes(user.uid)
                    );

                    return combineLatest(
                        preFilteredUsers.map((user) =>

                            this.friendService

                                .hasPendingRequest(of(user))
                                .pipe(map((hasPending) => ({ user, hasPending })))
                        )
                    );
                })
            )
            .subscribe((usersWithPendingStatus) => {
                this.allUsers = usersWithPendingStatus;
            });

        // Update `searchTerm` whenever the search control changes

        this.searchControl.valueChanges

            .pipe(startWith(''), debounceTime(30), distinctUntilChanged())
            .subscribe((searchTerm) => {
                this.searchTerm = (searchTerm ?? '').toLowerCase(); // Ensure it's a string

            });
    }

    applyFilter(user: { user: User; hasPending: boolean }): boolean {
        if (!this.searchTerm) return true; // Show all users if no search term

        return user.user.username.toLowerCase().includes(this.searchTerm);
    }


    trackByUserId(index: number, item: { user: User; hasPending: boolean }): string {
        return item.user.uid;
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
