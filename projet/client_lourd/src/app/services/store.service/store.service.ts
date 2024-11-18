import {Injectable} from '@angular/core';
import {
    doc, docData, Firestore, updateDoc, collection, collectionData, arrayUnion, setDoc, getDoc,
} from '@angular/fire/firestore';
import {StoreItem} from "@common/interfaces/store.interface";
import {catchError, firstValueFrom, Observable, of, switchMap} from "rxjs";
import {UsersService} from "@app/services/users.service/users.service";
import {map} from "rxjs/operators";
type StoreItemWithOwnership = StoreItem & { isOwned: boolean };

@Injectable({
    providedIn: 'root'
})
export class StoreService {
    constructor(private firestore: Firestore, private usersService: UsersService) {
    }

    get allStoreItems(): Observable<StoreItem[]> {
        const itemsCollectionRef = collection(this.firestore, `storeItems`);
        return collectionData(itemsCollectionRef, {idField: 'id'}).pipe(map((data) => data as StoreItem[]), catchError((error) => {
            console.error('Error fetching all store items:', error);
            return of([]);
        }));
    }

    get allStoreItemsWithOwnership(): Observable<StoreItemWithOwnership[]> {
        return this.usersService.currentUserProfile$.pipe(
            switchMap((user) => {
                const uid = user?.uid;
                if (!uid) return of([]); // Return empty array if no user is found

                const userDocRef = doc(this.firestore, `storeProfiles/${uid}`);
                return docData(userDocRef).pipe(
                    switchMap((userProfile: any) => {
                        const ownedItems = userProfile?.ownedItems || [];
                        const itemsCollectionRef = collection(this.firestore, `storeItems`);
                        return collectionData(itemsCollectionRef, { idField: 'id' }).pipe(
                            map((data) => (data as StoreItem[]).map((item) => ({
                                ...item,
                                isOwned: ownedItems.includes(item.id) // Add isOwned flag based on user's owned items
                            } as StoreItemWithOwnership)))
                        );
                    })
                );
            }),
            catchError((error) => {
                console.error('Error fetching all store items with ownership status:', error);
                return of([]);
            })
        );
    }

    get allUnOwnedStoreItems(): Observable<StoreItem[]> {
        return this.usersService.currentUserProfile$.pipe(switchMap((user) => {
            const uid = user?.uid;
            if (!uid) return of([]);

            const userDocRef = doc(this.firestore, `storeProfiles/${uid}`);
            return docData(userDocRef).pipe(switchMap((userProfile: any) => {
                const ownedItems = userProfile?.ownedItems || [];
                const itemsCollectionRef = collection(this.firestore, `storeItems`);
                return collectionData(itemsCollectionRef, {idField: 'id'}).pipe(map((data) => (data as StoreItem[]).filter((item) => !ownedItems.includes(item.id))));
            }));
        }), catchError((error) => {
            console.error('Error fetching filtered store items:', error);
            return of([]);
        }));
    }

    getStoreItemById(id: string): Observable<StoreItem | null> {
        const itemDocRef = doc(this.firestore, `storeItems/${id}`);
        return docData(itemDocRef, {idField: 'id'}).pipe(catchError((error) => {
            console.error(`Error fetching store item with ID ${id}:`, error);
            return of(null); // Return null if there's an error or item not found
        })) as Observable<StoreItem | null>;
    }

    async addItemToUserProfile(id: string) {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        const uid = currentUser?.uid;

        if (!uid) throw new Error("User ID not found");

        const userDocRef = doc(this.firestore, `storeProfiles/${uid}`);
        try {
            const userDocSnap = await getDoc(userDocRef);
            if (!userDocSnap.exists()) {
                await setDoc(userDocRef, { ownedItems: [id] });
            } else {
                await updateDoc(userDocRef, {
                    ownedItems: arrayUnion(id)
                });
            }
        } catch (error) {
            throw new Error('Erreur de achat');
        }
    }


    async buyItem(id: string) {
        const currentUser = await firstValueFrom(this.usersService.currentUserProfile$);
        try {
            const storeItem: StoreItem | null = await firstValueFrom(this.getStoreItemById(id));
            if (!storeItem) throw new Error("Item n'existe pas.")
            if ((currentUser?.currency || 0) < storeItem.cost) throw new Error("Vous n'avez pas assez d'argent.")
            if (storeItem.itemType === 'rewardTheme' || storeItem.itemType === 'rewardImage') {
                if ((currentUser?.level||0) < (storeItem.minLevel||0)) throw new Error(`Vous n'avez pas le niveau requis pour ce item (${storeItem.minLevel!})}`);
                if ((currentUser?.prestige||0) < (storeItem.minPrestige||0)) throw new Error(`Vous n'avez pas le prestige requis pour ce item (${storeItem.minPrestige!})}`);
                const hasRequiredAchievement = !storeItem.achievement || (currentUser?.achievements || []).includes(storeItem.achievement);
                if (!hasRequiredAchievement) throw new Error(`Vous n'avez pas le achievement requis pour ce item`);
            }
            await this.addItemToUserProfile(id)
            await this.usersService.updateUser({currency: (currentUser?.currency || 0) - storeItem.cost});
        } catch (error: any) {
            console.log(error.message);
            throw new Error("Erreur d'achat")
        }
    }
}
