import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { progressCardComponent } from './progress-card.component';

describe('progressCardComponent', () => {
  let component: progressCardComponent;
  let fixture: ComponentFixture<progressCardComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [progressCardComponent]
    })
      .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(progressCardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
