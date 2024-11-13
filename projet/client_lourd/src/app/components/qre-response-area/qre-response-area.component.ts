import { Component, OnInit } from '@angular/core';
import { GameService } from "@app/services/game.service/game.service";
import { Options } from "@angular-slider/ngx-slider";

@Component({
  selector: 'app-qre-response-area',
  templateUrl: './qre-response-area.component.html',
  styleUrls: ['./qre-response-area.component.scss']
})
export class QreResponseAreaComponent implements OnInit {
  min: number;
  max: number;
  margin: number;
  selectedValue: number;
  options: Options;
  optionsDisabled: Options;
  responseInterval: string;

  constructor(public gameService: GameService) {
  }

  ngOnInit() {
    this.min = this.gameService.question!.interval?.min as number;
    this.max = this.gameService.question!.interval?.max as number;
    this.margin = this.gameService.question!.margin as number;
    this.selectedValue = (this.min + this.max) / 2;
    this.calculateResponseInterval();
    this.options = {
      floor: this.min,
      ceil: this.max,
      step: 1,
      translate: (value: number): string => {
        return value.toString();
      }
    };
    this.optionsDisabled = { ...this.options, disabled: true };
    this.gameService.qreAnswer=this.selectedValue;
  }

  calculateResponseInterval() {
    const lowerBound = Math.max(this.min, this.selectedValue - this.margin);
    const upperBound = Math.min(this.max, this.selectedValue + this.margin);
    this.responseInterval = `${lowerBound.toString()} à ${upperBound.toString()}`;
  }

  onSliderChange() {
    this.calculateResponseInterval();
    this.gameService.selectQREAnswer(this.selectedValue);
  }

  validate() {
    if (!this.gameService.validatedStatus) {
      this.gameService.qreAnswer = this.selectedValue;
      this.gameService.selectQREAnswer(this.selectedValue);
      this.gameService.sendAnswer();
    }
  }

  decrementValue() {
    if (this.selectedValue != this.min) {
      this.selectedValue -= 1;
      this.onSliderChange();
    }
  }

  incrementValue() {
    if (this.selectedValue != this.max) {
      this.selectedValue += 1;
      this.onSliderChange();
    }

  }
}