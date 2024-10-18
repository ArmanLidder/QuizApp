import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AvatarModificationDialogComponent } from './avatar-modification-dialog.component';

describe('AvatarModificationDialogComponent', () => {
  let component: AvatarModificationDialogComponent;
  let fixture: ComponentFixture<AvatarModificationDialogComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [AvatarModificationDialogComponent]
    });
    fixture = TestBed.createComponent(AvatarModificationDialogComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
