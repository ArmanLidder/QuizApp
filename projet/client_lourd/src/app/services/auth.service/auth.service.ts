import {Injectable} from '@angular/core';

import {
    Auth, authState,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
} from '@angular/fire/auth';

import {setPersistence, browserSessionPersistence} from "firebase/auth";
import {UsersService} from "@app/services/users.service/users.service";
import {AvatarService} from "@app/services/avatar.service/avatar.service";
import {first, switchMap} from "rxjs";
import {map} from "rxjs/operators";
import {TranslateService} from "@ngx-translate/core";
import {randomDelay} from "../../../utils/random-time-waiter/random-time-waiter";


@Injectable({
    providedIn: 'root'
})
export class AuthService {
    // How authState(this.auth) works:
    //
    // If the user is logged in: this.user$ will emit the current user object (with details like uid, email, etc.).
    // If the user is logged out: this.user$ will emit null when the user logs out (triggered by auth.signOut()).

    readonly user$ = authState(this.auth).pipe(
        switchMap(firebaseUser =>
            firebaseUser
                ? this.usersService.getUserByEmail(firebaseUser.email!)
                : Promise.resolve(null)
        )
    );

    constructor(private auth: Auth,
                private usersService: UsersService,
                private avatarService: AvatarService,
                private translate: TranslateService) {
    }

    async register(username: string, email: string, password: string, selectedAvatar: string | File): Promise<void> {
        await randomDelay(500,2500);
        const isTakenOne = await this.usersService.isUsernameTaken(username);
        await randomDelay(500,2500);
        const isTakenTwo = await this.usersService.isUsernameTaken(username);
        if (isTakenOne || isTakenTwo) throw new Error(this.translate.instant('REGISTER_PAGE.THE_NAME_IS_ALREADY_USED',{name:username}));
        try {
            //This delay was added because firebase has a bug where two uid's with same
            //email can be created if both users create an account at the exact same time
            await randomDelay(500,2500);
            const {user} = await createUserWithEmailAndPassword(this.auth, email, password);
            await this.usersService.addUser({uid: user.uid, email, username});
            await this.avatarService.handleAvatarModification(selectedAvatar);

            await this.user$.pipe(
                map(user => !!user),
                first(isReady => isReady)  // Wait for first truthy value
            ).toPromise();
            await this.usersService.addLogEvent('login');
        } catch (error: any) {
            const frenchErrorMessage = this.mapFirebaseAuthError(error.code);
            throw new Error(frenchErrorMessage);
        }
    }


    async login(email: string, password: string): Promise<void> {
        const existingUser = await this.usersService.getUserByEmail(email);
        if (existingUser?.isConnected) {
            throw new Error(this.translate.instant('LOGIN_PAGE.USER_ALREADY_CONNECTED'));
        }
        try {
            setPersistence(this.auth, browserSessionPersistence).then(()=>{
                return signInWithEmailAndPassword(this.auth, email, password);
            })
            await this.user$.pipe(
                map(user => !!user),
                first(isReady => isReady)  // Wait for first truthy value
            ).toPromise();
        } catch (error: any) {
            console.error('Login error:', error);
            await this.auth.signOut();
            throw new Error(this.mapFirebaseAuthError(error.code));
        }
        try {
            await this.usersService.addLogEvent('login');
        } catch (error:any) {
            console.error('Login error:', error);
            await this.auth.signOut();
            throw new Error(error.message);
        }
    }

    async logout(): Promise<void> {
        await this.usersService.addLogEvent('logout');
        return await this.auth.signOut();
    }

    private mapFirebaseAuthError(errorCode: string): string {
        switch (errorCode) {
            case 'auth/invalid-email':
                return this.translate.instant('LOGIN_PAGE.INVALID_EMAIL');
            case 'auth/invalid-credential':
                return this.translate.instant('LOGIN_PAGE.INVALID_CREDENTIAL');
            case 'auth/user-disabled':
                return this.translate.instant('LOGIN_PAGE.USER_DISABLED');
            case 'auth/user-not-found':
                return this.translate.instant('LOGIN_PAGE.USER_NOT_FOUND');
            case 'auth/wrong-password':
                return this.translate.instant('LOGIN_PAGE.WRONG_PASSWORD');
            case 'auth/email-already-in-use':
                return this.translate.instant('LOGIN_PAGE.EMAIL_ALREADY_IN_USE');
            case 'auth/weak-password':
                return this.translate.instant('LOGIN_PAGE.WEAK_PASSWORD');
            case 'auth/operation-not-allowed':
                return this.translate.instant('LOGIN_PAGE.OPERATION_NOT_ALLOWED');
            case 'auth/network-request-failed':
                return this.translate.instant('LOGIN_PAGE.NETWORK_REQUEST_FAILED');
            case 'auth/requires-recent-login':
                return this.translate.instant('LOGIN_PAGE.REQUIRES_RECENT_LOGIN');
            default:
                return this.translate.instant('LOGIN_PAGE.UNKNOWN_ERROR');
        }
    }
}