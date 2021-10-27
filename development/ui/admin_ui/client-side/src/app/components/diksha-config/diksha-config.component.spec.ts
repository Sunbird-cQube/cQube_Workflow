import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { DikshaConfigComponent } from './diksha-config.component';

describe('DikshaConfigComponent', () => {
  let component: DikshaConfigComponent;
  let fixture: ComponentFixture<DikshaConfigComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ DikshaConfigComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(DikshaConfigComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
