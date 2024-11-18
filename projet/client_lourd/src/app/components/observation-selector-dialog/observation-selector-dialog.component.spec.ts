import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ObservationSelectorDialogComponent } from './observation-selector-dialog.component';

describe('ObservationSelectorDialogComponent', () => {
  let component: ObservationSelectorDialogComponent;
  let fixture: ComponentFixture<ObservationSelectorDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [ObservationSelectorDialogComponent]
    });
    fixture = TestBed.createComponent(ObservationSelectorDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
