import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GameConfigDialogComponent } from './game-config-dialog.component';

describe('GameConfigDialogComponent', () => {
  let component: GameConfigDialogComponent;
  let fixture: ComponentFixture<GameConfigDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [GameConfigDialogComponent]
    });
    fixture = TestBed.createComponent(GameConfigDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
