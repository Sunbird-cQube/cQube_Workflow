import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ProgressCardDashboardComponent } from './progress-card-dashboard.component';

describe('ProgressCardDashboardComponent', () => {
  let component: ProgressCardDashboardComponent;
  let fixture: ComponentFixture<ProgressCardDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ProgressCardDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ProgressCardDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
