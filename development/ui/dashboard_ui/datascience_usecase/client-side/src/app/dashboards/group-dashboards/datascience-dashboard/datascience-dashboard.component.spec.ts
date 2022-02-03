import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DatascienceDashboardComponent } from './datascience-dashboard.component';

describe('DatascienceDashboardComponent', () => {
  let component: DatascienceDashboardComponent;
  let fixture: ComponentFixture<DatascienceDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [DatascienceDashboardComponent]
    })
      .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(DatascienceDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
