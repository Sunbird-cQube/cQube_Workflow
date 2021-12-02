import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EtbPerCapitaComponent } from './etb-per-capita.component';

describe('EtbPerCapitaComponent', () => {
  let component: EtbPerCapitaComponent;
  let fixture: ComponentFixture<EtbPerCapitaComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ EtbPerCapitaComponent ]
    })
    .compileComponents();
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(EtbPerCapitaComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
