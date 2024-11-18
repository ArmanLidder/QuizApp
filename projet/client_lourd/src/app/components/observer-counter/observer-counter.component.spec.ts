import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ObserverCounterComponent } from './observer-counter.component';

describe('ObserverCounterComponent', () => {
  let component: ObserverCounterComponent;
  let fixture: ComponentFixture<ObserverCounterComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ObserverCounterComponent]
    });
    fixture = TestBed.createComponent(ObserverCounterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
