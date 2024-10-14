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
    where, getDoc,
} from '@angular/fire/firestore';
import {from, map, Observable, of, switchMap} from 'rxjs';
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

    getUser(uid: string): Observable<User | undefined> {
        const userDocRef = doc(this.firestore, `users/${uid}`);
        return from(getDoc(userDocRef)).pipe(
            map((docSnapshot) => {
                if (docSnapshot.exists()) {
                    return docSnapshot.data() as User; // Return user data if document exists
                } else {
                    return undefined; // Return undefined if no document is found
                }
            })
        );
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
        const lowerCaseUsername = username.toLowerCase();
        const usersRef = collection(this.firestore, 'users');

        const q = query(usersRef, where('username', '>=', lowerCaseUsername), where('username', '<=', lowerCaseUsername + '\uf8ff'));
        const querySnapshot = await getDocs(q);

        return querySnapshot.docs.some(doc =>
            (doc.data().username as string).toLowerCase() === lowerCaseUsername
        );
    }

    async updateUsername(newUsername: string): Promise<string> {
        const lowerCaseUsername = newUsername.toLowerCase();
        const isTaken = await this.isUsernameTaken(lowerCaseUsername);
        if (isTaken) throw new Error('This username is already taken.');
        if (this.auth.currentUser?.uid){
            const userDocRef = doc(this.firestore, `users/${this.auth.currentUser?.uid}`);
            await updateDoc(userDocRef, {username: lowerCaseUsername});
            return 'Username updated successfully.';
        } else throw new Error('User not found or not authenticated.');
    }
}
