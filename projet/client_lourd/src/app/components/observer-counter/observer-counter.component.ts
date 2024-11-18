import { Component, OnInit } from '@angular/core';
import {ObserverCounterService} from "@app/services/observer-counter.service/observer-counter.service";

@Component({
  selector: 'app-observer-counter',
  templateUrl: './observer-counter.component.html',
  styleUrls: ['./observer-counter.component.scss']
})
export class ObserverCounterComponent implements OnInit {

  constructor(public observerCounterService: ObserverCounterService) {}

  ngOnInit() {
    console.log("ngOnit Observer Count Service");
    this.observerCounterService.initialize();
  }

}
