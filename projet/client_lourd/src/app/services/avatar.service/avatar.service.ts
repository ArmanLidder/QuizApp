import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import {environment} from "../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class AvatarService {
  private apiUrl = environment.serverUrl;

  constructor(private http: HttpClient) {}

  getDefaultAvatars(): Observable<string[]> {
    return this.http.get<string[]>(`${this.apiUrl}/avatar`);
  }
}
