import { HttpClientModule } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AlertDialogComponent } from '@app/components/alert-dialog/alert-dialog.component';
import { GameAnswerChoiceCardComponent } from '@app/components/game-answer-choice-card/game-answer-choice-card.component';
import { GameAnswersListComponent } from '@app/components/game-answers-list/game-answers-list.component';
import { GameInterfaceComponent } from '@app/components/game-interface/game-interface.component';
import { GameItemComponent } from '@app/components/game-item/game-item.component';
import { GamesListComponent } from '@app/components/games-list/games-list.component';
import { HostInterfaceComponent } from '@app/components/host-interface/host-interface.component';
import { PlayerListComponent } from '@app/components/player-list/player-list.component';
import { QrlResponseAreaComponent } from '@app/components/qrl-response-area/qrl-response-area.component';
import { QuestionListComponent } from '@app/components/question-list/question-list.component';
import { QuizCreationComponent } from '@app/components/quiz-creation/quiz-creation.component';
import { QuizInfoComponent } from '@app/components/quiz-info/quiz-info.component';
import { RoomCodePromptComponent } from '@app/components/room-code-prompt/room-code-prompt.component';
import { StatisticHistogramComponent } from '@app/components/statistic-histogram/statistic-histogram.component';
import { UniqueQuizErrorFeedbackComponent } from '@app/components/unique-quiz-error-feedback/unique-quiz-error-feedback.component';
import { ValidationQuizErrorFeedbackComponent } from '@app/components/validation-quiz-error-feedback/validation-quiz-error-feedback.component';
import { WaitingRoomComponent } from '@app/components/waiting-room/waiting-room.component';
import { AppRoutingModule } from '@app/modules/app-routing.module';
import { AppMaterialModule } from '@app/modules/material.module';
import { AppComponent } from '@app/pages/app/app.component';
import { GameAdministrationPageComponent } from '@app/pages/game-administration-page/game-administration-page.component';
import { GameCreationPageComponent } from '@app/pages/game-creation-page/game-creation-page.component';
import { GamePageComponent } from '@app/pages/game-page/game-page.component';
import { MainPageComponent } from '@app/pages/main-page/main-page.component';
import { QuizCreationPageComponent } from '@app/pages/quiz-creation-page/quiz-creation-page.component';
import { WaitingRoomHostPageComponent } from '@app/pages/waiting-room-host-page/waiting-room-host-page.component';
import { WaitingRoomPlayerPageComponent } from '@app/pages/waiting-room-player-page/waiting-room-player-page.component';
import { NgChartsModule } from 'ng2-charts';
import { ConfirmationDialogComponent } from './components/confirmation-dialog/confirmation-dialog.component';
import { CorrectionQRLComponent } from './components/correction-qrl/correction-qrl.component';
import { GameHistoryListComponent } from './components/game-history-list/game-history-list.component';
import { LeaveButtonComponent } from './components/leave-boutton/leave-boutton.component';
import { StatisticZoneComponent } from './components/statistic-zone/statistic-zone.component';
import { LoginPageComponent } from '@app/pages/login-page/login-page.component';
import {MatFormFieldModule} from "@angular/material/form-field";
import {MatIconModule} from "@angular/material/icon";
import {MatInputModule} from "@angular/material/input";
import { MatSnackBarModule } from '@angular/material/snack-bar';
import {RegisterPageComponent} from "@app/pages/register-page/register-page.component";
import { AvatarComponent } from './components/avatar/avatar.component';
import { HeaderComponent } from './components/header/header.component';
import { ProfilePageComponent } from './pages/profile-page/profile-page.component';
import { UsernameModificationDialogComponent } from '@app/components/username-modification-dialog/username-modification-dialog.component';
import { AvatarPickerComponent } from './components/avatar-picker/avatar-picker.component';
import {initializeApp, provideFirebaseApp} from "@angular/fire/app";
import { provideAuth, getAuth } from '@angular/fire/auth';
import { provideFirestore, getFirestore } from '@angular/fire/firestore';
import { getStorage, provideStorage } from '@angular/fire/storage';
import {environment} from "../environments/environment";
import {ChatComponent} from "@app/components/chat/chat.component";
import {FIREBASE_OPTIONS} from "@angular/fire/compat";
import {CanalService} from "@app/services/canal.service/canal.service";
import { AvatarModificationDialogComponent } from './components/avatar-modification-dialog/avatar-modification-dialog.component';
import {MatProgressSpinnerModule} from "@angular/material/progress-spinner";
import { UserSearchDialogComponent } from './components/user-search-dialog/user-search-dialog.component';
import {MatAutocompleteModule} from "@angular/material/autocomplete";
import {MatListModule} from "@angular/material/list";
import { FriendsComponent } from './components/friends/friends.component';
import {MatTabsModule} from "@angular/material/tabs";
import { AvatarWithLevelComponent } from './components/avatar-with-level/avatar-with-level.component';
import { PopoutWindowModule } from 'angular-popout-window';
import { GameConfigDialogComponent } from './components/game-config-dialog/game-config-dialog.component';
import {MatCheckboxModule} from "@angular/material/checkbox";
import {MatSelectModule} from "@angular/material/select";
import { ActiveGameListComponent } from './components/active-game-list/active-game-list.component';
import { ErrorDialogComponent } from './components/error-dialog/error-dialog.component';
import { QreResponseAreaComponent } from './components/qre-response-area/qre-response-area.component';

/**
 * Main module that is used in main.ts.
 * All automatically generated components will appear in this module.
 * Please do not move this module in the module folder.
 * Otherwise, Angular Cli will not know in which module to put new component
 */
@NgModule({
    declarations: [
        AppComponent,
        GamePageComponent,
        MainPageComponent,
        QuizCreationComponent,
        QuizCreationPageComponent,
        QuestionListComponent,
        GameCreationPageComponent,
        GameAdministrationPageComponent,
        GameItemComponent,
        GamesListComponent,
        GameHistoryListComponent,
        QuizInfoComponent,
        UniqueQuizErrorFeedbackComponent,
        ValidationQuizErrorFeedbackComponent,
        WaitingRoomComponent,
        WaitingRoomHostPageComponent,
        WaitingRoomPlayerPageComponent,
        RoomCodePromptComponent,
        GameInterfaceComponent,
        GameAnswersListComponent,
        GameAnswerChoiceCardComponent,
        HostInterfaceComponent,
        StatisticHistogramComponent,
        AlertDialogComponent,
        PlayerListComponent,
        CorrectionQRLComponent,
        QrlResponseAreaComponent,
        LeaveButtonComponent,
        StatisticZoneComponent,
        ConfirmationDialogComponent,
        LoginPageComponent,
        RegisterPageComponent,
        AvatarComponent,
        HeaderComponent,
        ProfilePageComponent,
        UsernameModificationDialogComponent,
        AvatarPickerComponent,
        ChatComponent,
        AvatarModificationDialogComponent,
        UserSearchDialogComponent,
        FriendsComponent,
        AvatarWithLevelComponent,
        GameConfigDialogComponent,
        ActiveGameListComponent,
        ErrorDialogComponent,
        QreResponseAreaComponent,
    ],
    imports: [
        AppMaterialModule,
        AppRoutingModule,
        BrowserAnimationsModule,
        BrowserModule,
        FormsModule,
        HttpClientModule,
        ReactiveFormsModule,
        NgChartsModule,
        BrowserAnimationsModule,
        MatTooltipModule,
        MatDialogModule,
        FormsModule,
        MatFormFieldModule,
        MatIconModule,
        MatInputModule,
        ReactiveFormsModule,
        MatSnackBarModule,
        provideFirebaseApp(() => initializeApp(environment.firebase)),
        provideAuth(() => getAuth()),
        provideFirestore(() => getFirestore()),
        provideStorage(() => getStorage()),
        MatProgressSpinnerModule,
        MatAutocompleteModule,
        MatListModule,
        MatTabsModule,
        PopoutWindowModule,
        MatCheckboxModule,
        MatSelectModule,
    ],
    providers: [
        CanalService,
        { provide: FIREBASE_OPTIONS, useValue: environment.firebase }
    ],
    bootstrap: [AppComponent],
})
export class AppModule {}
