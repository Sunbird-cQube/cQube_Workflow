import { TestBed } from '@angular/core/testing';

import { GetQRcodeService } from './get-qrcode.service';

describe('GetQRcodeService', () => {
  let service: GetQRcodeService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(GetQRcodeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
