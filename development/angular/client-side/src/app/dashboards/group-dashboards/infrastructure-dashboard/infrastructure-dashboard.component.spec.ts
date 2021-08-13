import { ComponentFixture, TestBed } from '@angular/core/testing';

import { InfrastructureDashboardComponent } from './infrastructure-dashboard.component';

describe('InfrastructureDashboardComponent', () => {
  let component: InfrastructureDashboardComponent;
  let fixture: ComponentFixture<InfrastructureDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ InfrastructureDashboardComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(InfrastructureDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
