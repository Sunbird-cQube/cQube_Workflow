import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EtbDashboardComponent } from './etb-dashboard.component';

describe('EtbDashboardComponent', () => {
  let component: EtbDashboardComponent;
  let fixture: ComponentFixture<EtbDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ EtbDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(EtbDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
