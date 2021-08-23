import { ChangeDetectorRef, Component, Input, OnInit } from '@angular/core';
import { AppServiceComponent } from 'src/app/app.service';

@Component({
  selector: 'app-management-selector',
  templateUrl: './management-selector.component.html',
  styleUrls: ['./management-selector.component.css']
})
export class ManagementSelectorComponent implements OnInit {
  managementType;
  categoryType;
  @Input() reportGroup: string;

  constructor(public service: AppServiceComponent, public changeDetection: ChangeDetectorRef) { }

  //Management and category
  public managements = [];
  public management = JSON.parse(localStorage.getItem('management')) != null ? JSON.parse(localStorage.getItem('management')).id : "";;
  categories = [];
  public category;
  onSelectManagement() {
    var obj = {
      id: this.management,
      value: this.service.changeingStringCases(this.management.replace(/_/g, ' '))
    }
    localStorage.setItem("management", JSON.stringify(obj));
    this.changeDetection.detectChanges();
  }
  onSelectCategory() {
    var obj = {
      id: this.category,
      value: this.service.changeingStringCases(this.category.replace(/_/g, ' '))
    }
    localStorage.setItem("category", JSON.stringify(obj));
    this.changeDetection.detectChanges();
  }

  ngOnInit(): void {
    this.managements = JSON.parse(localStorage.getItem('managements'))
    document.getElementById("spinner").style.display = "block";
    this.changeDetection.detectChanges();
    if (!this.managements) {
      this.service.management_category_metaData().subscribe((res) => {
        this.managements = res["mydata"].management;
        this.managements.unshift({ id: "overall", value: "Overall" });
        this.categories = res["mydata"].category;
        this.categories.unshift({ id: "overall", value: "Overall" });
        localStorage.setItem('managements', JSON.stringify(this.managements));
        document.getElementById("spinner").style.display = "none";
      }, err => {
        let isThere = false;
        this.managements.map(item => {
          if (item.id != JSON.parse(localStorage.getItem('management')).id) {
            isThere = true;
            return isThere;
          }
        });
        if (isThere) {
          this.managements.unshift(JSON.parse(localStorage.getItem('management')));
        }
        if (JSON.parse(localStorage.getItem('management'))) {
          var name = this.managements.find(a => { return a.id == JSON.parse(localStorage.getItem('management')).id });
          if (name && name.value != 'Overall') {
            this.managements.unshift({ id: "overall", value: "Overall" });
          }
        }
        document.getElementById("spinner").style.display = "none";
      });

    } else {
      if (this.managements.length > 0) {
        document.getElementById("spinner").style.display = "none";
      }
    }
    this.getDefault();
  }

  getDefault() {
    this.service.getDefault().subscribe(res => {
      this.managementType = res[0]['name'];
      this.categoryType = res[1]['name'];
      this.setDefault();
    });
  }

  setDefault() {
    if (localStorage.getItem('management') == null) {
      this.management = this.managementType;
      this.category = this.categoryType;
      let obj = {
        id: this.managementType,
        value: this.service.changeingStringCases(this.managementType.replace(/_/g, ' '))
      }
      localStorage.setItem("management", JSON.stringify(obj));
      obj = {
        id: this.categoryType,
        value: this.service.changeingStringCases(this.categoryType.replace(/_/g, ' '))
      }
      localStorage.setItem("category", JSON.stringify(obj));
    } else {
      this.management = JSON.parse(localStorage.getItem('management')).id;
      this.category = JSON.parse(localStorage.getItem('category')).id;
    }
    if (this.managementType) {
      if (this.managements && this.managements.length == 0) {
        this.managements.push({ id: this.managementType, value: this.service.changeingStringCases(this.managementType.replace(/_/g, ' ')) })
      }
    } else {
      this.management = JSON.parse(localStorage.getItem('management')).id;
      this.category = JSON.parse(localStorage.getItem('category')).id;
    }
    this.changeDetection.detectChanges();
  }

}
