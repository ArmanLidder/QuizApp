import { Component, Input, OnChanges, OnDestroy, OnInit, SimpleChanges } from '@angular/core';
import { QuestionStatistics } from '@common/constants/statistic-zone.component.const';
import { QrlEvaluationService } from '@app/services/qrl-evaluation.service/qrl-evaluation.service';
import { GameService } from "@app/services/game.service/game.service";
import {GameConfigService} from "@app/services/game-config.service/game-config.service";
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-correction-qrl',
    templateUrl: './correction-qrl.component.html',
    styleUrls: ['./correction-qrl.component.scss'],
})
export class CorrectionQRLComponent implements OnChanges, OnInit, OnDestroy {
    @Input() gameStats: QuestionStatistics[] = [];
    @Input() qrlAnswers = new Map<string, { answers: string; time: number }>();
    @Input() isHostEvaluating: boolean = false;

    revokeAIcorrection: boolean = false;

    constructor(
        public qrlEvaluationService: QrlEvaluationService,
        public gameService: GameService,
        public gameConfigs: GameConfigService,
        private translate: TranslateService
    ) {}

    ngOnChanges(changes: SimpleChanges) {
        if (changes.qrlAnswers) {
            this.qrlEvaluationService.clearAll();
            this.qrlEvaluationService.initialize(this.qrlAnswers);
        }
    }

    ngOnInit() {
        this.qrlEvaluationService.initialize(this.qrlAnswers);
    }

    ngOnDestroy() {
        this.qrlEvaluationService.reset();
    }

    submitPoint() {
        this.qrlEvaluationService.submitPoint(this.gameStats);
        this.revokeAIcorrection = false;
    }

    get AIcorrectionText() {
        return this.qrlEvaluationService.correctedQrlByOpenAi
            ?.get(this.qrlEvaluationService.currentUsername)?.[1] ?? this.translate.instant('GAME_INTERFACE.QRL_CORRECTION.AI_GENERATING');
    }

    get AIscore() {
        const score = this.qrlEvaluationService.correctedQrlByOpenAi
            ?.get(this.qrlEvaluationService?.currentUsername)?.[0] ?? 0;
        if (!this.revokeAIcorrection) this.qrlEvaluationService.inputPoint = score
        return score
    }

    switchScore(event: Event) {
        this.revokeAIcorrection = true;
        const score = (event.target as HTMLSelectElement).value;
        this.qrlEvaluationService.inputPoint = Number(score);
    }
}
