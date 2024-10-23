import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UsernameModificationDialogComponent } from './username-modification-dialog.component';

describe('UserModificationDialogComponent', () => {
  let component: UsernameModificationDialogComponent;
  let fixture: ComponentFixture<UsernameModificationDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [UsernameModificationDialogComponent]
    });
    fixture = TestBed.createComponent(UsernameModificationDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
