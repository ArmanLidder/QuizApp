import { ComponentFixture, TestBed } from '@angular/core/testing';

import { QreResponseAreaComponent } from './qre-response-area.component';

describe('QreResponseAreaComponent', () => {
  let component: QreResponseAreaComponent;
  let fixture: ComponentFixture<QreResponseAreaComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [QreResponseAreaComponent]
    });
    fixture = TestBed.createComponent(QreResponseAreaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
