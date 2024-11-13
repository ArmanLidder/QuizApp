import {Component, OnDestroy, HostListener, OnInit} from '@angular/core';
import {SocketClientService} from "@app/services/socket-client.service/socket-client.service";
import {AuthService} from "@app/services/auth.service/auth.service";
import {TranslateService} from "@ngx-translate/core";
import {UserSettingsService} from "@app/services/user-settings.service/user-settings.service";

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnDestroy, OnInit {

    constructor(private socketService: SocketClientService,
                private authService: AuthService,
                private translate: TranslateService,
                private settings: UserSettingsService) {}

    ngOnInit() {
        this.translate.addLangs(['en', 'fr']);
        this.translate.setDefaultLang('fr');
        this.settings.currentLanguage.subscribe(language => {
            this.translate.use(language);
        });
    }


    @HostListener('window:beforeunload')
    removeToken() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        this.authService.logout();
        console.log('app disonnect')
    }

    async ngOnDestroy() {
        if (this.socketService.isSocketAlive()) this.socketService.disconnect();
        await this.authService.logout();
    }
}
