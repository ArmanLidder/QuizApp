import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AvatarWithLevelComponent } from './avatar-with-level.component';

describe('AvatarWithLevelComponent', () => {
  let component: AvatarWithLevelComponent;
  let fixture: ComponentFixture<AvatarWithLevelComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [AvatarWithLevelComponent]
    });
    fixture = TestBed.createComponent(AvatarWithLevelComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
