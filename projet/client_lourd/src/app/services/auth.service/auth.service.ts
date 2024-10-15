import {Injectable} from '@angular/core';
import {firstValueFrom} from 'rxjs';
import {Timestamp} from "firebase/firestore";

import {
    Auth, authState,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
} from '@angular/fire/auth';

import {UsersService} from "@app/services/users.service/users.service";
import {LoginHistory} from "@app/interfaces/user/user-data.interface";
import {ServerTimeService} from "@app/services/server-time.service/server-time.service";
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

    constructor(private auth: Auth, private usersService: UsersService, private servertimeService : ServerTimeService) {
    }

    async register(username: string, email: string, password: string): Promise<any> {
        const isTaken = await this.usersService.isUsernameTaken(username);
        if (isTaken) throw new Error(`Le nom "${username}" est déjà utilisé`);

        try {
            return await createUserWithEmailAndPassword(this.auth, email, password);
        } catch (error:any) {
            throw new Error('Erreur de création du utilisateur' + error.message);
        }
    }


    async login(email: string, password: string): Promise<void> {
        // Get the user data by email
        const userData = await this.usersService.getUserByEmail(email);
        if (userData?.isConnected) {
            throw new Error('Cet utilisateur est déjà connecté.');
        }

        const userCredential = await signInWithEmailAndPassword(this.auth, email, password);
        const time = await this.servertimeService.getServerTime();

        const loginEvent: LoginHistory = {
            eventType: 'login',
            timestamp: time,
        };

        await this.usersService.updateUser({
            uid: userCredential.user.uid,
            isConnected: true,
            loginHistory: [...(userData?.loginHistory || []), loginEvent], // Append the new login event
        });
    }


    async logout(): Promise<void> {
        const user = await firstValueFrom(this.usersService.currentUserProfile$) ;
        if (user) {
            const time = await this.servertimeService.getServerTime();

            const logoutEvent: LoginHistory = {
                eventType: 'logout',
                timestamp: time,
            };

            await this.usersService.updateUser({
                uid: user.uid,
                isConnected: false,
                loginHistory: [...(user.loginHistory || []), logoutEvent], // Append the new logout event
            });
        }

        await this.auth.signOut();
    }


}