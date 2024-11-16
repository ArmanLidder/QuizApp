import {Component, OnDestroy, OnInit} from '@angular/core';
import { GameService } from "@app/services/game.service/game.service";
import { Options } from "@angular-slider/ngx-slider";
import {Subscription} from "rxjs";
import {QuizQuestion} from "@common/interfaces/quiz.interface";

@Component({
  selector: 'app-qre-response-area',
  templateUrl: './qre-response-area.component.html',
  styleUrls: ['./qre-response-area.component.scss']
})
export class QreResponseAreaComponent implements OnInit, OnDestroy {
  min: number;
  max: number;
  margin: number;
  selectedValue: number;
  options: Options;
  optionsDisabled: Options;
  responseInterval: string;
  private subscription: Subscription = new Subscription();

  constructor(public gameService: GameService) {
  }

  ngOnInit() {
    const initialQuestion = this.gameService.gameRealService.question;
    if (initialQuestion?.interval) {
      this.updateQuestionValues(initialQuestion);
      this.calculateResponseInterval();
    }
    this.subscription = this.gameService.gameRealService.question$.subscribe((question) => {
      if (question?.interval) {
        this.updateQuestionValues(question);
      }
    });
  }

  ngOnDestroy() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  private updateQuestionValues(question: QuizQuestion) {
    this.min = question.interval!.min!;
    this.max = question.interval!.max!;
    this.margin = question.margin! || 0;
    this.selectedValue = (this.min + this.max) / 2;

    this.options = {
      floor: this.min,
      ceil: this.max,
      step: 1,
      translate: (value: number): string => value.toString(),
    };

    this.gameService.qreAnswer = this.selectedValue;
    this.optionsDisabled = { ...this.options, disabled: true };
  }

  calculateResponseInterval() {
    const lowerBound = Math.max(this.gameService.question!.interval!.min!, this.selectedValue - this.gameService.question!.margin!);
    const upperBound = Math.min(this.gameService.question!.interval!.max!, this.selectedValue + this.gameService.question!.margin!);
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
    if (this.selectedValue != this.gameService.question!.interval!.min!) {
      this.selectedValue -= 1;
      this.onSliderChange();
    }
  }

  incrementValue() {
    if (this.selectedValue != this.gameService.question!.interval!.max!) {
      this.selectedValue += 1;
      this.onSliderChange();
    }
  }


}