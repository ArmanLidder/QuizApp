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
import {StoreItem} from "@common/interfaces/store.interface";

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
            await this.usersService.updateUser({avatar: avatarData});
            const avataraFileRef = ref(this.storage, `user_avatars/${uid}/avatar.png`);
            try {
                await deleteObject(avataraFileRef);
            } catch {
            }
        } else {
            const newAvatarUrl = await this.uploadAvatar(avatarData as File);
            await this.usersService.updateUser({avatar: newAvatarUrl});
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
                    return [];
                }
            })
        );
    }

    async getBoughtAvatars(): Promise<string[]> {
        const currentUser = await firstValueFrom(this.usersService.user$);
        const uid = currentUser?.uid;
        if (!uid) return [];

        const userDocRef = doc(this.firestore, `storeProfiles/${uid}`);
        const userProfile = await getDoc(userDocRef);
        const ownedItems = userProfile.exists() ? userProfile.data().ownedItems || [] : [];

        const avatarUrls: string[] = [];
        for (const itemId of ownedItems) {
            const itemDocRef = doc(this.firestore, `storeItems/${itemId}`);
            const itemDoc = await getDoc(itemDocRef);

            if (itemDoc.exists()) {
                const itemData = itemDoc.data() as StoreItem;
                if ((itemData.itemType === 'image' || itemData.itemType === 'rewardImage') && itemData.source) {
                    avatarUrls.push(itemData.source);
                }
            }
        }
        return avatarUrls;
    }

}