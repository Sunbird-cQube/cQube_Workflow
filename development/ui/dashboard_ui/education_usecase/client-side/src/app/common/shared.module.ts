import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MultiSelectComponent } from './multi-select/multi-select.component';
import { FormsModule } from '@angular/forms';

@NgModule({
    declarations: [
        MultiSelectComponent,
    ],
    imports: [
      CommonModule,
      FormsModule
    ],
    exports:[
        MultiSelectComponent
    ]
  })
  export class SharedModule { }