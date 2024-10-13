import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { User } from "@common/interfaces/user-data.interface";
import { environment } from "../../../environments/environment";

@Injectable({
  providedIn: 'root'
})

export class ProfileService {
  userProfile : User | null;
  avatarLink: string;

  private apiUrl = environment.serverUrl;
  constructor(private http: HttpClient) {}

  get userData() : User | null {
    return this.userProfile;
  }

  get avatarUrl(): string | null {
      // this code force the browser to consider the new img rsrc => hence image is updated
      return this.avatarLink ? `${this.avatarLink}?${new Date().getTime()}` : null;
  }

  fetchUserProfile(): void {
    const token = localStorage.getItem('token');
    this.http.get<User>(`${this.apiUrl}/profile`, {headers: {Authorization: token ? token : ''}}).subscribe(
        (data:User) => {
          this.userProfile = data;
          this.avatarLink = environment.serverUrl+'/images/'+this.userProfile.avatar
        }
    );
  }

  updateUserProfile(modifiedData: any): void {
    const token = localStorage.getItem('token');
    console.log("sending patch")
    this.http.patch<User>(`${this.apiUrl}/profile`, modifiedData, {headers: {Authorization: token ? token : ''}}).subscribe(
        (data: User) => {
          this.userProfile = data;
          this.avatarLink = environment.serverUrl+'/images/'+this.userProfile.avatar
          console.log(JSON.stringify(this.userProfile, null, 2));
        }
    );
  }

  clear() {
    this.userProfile = null;
  }
}