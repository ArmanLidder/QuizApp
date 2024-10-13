import { Injectable } from '@angular/core';
import { Firestore, doc, getDoc } from '@angular/fire/firestore';
import {Observable, from, switchMap} from 'rxjs';
import { map } from 'rxjs/operators';
import {
    getDownloadURL,
    ref,
    Storage,
    uploadBytes,
} from '@angular/fire/storage';

@Injectable({
    providedIn: 'root',
})
export class AvatarService {
    constructor(private firestore: Firestore, private storage: Storage) {}

    uploadAvatar(uid: string, image: File): Observable<string> {
        const storageRef = ref(this.storage, `user_avatars/${uid}/${image.name}`);
        const uploadTask = from(uploadBytes(storageRef, image));
        return uploadTask.pipe(switchMap((result) => getDownloadURL(result.ref)));
    }


    getDefaultAvatarUrls(): Observable<string[]> {
        const docRef = doc(this.firestore, 'assets', 'default_avatars');
        return from(getDoc(docRef)).pipe(
            map(docSnap => {
                if (docSnap.exists()) {
                    return docSnap.data()['avatarURLS'];
                } else {
                    console.log("No such document!");
                    return [];
                }
            })
        );
    }
}