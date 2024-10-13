import {Injectable} from '@angular/core';
import {firstValueFrom, from, Observable, switchMap, throwError} from 'rxjs';

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
    // How authState(this.auth) works:
    //
    // If the user is logged in: this.user$ will emit the current user object (with details like uid, email, etc.).
    // If the user is logged out: this.user$ will emit null when the user logs out (triggered by auth.signOut()).

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

    async login(email: string, password: string) {
        // return this.usersService.getUserByEmail(email).pipe(  // Get user data by email first
        //     switchMap((userData) => {
        //         if (userData?.isConnected) {
        //             // If user is already connected, throw an error and don't attempt login
        //             return throwError(() => new Error('Cet utilisateur est déjà connecté.'));
        //         }
        //         // If user is not connected, proceed with the login
        //         return from(signInWithEmailAndPassword(this.auth, email, password)).pipe(
        //             switchMap((userCredential) => {
        //                 const uid = userCredential.user.uid;
        //                 // Set isConnected to true after a successful login
        //                 return this.usersService.updateUser({uid: uid, isConnected: true});
        //             })
        //         );
        //     })
        // );
        const userData = await firstValueFrom(this.usersService.getUserByEmail(email));
        if (userData?.isConnected) throw new Error('Cet utilisateur est déjà connecté.');
        const userCredential = await signInWithEmailAndPassword(this.auth, email, password);
        const uid = userCredential.user.uid;
        await firstValueFrom(this.usersService.updateUser({ uid: uid, isConnected: true }));

    }


    async logout() {
        const user = await firstValueFrom(this.usersService.currentUserProfile$)
        const updatedUser: Partial<User> = {uid: user?.uid, isConnected: false};
        await firstValueFrom(this.usersService.updateUser(updatedUser));
        await this.auth.signOut();
    }
}