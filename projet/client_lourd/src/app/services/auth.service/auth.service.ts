import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import {Observable, tap} from 'rxjs';
import {environment} from "../../../environments/environment";
// import {UserModificationData} from "@common/interfaces/user-data.interface";

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = environment.serverUrl;

  constructor(private http: HttpClient) {}

    register(userData: any): Observable<any> {
      return this.http.post(`${this.apiUrl}/auth/register`, userData)
  }

  login(userData: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/login`, userData).pipe(
        tap(response => {
          if (response.token) {
            console.log(response);
            localStorage.setItem('token', response.token);
          }
        })
    );
  }
}