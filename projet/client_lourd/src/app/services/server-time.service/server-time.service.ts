import { Injectable } from '@angular/core';
import { AngularFirestore } from '@angular/fire/compat/firestore';
import { updateDoc, doc, docData, serverTimestamp, Timestamp } from '@angular/fire/firestore';
import {firstValueFrom} from "rxjs";

@Injectable({
  providedIn: 'root'
})
export class ServerTimeService {

  constructor(private firestore: AngularFirestore) {}

  async getServerTime(): Promise<Date> {
    const docRef = doc(this.firestore.firestore, 'server-time', 'server-time');
    await updateDoc(docRef, {
      time: serverTimestamp()
    });
    const result = await firstValueFrom(docData(docRef)) as {time: Timestamp}
    return result.time.toDate()
  }
}
