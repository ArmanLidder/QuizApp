import {Injectable} from '@angular/core';
import {UsersService} from "@app/services/users.service/users.service";
import {firstValueFrom, Observable, switchMap, of, combineLatest, map} from "rxjs";
import {User, FriendRequest} from "@common/interfaces/user-data.interface";

import {
    doc,
    Firestore,
    runTransaction,
    arrayRemove,
    updateDoc,
} from '@angular/fire/firestore';
import {TranslateService} from "@ngx-translate/core";
//TODO refactor other functions to be similar to the deleteFriends one at the bottom of this file
@Injectable({
    providedIn: 'root'
})
export class FriendService {

    constructor(private firestore: Firestore, private usersService: UsersService,private translate: TranslateService) {
    }

    get friends$(): Observable<User[]> {
        return this.usersService.currentUserProfile$.pipe(
            switchMap((currentUser: User | null) => {
                if (!currentUser || !currentUser.friends || currentUser.friends.length === 0) {
                    return of([] as User[]);
                }

                const friendObservables: Observable<User | null>[] = currentUser.friends.map((friendId: string) =>
                    this.usersService.getUser(friendId)
                );

                // Combine all the individual friend observables into a single observable that emits an array of users
                return combineLatest(friendObservables).pipe(
                    // Filter out any null values in case some users don't exist
                    map((friends: (User | null)[]) => friends.filter(friend => !!friend) as User[])
                );
            })
        );
    }

    get friendRequests$(): Observable<User[]> {
        return this.usersService.currentUserProfile$.pipe(
            switchMap((currentUser: User | null) => {
                if (!currentUser || !currentUser.friendRequests || currentUser.friendRequests.length === 0) {
                    return of([]); // Return an empty array if no pending friend requests
                }

                const friendRequestObservables: Observable<User | null>[] = currentUser.friendRequests.map(
                    (request: FriendRequest) => this.usersService.getUser(request.fromUserId)
                );

                // Combine all the individual user observables into a single observable that emits an array of users
                return combineLatest(friendRequestObservables).pipe(
                    // Filter out any null values in case some users don't exist
                    map((users: (User | null)[]) => users.filter(user => !!user) as User[])
                );
            })
        );
    }

    async sendFriendRequest(toUserId: string) {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$); // Get current user
        if (!currentUser) throw new Error('Erreur de authentification, reconnectez vous');

        // Check if a friend request from the target user already exists
        const existingRequest = currentUser.friendRequests.find(
            (request: FriendRequest) => request.fromUserId === toUserId
        );

        if (existingRequest) {
            await this.acceptFriendRequest(toUserId);
            return;
        } else {
            // Otherwise, proceed with sending a new friend request
            const friendRequest: FriendRequest = {
                fromUserId: currentUser.uid,
                toUserId: toUserId,
            };
            const userDocRef = doc(this.firestore, `users/${toUserId}`);

            return runTransaction(this.firestore, async (transaction) => {
                const userDoc = await transaction.get(userDocRef);
                if (!userDoc.exists) throw new Error("L'utilisateur n'existe plus");

                const friendRequests = userDoc.data()?.friendRequests || [];

                const existingOutgoingRequest = friendRequests.find(
                    (req: any) => req.fromUserId === currentUser.uid
                );
                if (existingOutgoingRequest) throw new Error(this.translate.instant('FRIENDS.ALREADY_SENT_ERROR'));

                transaction.update(userDocRef, {
                    friendRequests: [...friendRequests, friendRequest],
                });
            });
        }
    }


    async acceptFriendRequest(fromUserId: string) {
        // Get the current user
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        if (!currentUser) throw new Error('Erreur d\'authentification. Veuillez vous reconnecter.');
        const toUserId = currentUser.uid;

        // Define document references
        const currentUserDocRef = doc(this.firestore, `users/${toUserId}`);
        const fromUserDocRef = doc(this.firestore, `users/${fromUserId}`);

        return runTransaction(this.firestore, async (transaction) => {
            const currentUserDoc = await transaction.get(currentUserDocRef);
            const fromUserDoc = await transaction.get(fromUserDocRef);

            if (!currentUserDoc.exists() || !fromUserDoc.exists()) throw new Error('Un ou les deux utilisateurs n\'existent plus.');

            const currentFriendRequests = currentUserDoc.data()?.friendRequests || [];
            const currentFriends = currentUserDoc.data()?.friends || [];

            const friendRequest = currentFriendRequests.find(
                (req: any) => req.fromUserId === fromUserId
            );
            if (!friendRequest) throw new Error('Demande d\'ami introuvable ou déjà traitée.');

            const updatedFriendRequests = currentFriendRequests.filter(
                (req: FriendRequest) => req.fromUserId !== fromUserId
            );

            const fromUserFriends = fromUserDoc.data()?.friends || [];

            transaction.update(currentUserDocRef, {
                friendRequests: updatedFriendRequests,
                friends: [...currentFriends, fromUserId]
            });

            transaction.update(fromUserDocRef, {
                friends: [...fromUserFriends, toUserId]
            });
        });
    }

    async denyFriendRequest(deniedUserId: string) {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        if (!currentUser) throw new Error('Erreur d\'authentification. Veuillez vous reconnecter.');
        const uid = currentUser.uid;
        const currentUserDocRef = doc(this.firestore, `users/${uid}`);
        return runTransaction(this.firestore, async (transaction) => {
            const currentUserDoc = await transaction.get(currentUserDocRef);

            const currentFriendRequests = currentUserDoc.data()?.friendRequests || [];

            const updatedFriendRequests = currentFriendRequests.filter(
                (req: FriendRequest) => req.fromUserId !== deniedUserId //Keep every friend request exceptt the one from userId
            );

            transaction.update(currentUserDocRef, {
                friendRequests: updatedFriendRequests,
            });
        });
    }

    async removeFriend(unfriendedUserId: string) {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        if (!currentUser) throw new Error('Erreur d\'authentification. Veuillez vous reconnecter.');
        const toUserId = currentUser.uid;
        const currentUserDocRef = doc(this.firestore, `users/${toUserId}`);
        const unfriendedUserDocRef = doc(this.firestore, `users/${unfriendedUserId}`);
        await updateDoc(currentUserDocRef, {friends: arrayRemove(unfriendedUserId)});
        await updateDoc(unfriendedUserDocRef, {friends: arrayRemove(toUserId)});
    }

    hasPendingRequest(user: Observable<User>): Observable<boolean> {
        return combineLatest([
            this.usersService.currentUserProfile$,
            user
        ]).pipe(
            map(([currentUser, viewedUser]) => {
                if (!currentUser || !viewedUser) return false;
                return viewedUser.friendRequests?.some(
                    request => request.fromUserId === currentUser.uid
                ) ?? false;
            })
        );
    }
    isFriend(user: Observable<User>): Observable<boolean> {
        return combineLatest([
            this.usersService.currentUserProfile$,
            user
        ]).pipe(
            map(([currentUser, viewedUser]) => {
                if (!currentUser || !viewedUser) return false;
                return currentUser.friends?.includes(viewedUser.uid) ?? false;
            })
        );
    }

}
