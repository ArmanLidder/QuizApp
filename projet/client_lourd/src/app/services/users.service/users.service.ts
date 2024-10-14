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

    getUser(uid: string): Observable<User | null> {
        const userDocRef = doc(this.firestore, `users/${uid}`);
        return docData(userDocRef, { idField: 'uid' }) as Observable<User | null>;
    }

    updateUserAvatar(uid: string, avatarUrl: string): Observable<void> {
        const userDoc = doc(this.firestore, `users/${uid}`);
        return from(updateDoc(userDoc, {avatar: avatarUrl}));
    }

    addUser(user: Partial<User>): Observable<void> {
        // Function does not need all the values of User interface, the missing ones are populated using defaultUser
        const newUser: User = {...defaultUser, ...user};
        const ref = doc(this.firestore, 'users', newUser.uid);
        return from(setDoc(ref, newUser));
    }

    updateUser(user: Partial<User>): Observable<void> { // This function needs uid in user input or errors will happen.
        const ref = doc(this.firestore, 'users', user.uid as string);
        return from(updateDoc(ref, { ...user }));
    }


    isUsernameTaken(username: string): Observable<boolean> {
        const usersRef = collection(this.firestore, 'users');
        const q = query(usersRef, where('username', '==', username));
        return from(getDocs(q)).pipe(
            map((querySnapshot) => {
                return !querySnapshot.empty; // Returns true if the username is found, otherwise false
            })
        );
    }

    getUserByEmail(email: string): Observable<User | undefined> {
        const usersRef = collection(this.firestore, 'users');
        const q = query(usersRef, where('email', '==', email));
        return from(getDocs(q)).pipe(
            map((querySnapshot) => {
                if (!querySnapshot.empty) {
                    const userDoc = querySnapshot.docs[0]; // Assuming email is unique
                    return userDoc.data() as User;
                } else {
                    return undefined;
                }
            })
        );
    }
}
