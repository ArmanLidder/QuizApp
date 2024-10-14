import {Injectable} from '@angular/core';
import {firstValueFrom, from, Observable, switchMap, throwError} from 'rxjs';
import {serverTimestamp } from "firebase/firestore";
import {Timestamp} from "firebase/firestore";

import {
    Auth, authState,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
} from '@angular/fire/auth';

import {UsersService} from "@app/services/users.service/users.service";
import {LoginHistory} from "@app/interfaces/user/user-data.interface";
export const timestampToDate = (timestamp: Timestamp) => {
    const unixTimestamp = (timestamp.seconds + timestamp.nanoseconds * 10**-9) * 1000;
    return new Date(unixTimestamp);
};

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

    async login(email: string, password: string): Promise<void> {

        const userData = await firstValueFrom(this.usersService.getUserByEmail(email));
        if (userData?.isConnected)throw new Error('Cet utilisateur est déjà connecté.');

        const userCredential = await signInWithEmailAndPassword(this.auth, email, password);
        const uid = userCredential.user.uid;

        const loginEvent:LoginHistory = {
            eventType: 'login',
            timestamp: serverTimestamp(),
        };

        await firstValueFrom(this.usersService.updateUser({
            uid: uid,
            isConnected: true,
            loginHistory: [...(userData?.loginHistory || []), loginEvent], // Append the new login event
        }));
    }



    async logout(): Promise<void> {
        const user = await firstValueFrom(this.usersService.currentUserProfile$);
        if (user) {
            const logoutEvent: LoginHistory = {
                eventType: 'logout',
                timestamp: serverTimestamp(),
            };

            await firstValueFrom(this.usersService.updateUser({
                uid: user.uid,
                isConnected: false,
                loginHistory: [...(user.loginHistory || []), logoutEvent], // Append the new logout event
            }));
        }
        await this.auth.signOut();
    }

}