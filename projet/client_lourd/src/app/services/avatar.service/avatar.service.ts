import {Injectable} from '@angular/core';
import {Firestore, doc, getDoc} from '@angular/fire/firestore';
import {Observable, from, firstValueFrom} from 'rxjs';
import {map} from 'rxjs/operators';
import {
    deleteObject,
    getDownloadURL, listAll,
    ref,
    Storage,
    uploadBytes,
} from '@angular/fire/storage';
import {UsersService} from "@app/services/users.service/users.service";

@Injectable({
    providedIn: 'root',
})
export class AvatarService {
    constructor(private firestore: Firestore, private storage: Storage, private usersService: UsersService) {
    }

    async handleAvatarModification(avatarData: File | String) {
        if (!avatarData) return;
        const currentUser = await firstValueFrom(this.usersService.user$);
        const uid = currentUser?.uid;
        if (typeof avatarData === 'string') {
            await this.usersService.updateUser({uid: uid, avatar: avatarData});
            const avataraFileRef = ref(this.storage, `user_avatars/${uid}/avatar.png`);
            try {
                await deleteObject(avataraFileRef);
            } catch {
            }
        } else {
            const newAvatarUrl = await this.uploadAvatar(avatarData as File);
            await this.usersService.updateUser({uid: uid, avatar: newAvatarUrl});
        }
    }

    async uploadAvatar(image: File): Promise<string> {
        /*
        What this function does:
        - Get the uid from auth state
        - Remove old avatar if exists in storage
        - Add new avatar in storage with name "avatar.{extension}"
        - Returns url of uploaded image
        - Since images can have different extensions (png, jpeg), we can't simply overrite existing file
         */
        const currentUser = await firstValueFrom(this.usersService.user$);
        const uid = currentUser?.uid;
        //const fileExtension = image.name.split('.').pop();

        const userAvatarFolderRef = ref(this.storage, `user_avatars/${uid}`);
        const listResult = await listAll(userAvatarFolderRef);
        const deletePromises = listResult.items.map((fileRef) => deleteObject(fileRef));
        await Promise.all(deletePromises);

        const storageRef = ref(this.storage, `user_avatars/${uid}/avatar.png`);
        const uploadResult = await uploadBytes(storageRef, image);
        const downloadURL = await getDownloadURL(uploadResult.ref);
        return downloadURL;
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