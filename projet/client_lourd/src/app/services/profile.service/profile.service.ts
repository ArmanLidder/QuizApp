import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import {UserProfile} from "@common/interfaces/user-data.interface";
import {environment} from "../../../environments/environment";

@Injectable({
  providedIn: 'root'
})
export class ProfileService {
  private apiUrl = environment.serverUrl;
  constructor(private http: HttpClient) {}

  getUserProfileWithUsername(username: string): Observable<UserProfile> {
    const token = localStorage.getItem('token');
    return this.http.get<UserProfile>(`${this.apiUrl}/profile/${username}`, {
      headers: {
        Authorization: token ? token : ''
      }
    });
  }

  getUserProfile(): Observable<UserProfile> {
    const token = localStorage.getItem('token');
    return this.http.get<UserProfile>(`${this.apiUrl}/profile`, {
      headers: {
        Authorization: token ? token : ''
      }
    });
  }
}
