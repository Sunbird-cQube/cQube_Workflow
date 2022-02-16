import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ManagementSelectorComponent } from './management-selector.component';

describe('ManagementSelectorComponent', () => {
  let component: ManagementSelectorComponent;
  let fixture: ComponentFixture<ManagementSelectorComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ManagementSelectorComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(ManagementSelectorComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
