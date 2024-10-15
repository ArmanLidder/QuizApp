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
    where,
} from '@angular/fire/firestore';
import {Observable, of, switchMap} from 'rxjs';
import {User} from "@app/interfaces/user/user-data.interface";
import {Auth, authState} from "@angular/fire/auth";


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

    constructor(private firestore: Firestore, private auth: Auth) {
    }

    get currentUserProfile$(): Observable<User | null> {
        return this.user$.pipe(
            switchMap((user) => {
                if (!user?.uid) return of(null);
                const ref = doc(this.firestore, 'users', user.uid);
                return docData(ref) as Observable<User>;
            })
        );
    }

    getUser(uid: string): Observable<User | null> {
        const userDocRef = doc(this.firestore, `users/${uid}`);
        return docData(userDocRef, { idField: 'uid' }) as Observable<User | null>;
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


    async updateUserAvatar(uid: string, avatarUrl: string): Promise<void> {
        const userDoc = doc(this.firestore, `users/${uid}`);
        await updateDoc(userDoc, { avatar: avatarUrl });
    }

    async updateUser(user: Partial<User>): Promise<void> { // This function needs uid in user input or errors will happen.
        const ref = doc(this.firestore, 'users', user.uid as string);
        await updateDoc(ref, { ...user });
    }

    async addUser(user: Partial<User>): Promise<void> {
        const newUser: User = { ...defaultUser, ...user };
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
        if (isTaken) throw new Error('Ce nom est déja utilisé');
        if (this.auth.currentUser?.uid){
            const userDocRef = doc(this.firestore, `users/${this.auth.currentUser?.uid}`);
            await updateDoc(userDocRef, {username: newUsername});
        } else throw new Error('Erreur: essayez de vous reconnectez.');
    }
}
