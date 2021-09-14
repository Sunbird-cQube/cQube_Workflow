import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CrcDashboardComponent } from './crc-dashboard.component';

describe('CrcDashboardComponent', () => {
  let component: CrcDashboardComponent;
  let fixture: ComponentFixture<CrcDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CrcDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CrcDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
