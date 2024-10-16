import {Component, inject, OnInit, OnDestroy} from '@angular/core';
import {MatDialogRef} from "@angular/material/dialog";
import {UsersService} from "@app/services/users.service/users.service";
import {Observable, of} from "rxjs";
import {map, startWith, debounceTime, distinctUntilChanged, switchMap} from "rxjs/operators";
import {User} from "@app/interfaces/user/user-data.interface";
import {FormControl} from "@angular/forms";
import {FriendService} from "@app/services/friend.service/friend.service";
import {SnackbarService} from "@app/services/snackbar.service/snack-bar.service";

@Component({
    selector: 'app-user-search-dialog',
    templateUrl: './user-search-dialog.component.html',
    styleUrls: ['./user-search-dialog.component.scss']
})
export class UserSearchDialogComponent implements OnInit, OnDestroy {
    readonly dialogRef = inject(MatDialogRef<UserSearchDialogComponent>);
    private usersService = inject(UsersService);
    private friendService = inject(FriendService);
    private snackbar = inject(SnackbarService);

    searchControl = new FormControl('');
    filteredUsers$: Observable<User[]>;
    currentUser$: Observable<User|null>
    ngOnInit() {
        this.currentUser$ = this.usersService.currentUserProfile$;
        this.filteredUsers$ = this.searchControl.valueChanges.pipe(
            startWith(''),
            debounceTime(300), // Wait for 300ms to reduce unnecessary calls
            distinctUntilChanged(),
            switchMap(searchTerm => {
                if (!searchTerm) return of([]);  // Return an observable of an empty array

                return this.usersService.currentUserProfile$.pipe(
                    switchMap(currentUser =>
                        this.usersService.getAllUsers().pipe(
                            map(users =>
                                (users || []).filter(user =>
                                    user.username.toLowerCase().includes(searchTerm.toLowerCase()) &&
                                    user.uid !== currentUser?.uid &&
                                    !currentUser?.friends.includes(user.uid)
                                )
                            )
                        )
                    )
                );
            })
        );
    }


    ngOnDestroy() {

    }

    close() {
        this.dialogRef.close();
    }

    async sendFriendRequest(user: User) {
        try {
            await this.friendService.sendFriendRequest(user.uid);
        } catch (error:any) {
            this.snackbar.show(error.message);
        }
    }

    hasPendingRequest(user: User, pendingUser: User | null): boolean {
        if (!pendingUser) return false;
        return user.friendRequests.some(request =>
            request.fromUserId === pendingUser.uid && request.toUserId === user.uid
        );
    }

}