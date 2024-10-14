import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { PasswordPromptComponent } from '@app/components/password-prompt/password-prompt.component';
import {AuthGuard, canActivate, redirectLoggedInTo, redirectUnauthorizedTo} from "@angular/fire/auth-guard";
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { GameCreationPageComponent } from '@app/pages/game-creation-page/game-creation-page.component';
import { GameAdministrationPageComponent } from '@app/pages/game-administration-page/game-administration-page.component';
import { MainPageComponent } from '@app/pages/main-page/main-page.component';
import { QuizCreationPageComponent } from '@app/pages/quiz-creation-page/quiz-creation-page.component';
import { WaitingRoomPlayerPageComponent } from '@app/pages/waiting-room-player-page/waiting-room-player-page.component';
import { WaitingRoomHostPageComponent } from '@app/pages/waiting-room-host-page/waiting-room-host-page.component';
import {LoginPageComponent} from "@app/pages/login-page/login-page.component";
import {RegisterPageComponent} from "@app/pages/register-page/register-page.component";
import {ProfilePageComponent} from "@app/pages/profile-page/profile-page.component";

const redirectUnauthorizedToLogin = () => redirectUnauthorizedTo(['login']);
const redirectLoggedInToHome = () => redirectLoggedInTo(['home']);

const routes: Routes = [
    { path: 'login', component: LoginPageComponent, ...canActivate(redirectLoggedInToHome) },
    { path: 'register', component: RegisterPageComponent, ...canActivate(redirectLoggedInToHome) },
    { path: 'profile', component: ProfilePageComponent,  canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin}},
    { path: 'home', component: MainPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'game/:id', component: GamePageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'game-creation-page', component: GameCreationPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin}},
    { path: 'quiz-creation', component: QuizCreationPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'quiz-creation/:id', component: QuizCreationPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'game-admin-prompt', component: PasswordPromptComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'quiz-testing-page/:id', component: GamePageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'waiting-room-host-page/:id', component: WaitingRoomHostPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'waiting-room-player-page', component: WaitingRoomPlayerPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: 'game-admin-page', component: GameAdministrationPageComponent, canActivate: [AuthGuard], data: {authGuardPipe: redirectUnauthorizedToLogin} },
    { path: '**', redirectTo: '/login' },
];

@NgModule({
    imports: [RouterModule.forRoot(routes, { useHash: true })],
    exports: [RouterModule],
})
export class AppRoutingModule {}
