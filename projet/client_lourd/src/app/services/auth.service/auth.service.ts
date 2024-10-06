import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import {Observable, tap} from 'rxjs';
import {environment} from "../../../environments/environment";
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
// import {UserModificationData} from "@common/interfaces/user-data.interface";

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = environment.serverUrl;

  constructor(private http: HttpClient, private socketService: SocketClientService) {}

  register(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/auth/register`, userData)
  }

  login(userData: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/auth/login`, userData).pipe(
        tap(response => {
          if (response.token) {
            console.log(response);
            localStorage.setItem('token', response.token);
            localStorage.setItem('username', userData.username)
            this.socketService.connect();
          }
        })
    );
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }
}