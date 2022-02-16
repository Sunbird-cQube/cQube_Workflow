import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ContentUsagePieChartComponent } from './content-usage-pie-chart.component';

describe('ContentUsagePieChartComponent', () => {
  let component: ContentUsagePieChartComponent;
  let fixture: ComponentFixture<ContentUsagePieChartComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ContentUsagePieChartComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ContentUsagePieChartComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
