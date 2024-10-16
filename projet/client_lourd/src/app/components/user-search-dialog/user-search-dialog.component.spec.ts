import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserSearchDialogComponent } from './user-search-dialog.component';

describe('UserSearchDialogComponent', () => {
  let component: UserSearchDialogComponent;
  let fixture: ComponentFixture<UserSearchDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [UserSearchDialogComponent]
    });
    fixture = TestBed.createComponent(UserSearchDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
