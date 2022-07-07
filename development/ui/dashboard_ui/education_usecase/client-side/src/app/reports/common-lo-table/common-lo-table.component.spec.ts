import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CommonLoTableComponent } from './common-lo-table.component';

describe('CommonLoTableComponent', () => {
  let component: CommonLoTableComponent;
  let fixture: ComponentFixture<CommonLoTableComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ CommonLoTableComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(CommonLoTableComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
