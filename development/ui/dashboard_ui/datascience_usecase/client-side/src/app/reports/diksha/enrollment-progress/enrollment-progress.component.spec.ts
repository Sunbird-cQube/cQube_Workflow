import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EnrollmentProgressComponent } from './enrollment-progress.component';

describe('EnrollmentProgressComponent', () => {
  let component: EnrollmentProgressComponent;
  let fixture: ComponentFixture<EnrollmentProgressComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ EnrollmentProgressComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(EnrollmentProgressComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
