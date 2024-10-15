import { Injectable } from '@angular/core';
import { AngularFirestore, AngularFirestoreCollection } from '@angular/fire/compat/firestore';
import { updateDoc, arrayUnion } from '@angular/fire/firestore';
import {Observable, firstValueFrom} from 'rxjs';
import { map } from 'rxjs/operators';
import {ServerTimeService} from "@app/services/server-time.service/server-time.service";
import { Message, Canal } from "@common/interfaces/message.interface";

@Injectable({
  providedIn: 'root'
})

export class CanalService {
  private canalsCollection: AngularFirestoreCollection<Canal>;
  canals$: Observable<Canal[]>; // Keep a list of all canals at all time

  constructor(private firestore: AngularFirestore, private serverTimeService: ServerTimeService) {
    this.canalsCollection = this.firestore.collection<Canal>('canals');
    this.canals$ = this.canalsCollection.snapshotChanges().pipe(
        map(actions => actions.map(a => {
          const data = a.payload.doc.data() as Canal;
          // This part saves Canal id on the client side
          const id = a.payload.doc.id;
          return { id, ...data };
        }))
    );
  }

  async ensureGeneralCanal() {
    const generalCanal = await firstValueFrom(this.canalsCollection.doc('general').get());
    if (!generalCanal?.exists) await this.createCanal('general', false, []);
  }

  async createCanal(name: string, isPrivate: boolean, permittedUsers: string[] = []): Promise<string> {
    const canals: Canal[] = await firstValueFrom(this.canals$)
    let canal_names: string[] = []
    canals.map((canal: Canal) => {
      canal_names.push(canal.name);
    });
    if (canal_names.includes(name)) throw new Error("Le nom de canal est déjà utiliser");
    const newCanal: Canal = {
      name,
      isPrivate,
      permittedUsers,
      messages: []
    };
    const docRef = await this.canalsCollection.add(newCanal);
    return docRef.id;
  }

  async deleteCanal(canalId: string): Promise<void> {
    const canal = await firstValueFrom(this.canalsCollection.doc(canalId).get());
    if (canal?.exists) {
      const canalData = canal.data() as Canal;
      if (canalData.name === 'general') throw new Error("Ce canal ne peut pas être effacer");
      await this.canalsCollection.doc(canalId).delete();
    } else {
      throw new Error('Canal not found');
    }
  }

  getCanal(canalId: string): Observable<Canal | undefined> {
    return this.canalsCollection.doc<Canal>(canalId).valueChanges({idField: "id"});
  }

  async addMessage(canalId: string, message: Message): Promise<void> {
    const date: Date = await this.serverTimeService.getServerTime();
    const messageWithTimestamp: Message = {
      ...message,
      createdAt: date // Use serverTimestamp here
    };
    const canalRef = this.canalsCollection.doc(canalId).ref;
    await updateDoc(canalRef, {
      messages: arrayUnion(messageWithTimestamp)
    });
  }

  async addUser(canalId: string, userId: string) {
    const canalRef = this.canalsCollection.doc(canalId).ref;
    await updateDoc(canalRef, {
      permittedUsers: arrayUnion(userId)
    });
  }
}