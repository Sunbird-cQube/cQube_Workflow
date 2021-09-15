import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SatTrendsChartComponent } from './sat-trends-chart.component';

describe('SatTrendsChartComponent', () => {
  let component: SatTrendsChartComponent;
  let fixture: ComponentFixture<SatTrendsChartComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ SatTrendsChartComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(SatTrendsChartComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
