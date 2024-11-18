import { Component, Input, OnChanges } from '@angular/core';
import { ChartConfiguration, ChartData, ChartType } from 'chart.js';
import {
    ResponsesValues,
    ResponsesNumber,
    BAR,
} from '@common/constants/statistic-histogram.component.const';
import { GameService } from '@app/services/game.service/game.service';
import { QuestionType } from '@common/enums/question-type.enum';
import { GREEN_INDEX, LIGHTGREEN_COLOR, RED_COLOR, RED_INDEX } from '@common/style/style';
import {TranslateService} from "@ngx-translate/core";

@Component({
    selector: 'app-statistic-histogram',
    templateUrl: './statistic-histogram.component.html',
    styleUrls: ['./statistic-histogram.component.scss'],
})
export class StatisticHistogramComponent implements OnChanges {
    @Input() changingResponses: ResponsesNumber;
    @Input() valueOfResponses: ResponsesValues;
    @Input() isGameOver: boolean = false;
    legendLabels: string[] = [];
    barChartOptions: ChartConfiguration['options'] = {
        responsive: true,
        plugins: {
            legend: {
                display: false,
            },
        },
    };
    barChartType: ChartType = BAR;
    barChartData: ChartData<'bar'>;

    constructor(private gameService: GameService,private translate: TranslateService) {}

    ngOnChanges() {
        const labels = Array.from(this.valueOfResponses.keys());
        const changingResponsesData = [];
        if (this.isGameOver) {
            this.legendLabels[RED_INDEX] = this.translate.instant('GAME_INTERFACE.HISTOGRAM.INCORRECT_ANSWERS');
            this.legendLabels[GREEN_INDEX] = this.translate.instant('GAME_INTERFACE.HISTOGRAM.CORRECT_ANSWERS');
        } else {
            this.legendLabels[RED_INDEX] = this.gameService.question?.type === QuestionType.QRL ? this.translate.instant('GAME_INTERFACE.HISTOGRAM.INACTIVE') : this.translate.instant('GAME_INTERFACE.HISTOGRAM.INCORRECT_ANSWERS');
            this.legendLabels[GREEN_INDEX] = this.gameService.question?.type === QuestionType.QRL ? this.translate.instant('GAME_INTERFACE.HISTOGRAM.ACTIVE') : this.translate.instant('GAME_INTERFACE.HISTOGRAM.CORRECT_ANSWERS');
        }

        for (const key of labels) {
            changingResponsesData.push(this.changingResponses.get(key) ?? 0);
        }

        const changingResponseColors = labels.map((label) => (this.valueOfResponses.get(label) ? LIGHTGREEN_COLOR : RED_COLOR));

        this.barChartData = {
            labels,
            datasets: [
                {
                    data: changingResponsesData,
                    backgroundColor: changingResponseColors,
                },
            ],
        };
    }
}
