import { TestBed } from '@angular/core/testing';

import { ObserverCounterService } from './observer-counter.service';

describe('ObserverCounterService', () => {
  let service: ObserverCounterService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ObserverCounterService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
