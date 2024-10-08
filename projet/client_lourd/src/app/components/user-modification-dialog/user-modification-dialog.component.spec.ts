import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserModificationDialogComponent } from './user-modification-dialog.component';

describe('UserModificationDialogComponent', () => {
  let component: UserModificationDialogComponent;
  let fixture: ComponentFixture<UserModificationDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [UserModificationDialogComponent]
    });
    fixture = TestBed.createComponent(UserModificationDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
