import { Injectable } from '@angular/core';
import {Storage, ref, uploadBytes, getDownloadURL} from '@angular/fire/storage';
// import { Observable, from } from 'rxjs';
// import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root',
})
export class QuestionImageService {
  constructor(private storage: Storage) {}

  async uploadQuestionImage(image: File, quizId: string): Promise<string> {
    const questionImageFolderRef = ref(this.storage, `quizImages`);
    const storageRef = ref(questionImageFolderRef, `${Date.now()}.png`);

    const uploadResult = await uploadBytes(storageRef, image);
    const downloadURL = await getDownloadURL(uploadResult.ref);

    return downloadURL;
  }
}
