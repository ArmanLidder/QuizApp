import {Component, inject} from '@angular/core';
import {ActivatedRoute} from '@angular/router';
import {GameService} from '@app/services/game.service/game.service';
import {SocketClientService} from '@app/services/socket-client.service/socket-client.service';
import {
    HostInterfaceManagementService
} from '@app/services/host-interface-management.service/host-interface-management.service';
import {QrlEvaluationService} from '@app/services/qrl-evaluation.service/qrl-evaluation.service';
import {TimerMessage} from '@common/browser-message/displayable-message/timer-message';
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-host-interface', templateUrl: './host-interface.component.html', styleUrls: ['./host-interface.component.scss'],
})
export class HostInterfaceComponent {
    qrlEvaluationService: QrlEvaluationService = inject(QrlEvaluationService);
    protected readonly timerMessage = TimerMessage;
    private isLastButton: boolean = false;
    private route: ActivatedRoute = inject(ActivatedRoute);

    constructor(public gameService: GameService, public hostInterfaceManagerService: HostInterfaceManagementService, private readonly socketService: SocketClientService, private translate: TranslateService) {
        if (this.socketService.isSocketAlive()) this.hostInterfaceManagerService.configureBaseSocketFeatures();
        this.gameService.init(this.route.snapshot.paramMap.get('id') as string);
    }

    isDisabled() {
        const duringEvaluation = !this.qrlEvaluationService.isCorrectionFinished && this.hostInterfaceManagerService.isHostEvaluating;
        return (!this.gameService.gameRealService.locked && !this.gameService.gameRealService.validated) || this.isLastButton || duringEvaluation;
    }

    updateHostCommand() {
        return this.gameService.gameRealService.isLast ? this.translate.instant('GAME_INTERFACE.SHOW_RESULT') : this.translate.instant('GAME_INTERFACE.NEXT_QUESTION');
    }

    handleHostCommand() {
        this.hostInterfaceManagerService.saveStats();
        if (this.gameService.gameRealService.isLast) {
            this.hostInterfaceManagerService.handleLastQuestion();
            this.isLastButton = true;
        } else {
            this.hostInterfaceManagerService.requestNextQuestion();
        }
    }

    isTimerStateResultAvailableIn() {
        return this.hostInterfaceManagerService.timerText === this.translate.instant('GAME_INTERFACE.TIMER_TEXT.RESULT_AVAILABLE_IN');
    }
}
