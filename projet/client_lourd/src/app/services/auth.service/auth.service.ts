import {Injectable} from '@angular/core';

import {
    Auth, authState,
    signInWithEmailAndPassword,
    createUserWithEmailAndPassword,
} from '@angular/fire/auth';

import {UsersService} from "@app/services/users.service/users.service";
import {AvatarService} from "@app/services/avatar.service/avatar.service";
import {first, switchMap} from "rxjs";
import {map} from "rxjs/operators";


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
                private avatarService: AvatarService) {
    }

    async register(username: string, email: string, password: string, selectedAvatar: string | File): Promise<void> {
        const isTaken = await this.usersService.isUsernameTaken(username);
        if (isTaken) throw new Error(`Le nom "${username}" est déjà utilisé`);
        try {
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
            throw new Error('Cet utilisateur est déjà connecté.');
        }

        try {
            await signInWithEmailAndPassword(this.auth, email, password);
            await this.user$.pipe(
                map(user => !!user),
                first(isReady => isReady)  // Wait for first truthy value
            ).toPromise();

            //we can safely add the log event
            await this.usersService.addLogEvent('login');
        } catch (error: any) {
            console.error('Login error:', error);
            await this.auth.signOut();
            throw new Error(this.mapFirebaseAuthError(error.code));
        }
    }

    async logout(): Promise<void> {
        await this.usersService.addLogEvent('logout');
        return await this.auth.signOut();
    }

    private mapFirebaseAuthError(errorCode: string): string {
        switch (errorCode) {
            case 'auth/invalid-email':
                return "L'adresse e-mail est invalide.";
            case 'auth/invalid-credential':
                return "Courriel et/ou mot de passe incorrect";
            case 'auth/user-disabled':
                return "Le compte de cet utilisateur est désactivé.";
            case 'auth/user-not-found':
                return "Aucun utilisateur trouvé avec cet e-mail.";
            case 'auth/wrong-password':
                return "Le mot de passe est incorrect.";
            case 'auth/email-already-in-use':
                return "Ce courriel est déjà utilisé par un autre compte.";
            case 'auth/weak-password':
                return "Le mot de passe est trop faible.";
            case 'auth/operation-not-allowed':
                return "Cette opération n'est pas autorisée.";
            case 'auth/network-request-failed':
                return "La connexion au réseau a échoué.";
            case 'auth/requires-recent-login':
                return "Veuillez vous reconnecter avant d'effectuer cette opération.";
            default:
                return "Une erreur inconnue s'est produite.";
        }
    }
}