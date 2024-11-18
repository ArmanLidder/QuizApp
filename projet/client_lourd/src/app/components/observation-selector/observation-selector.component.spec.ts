import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ObservationSelectorComponent } from './observation-selector.component';

describe('ObservationSelectorComponent', () => {
  let component: ObservationSelectorComponent;
  let fixture: ComponentFixture<ObservationSelectorComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ObservationSelectorComponent]
    });
    fixture = TestBed.createComponent(ObservationSelectorComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
