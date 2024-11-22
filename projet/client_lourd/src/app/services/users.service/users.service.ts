import {Injectable} from '@angular/core';
import {
    doc,
    docData,
    Firestore,
    setDoc,
    updateDoc,
    query,
    collection,
    getDocs,
    where, collectionData,
} from '@angular/fire/firestore';
import {catchError, firstValueFrom, Observable, of, shareReplay, map, BehaviorSubject, switchMap} from 'rxjs';
import {User} from "@app/interfaces/user/user-data.interface";
import {Auth, authState} from "@angular/fire/auth";
import {LoginHistory} from "@common/interfaces/user-data.interface";
import {ServerTimeService} from "@app/services/server-time.service/server-time.service";
import {TranslateService} from "@ngx-translate/core";

const defaultUser: User = {
    uid: '',
    email: '',
    username: '',
    avatar: '',
    friends: [],
    currency: 0,
    achievements: [],
    level: 0,
    prestige: 0,
    isConnected: false,
    stats: {
        gamesPlayed: 0,
        gamesWon: 0,
        avgCorrectAnswers: 0,
        avgGameTime: 0,
        correctAnswers: 0,
        gameTime: 0,
    },
    loginHistory: [],
    gameHistory: [],
    friendRequests: [],
    settings: {
        theme: 'light',
        language: 'en',
        notificationsEnabled: true,
    },
};

@Injectable({
    providedIn: 'root'
})
export class UsersService {
    user$ = authState(this.auth);
    userProfile$: Observable<User | null> | undefined;
    private userProfileSubject$ = new BehaviorSubject<Observable<User | null>>(of(null));

    constructor(private firestore: Firestore,
                private auth: Auth,
                private serverTimeService: ServerTimeService,
                private translate: TranslateService) {
        this.user$.subscribe(async (user) => {
            if (user) {
                this.userProfile$ = this.createUserProfileObservable(user.uid);
                this.userProfileSubject$.next(this.userProfile$);
            } else if (!user) { //logout
                this.userProfile$ = undefined;
                this.userProfileSubject$.next(of(null));
            }
        });
    }

    get currentUserProfile$(): Observable<User | null> {
        return this.userProfileSubject$.pipe(switchMap(obs => obs));
    }

    private createUserProfileObservable(uid: string): Observable<User | null> {
        const ref = doc(this.firestore, 'users', uid);
        console.log(`Adding a read because of a getUserProfile`);
        return docData(ref).pipe(
            map(data => data as User),
            catchError(error => {
                console.error('Error fetching user profile:', error);
                return of(null);
            }),
            shareReplay(1) // Cache the latest result for all subscribers
        );
    }

    getUser(uid: string): Observable<User | null> {
        const userDocRef = doc(this.firestore, `users/${uid}`);
        return docData(userDocRef, {idField: 'uid'}) as Observable<User | null>;
    }

    getAllUsers(): Observable<User[] | null> {
        const userCollectionRef = collection(this.firestore, `users`);
        return collectionData(userCollectionRef) as Observable<User[] | null>;
    }

    async updateUser(user: Partial<User>): Promise<void> {
        const currentUser = await firstValueFrom(this.user$);
        const uid = currentUser?.uid;
        const ref = doc(this.firestore, 'users', uid as string);
        await updateDoc(ref, {...user});
    }

    async addUser(user: Partial<User>): Promise<void> {
        const newUser: User = {...defaultUser, ...user};
        const ref = doc(this.firestore, 'users', newUser.uid);
        await setDoc(ref, newUser);
    }

    async isUsernameTaken(username: string): Promise<boolean> {
        const usersRef = collection(this.firestore, 'users');
        const q = query(usersRef, where('username', '==', username));
        const querySnapshot = await getDocs(q);
        return !querySnapshot.empty;
    }

    async updateUsername(newUsername: string): Promise<void> {
        const isTaken = await this.isUsernameTaken(newUsername);
        if (isTaken) throw new Error(await firstValueFrom(this.translate.get('USERNAME_MODIFICATION.ALREADY_USED')));
        if (this.auth.currentUser?.uid) {
            const userDocRef = doc(this.firestore, `users/${this.auth.currentUser?.uid}`);
            await updateDoc(userDocRef, {username: newUsername});
        }
    }

    async addLogEvent(event: 'login' | 'logout'): Promise<void> {
        const currentUser = await firstValueFrom(this.currentUserProfile$)
        const time = await this.serverTimeService.getServerTime();
        const loginEvent: LoginHistory = {
            eventType: event,
            timestamp: time,
        };
        await this.updateUser({
            isConnected: event === 'login',
            loginHistory: [...currentUser?.loginHistory || [], loginEvent], // Append new login event
        });
    }

    async getUserByEmail(email: string): Promise<User | undefined> {
        const usersRef = collection(this.firestore, 'users');
        const q = query(usersRef, where('email', '==', email));
        const querySnapshot = await getDocs(q);

        if (!querySnapshot.empty) {
            const userDoc = querySnapshot.docs[0]; // Assuming email is unique
            return userDoc.data() as User;
        } else return undefined;
    }
}
