import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UniqueQuizNameDialogComponent } from './unique-quiz-name-dialog.component';

describe('UniqueQuizNameDialogComponent', () => {
  let component: UniqueQuizNameDialogComponent;
  let fixture: ComponentFixture<UniqueQuizNameDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [UniqueQuizNameDialogComponent]
    });
    fixture = TestBed.createComponent(UniqueQuizNameDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
