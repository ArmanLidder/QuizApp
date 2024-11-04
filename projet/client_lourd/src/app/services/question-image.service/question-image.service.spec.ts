import { TestBed } from '@angular/core/testing';

import { QuestionImageService } from './question-image.service';

describe('QuestionImageService', () => {
  let service: QuestionImageService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(QuestionImageService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
