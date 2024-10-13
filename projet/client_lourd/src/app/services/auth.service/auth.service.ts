import {Injectable} from '@angular/core';
import {firstValueFrom, from, Observable, of, switchMap, throwError} from 'rxjs';

import {
    Auth, authState,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
} from '@angular/fire/auth';
import {UsersService} from "@app/services/users.service/users.service";
import {User} from "@common/interfaces/user-data.interface";


@Injectable({
    providedIn: 'root'
})
export class AuthService {

    user$ = authState(this.auth);

    constructor(private auth: Auth, private usersService: UsersService) {
    }

    register(username: string, email: string, password: string): Observable<any> {
        return this.usersService.isUsernameTaken(username).pipe(
            switchMap(isTaken => {
                if (isTaken) return throwError(() => new Error(`Le nom "${username}" est déja utilisé`));
                return from(createUserWithEmailAndPassword(this.auth, email, password));
            })
        );
    }

    login(email: string, password: string): Observable<void> {
        return this.usersService.getUserByEmail(email).pipe(  // Get user data by email first
            switchMap((userData) => {
                if (userData?.isConnected) {
                    // If user is already connected, throw an error and don't attempt login
                    return throwError(() => new Error('Cet utilisateur est déjà connecté.'));
                }
                // If user is not connected, proceed with the login
                return from(signInWithEmailAndPassword(this.auth, email, password)).pipe(
                    switchMap((userCredential) => {
                        const uid = userCredential.user.uid;
                        // Set isConnected to true after a successful login
                        return this.usersService.updateUser({uid: uid, isConnected: true});
                    })
                );
            })
        );
    }


    async logout() {
        // return this.user$.pipe(
        //     switchMap(user => {
        //         if (user) {
        //             console.log("changing is")
        //             const updatedUser: Partial<User> = { uid: user.uid, isConnected: false };
        //             return this.usersService.updateUser(updatedUser).pipe(
        //                 switchMap(() => {
        //                     this.user$ = of(null);
        //                     return from(this.auth.signOut());
        //                 })
        //             );
        //         }
        //         return from(this.auth.signOut());
        //     })
        // );
        const user = await firstValueFrom(this.usersService.currentUserProfile$)
        const updatedUser: Partial<User> = {uid: user?.uid, isConnected: false};
        await firstValueFrom(this.usersService.updateUser(updatedUser));
        this.user$ = of(null);
        await this.auth.signOut();
    }
}