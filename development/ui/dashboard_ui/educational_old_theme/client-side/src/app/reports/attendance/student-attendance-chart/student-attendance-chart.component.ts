import { ChangeDetectorRef, Component, OnInit, QueryList, ViewChild, ViewChildren } from '@angular/core';
import { AppServiceComponent } from 'src/app/app.service';
import { MultiSelectComponent } from '../../../common/multi-select/multi-select.component';
import { LineChartComponent } from '../../../common/line-chart/line-chart.component';
import { AttendanceReportService } from '../../../services/student.attendance-report.service';

@Component({
  selector: 'app-student-attendance-chart',
  templateUrl: './student-attendance-chart.component.html',
  styleUrls: ['./student-attendance-chart.component.css']
})
export class StudentAttendanceChartComponent implements OnInit {
  state;
  level = 'state';
  counts: any = [];
  districtList: any = [];
  blockList: any = [];
  blockData: any = [];
  selectedBlock: any = [];
  clusterList: any = [];
  clusterData: any = [];
  selectedCluster: any = [];
  schoolList: any = [];
  schoolData: any = [];
  selectedSchool: any = [];

  years = [];
  selectedYear = '';
  selectedDistricts = [];

  managementName;
  management;
  category;

  data: any = [];
  currentData = [];
  xAxisLabels = ['June', 'July', 'August', 'September', 'October', 'November', 'December', 'January', 'February', 'March', 'April', 'May'];
  height = window.innerHeight;
  constructor(public commonService: AppServiceComponent, public service: AttendanceReportService, private changeDetection: ChangeDetectorRef) { }

  @ViewChildren(MultiSelectComponent) multiSelect: QueryList<MultiSelectComponent>;
  @ViewChild('multiSelect1') multiSelect1: MultiSelectComponent;
  @ViewChild('multiSelect2') multiSelect2: MultiSelectComponent;
  @ViewChild('multiSelect3') multiSelect3: MultiSelectComponent;
  @ViewChild('multiSelect4') multiSelect4: MultiSelectComponent;

  ngOnInit(): void {
    document.getElementById('home').style.display = 'none';
    document.getElementById('homeBtn').style.display = 'block';
    document.getElementById('backBtn').style.display = 'none';
    this.state = this.commonService.state;
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.service.getYears().subscribe(res => {
      this.years = Object.keys(res);
      this.selectedYear = this.years[this.years.length - 1];
      this.onResize();
      this.onHomeClick(false);
    }, err => {
      this.commonService.loaderAndErr([]);
    })
    this.changeDetection.detectChanges();
  }

  onResize() {
    this.height = window.innerHeight;
    console.log(this.height)
  }
  districtData = [];
  onSelectYear() {
    this.commonService.errMsg();
    this.currentColors = [];
    this.dataWithColors = [];
    this.onHomeClick(true);
  }

  onHomeClick(defYear) {
    this.commonService.errMsg();
    if (!defYear)
      this.selectedYear = this.years[this.years.length - 1];
    this.getStateData();
    this.selectedDistricts = [];
    this.selectedBlock = [];
    this.selectedCluster = [];
    this.selectedSchool = [];
    this.currentColors = [];
    this.dataWithColors = [];
    var districtList = this.districtList.map(district => {
      district.status = false;
      return district;
    });
    this.districtList = districtList;
    if (this.multiSelect1)
      this.multiSelect1.checkedList = [];
    document.getElementById('home').style.display = 'none';
  }
  getStateData() {
    this.level = 'State';
    this.service.getStateData({ ...{ year: this.selectedYear }, ...{ management: this.management, category: this.category } }).subscribe(res => {
      this.data = res['data'];
      var data = [];
      this.counts = [];
      var counts = [];
      this.currentData = [];
      this.data.map(item => {
        item.attendance.map(i => {
          data.push(i.attendance);
          counts.push({ studentCount: i.studentCount, schoolCount: i.schoolCount, index: 0 });
        });
        this.counts.push(counts);
        this.currentData.push({ data: data, name: this.state, color: '#00FF00' });
        this.commonService.loaderAndErr(this.currentData);
      });
      this.getDistrictData();
    }, err => {
      this.data = [];
      this.currentData = [];
      this.commonService.loaderAndErr(this.data);
    })
  }
  getDistrictData() {
    this.districtList = [];
    this.districtData = [];
    this.service.getDistrictData({ ...{ year: this.selectedYear }, ...{ management: this.management, category: this.category } }).subscribe((res: any) => {
      this.districtData = res['data'];
      this.districtData.map(item => {
        this.districtList.push({ id: item.districtId, name: item.districtName });
      });
      var districtList = this.districtList.map(district => {
        district.status = false;
        return district;
      });
      this.districtList = districtList;
      if (this.multiSelect1)
        this.multiSelect1.checkedList = [];
      this.districtList = this.districtList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
    }, err => {
      this.commonService.loaderAndErr([]);
    })
  }

  getBlockData() {
    this.blockList = [];
    this.blockData = [];
    if (this.selectedDistricts.length == 1) {
      this.service.getBlockData({ ...{ year: this.selectedYear, districtId: this.selectedDistricts[0] }, ...{ management: this.management, category: this.category } }).subscribe((res: any) => {
        this.blockData = res['data'];
        this.blockData.map(item => {
          this.blockList.push({ id: item.blockId, name: item.blockName });
        });
        var blockList = this.blockList.map(block => {
          block.status = false;
          return block;
        });
        this.blockList = blockList;
        if (this.multiSelect2)
          this.multiSelect2.checkedList = [];
        this.blockList = this.blockList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
      }, err => {
        this.commonService.loaderAndErr([]);
      })
    }
    else {
      this.blockData = [];
    }
  }

  getClusterData() {
    this.clusterList = [];
    this.clusterData = [];
    if (this.selectedBlock.length == 1) {
      this.service.getClusterData({ ...{ year: this.selectedYear, blockId: this.selectedBlock[0] }, ...{ management: this.management, category: this.category } }).subscribe((res: any) => {
        this.clusterData = res['data'];
        this.clusterData.map(item => {
          this.clusterList.push({ id: item.clusterId, name: item.clusterName });
        });
        var clusterList = this.clusterList.map(cluster => {
          cluster.status = false;
          return cluster;
        });
        this.clusterList = clusterList;
        if (this.multiSelect3)
          this.multiSelect3.checkedList = [];
        this.clusterList = this.clusterList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
      }, err => {
        this.commonService.loaderAndErr([]);
      })
    } else {
      this.clusterData = [];
    }
  }

  getSchoolData() {
    this.schoolList = [];
    this.schoolData = [];
    if (this.selectedCluster.length == 1) {
      this.service.getSchoolData({ ...{ year: this.selectedYear, clusterId: this.selectedCluster[0] }, ...{ management: this.management, category: this.category } }).subscribe((res: any) => {
        this.schoolData = res['data'];
        this.schoolData.map(item => {
          this.schoolList.push({ id: item.schoolId, name: item.schoolName });
        });
        var schoolList = this.schoolList.map(school => {
          school.status = false;
          return school;
        });
        this.schoolList = schoolList;
        if (this.multiSelect4)
          this.multiSelect4.checkedList = [];
        this.schoolList = this.schoolList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
      }, err => {
        this.commonService.loaderAndErr([]);
      })
    } else {
      this.schoolData = [];
    }
  }

  public colors = ['#a50026', '#d73027', '#f46d43', '#fdae61', '#fee08b', '#d9ef8b', '#a6d96a', '#66bd63', '#1a9850', '#006837'];
  public currentColors = [];
  public dataWithColors = [];

  clearSuccessors(type: string): any {
    if (type === 'District') {
      this.selectedDistricts = [];
      this.selectedBlock = [];
      this.blockData = [];
      this.blockList = [];
      this.selectedCluster = [];
      this.clusterData = [];
      this.clusterList = [];
      this.selectedSchool = [];
      this.schoolData = [];
      this.schoolList = [];
    } else if (type === 'Block') {
      this.selectedBlock = [];
      this.selectedCluster = [];
      this.clusterData = [];
      this.clusterList = [];
      this.selectedSchool = [];
      this.schoolData = [];
      this.schoolList = [];
    } else if (type === 'Cluster') {
      this.selectedCluster = [];
      this.selectedSchool = [];
      this.schoolData = [];
      this.schoolList = [];
    }
  }

  getDistrictName(districtId: number): string {
    let district = this.districtList.find(district => district.id === districtId);
    return district.name;
  }

  getBlockName(blockId: number): string {
    let block = this.blockList.find(block => block.id === blockId);
    return block.name;
  }

  getClusterName(clusterId: number): string {
    let cluster = this.clusterList.find(cluster => cluster.id === clusterId);
    return cluster.name;
  }

  shareCheckedList(list) {
    this.currentColors = [];
    this.dataWithColors = [];
    this.selectedBlock = [];
    this.blockData = [];
    this.blockList = [];
    this.selectedCluster = [];
    this.clusterData = [];
    this.clusterList = [];
    this.selectedSchool = [];
    this.schoolData = [];
    this.schoolList = [];

    var names = [];
    this.selectedDistricts = list.slice();
    this.districtList.map((item) => {
      this.selectedDistricts.map(i => {
        if (i == item.id) {
          names.push({ id: i, name: item.name });
        }
      })
    });
    if (this.selectedDistricts.length > 0) {
      for (let i = 0; i < this.selectedDistricts.length; i++) {
        if (i <= 9) {
          this.currentColors.push(this.colors[i]);
          this.dataWithColors.push({ id: [names[i].id], name: [names[i].name], color: this.colors[i] });
        }
      }
      if (this.selectedDistricts.length == 1) {
        this.getBlockData();
      }
      this.getCurrentDistData();
      document.getElementById('home').style.display = 'block';
      this.changeDetection.detectChanges();
    } else {
      this.onHomeClick(false);
      document.getElementById('home').style.display = 'none';
    }
  }

  shareCheckedList1(list) {
    this.currentColors = [];
    this.dataWithColors = [];
    this.selectedCluster = [];
    this.clusterList = [];
    this.clusterData = [];
    this.selectedSchool = [];
    this.schoolData = [];
    this.schoolList = [];
    var names = [];
    this.selectedBlock = list.slice();
    this.blockList.map((item) => {
      this.selectedBlock.map(i => {
        if (i == item.id) {
          names.push({ id: i, name: item.name });
        }
      })
    });
    if (this.selectedBlock.length > 0) {
      for (let i = 0; i < this.selectedBlock.length; i++) {
        if (i <= 9) {
          this.currentColors.push(this.colors[i]);
          this.dataWithColors.push({ id: [names[i].id], name: [names[i].name], color: this.colors[i] });
        }
      }
      if (this.selectedBlock.length == 1) {
        this.getClusterData();
      }
      this.getCurrentBlockData();
      document.getElementById('home').style.display = 'block';
      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect2)
        this.multiSelect2.showDropDown = false;
      this.shareCheckedList(this.selectedDistricts);
      document.getElementById('home').style.display = 'none';
    }
  }

  shareCheckedList2(list) {
    this.currentColors = [];
    this.dataWithColors = [];
    this.selectedSchool = [];
    var names = [];
    this.selectedCluster = list.slice();
    this.clusterList.map((item) => {
      this.selectedCluster.map(i => {
        if (i == item.id) {
          names.push({ id: i, name: item.name });
        }
      })
    });
    if (this.selectedCluster.length > 0) {
      for (let i = 0; i < this.selectedCluster.length; i++) {
        if (i <= 9) {
          this.currentColors.push(this.colors[i]);
          this.dataWithColors.push({ id: [names[i].id], name: [names[i].name], color: this.colors[i] });
        }
      }
      if (this.selectedCluster.length == 1) {
        this.getSchoolData();
      }
      this.getCurrentClusterData();
      document.getElementById('home').style.display = 'block';
      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect3)
        this.multiSelect3.showDropDown = false;

      this.shareCheckedList1(this.selectedBlock);
      document.getElementById('home').style.display = 'none';
    }
  }
  shareCheckedList3(list) {
    this.currentColors = [];
    this.dataWithColors = [];
    this.selectedSchool = [];
    var names = [];
    this.selectedSchool = list.slice();
    this.schoolList.map((item) => {
      this.selectedSchool.map(i => {
        if (i == item.id) {
          names.push({ id: i, name: item.name });
        }
      })
    });
    if (this.selectedSchool.length > 0) {
      for (let i = 0; i < this.selectedSchool.length; i++) {
        if (i <= 9) {
          this.currentColors.push(this.colors[i]);
          this.dataWithColors.push({ id: [names[i].id], name: [names[i].name], color: this.colors[i] });
        }
      }
      this.getCurrentSchoolData();
      document.getElementById('home').style.display = 'block';
      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect2)
        this.multiSelect2.showDropDown = false;

      this.shareCheckedList2(this.selectedCluster);
      document.getElementById('home').style.display = 'none';
    }
  }

  getCurrentDistData() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData = [];
    this.counts = [];
    this.level = 'District';
    if (this.districtData.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.districtData.map(element => {
          item.id.map(id => {
            if (id == element.districtId) {
              var data = [];
              element.attendance.map(i => {
                data.push(i.attendance);
                counts.push({ studentCount: i.studentCount, schoolCount: i.schoolCount });
              })
              this.currentData.push({ data: data, name: element.districtName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);
    document.getElementById('errMsg').style.display = 'none';
  }

  getCurrentBlockData() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData = [];
    this.counts = [];
    this.level = 'Block';
    if (this.blockData.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.blockData.map(element => {
          item.id.map(id => {
            if (id == element.blockId) {
              var data = [];
              element.attendance.map(i => {
                data.push(i.attendance);
                counts.push({ studentCount: i.studentCount, schoolCount: i.schoolCount });
              })
              this.currentData.push({ data: data, name: element.blockName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);
    document.getElementById('errMsg').style.display = 'none';
  }

  getCurrentClusterData() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData = [];
    this.counts = [];
    this.level = 'Cluster';
    if (this.clusterData.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.clusterData.map(element => {
          item.id.map(id => {
            if (id == element.clusterId) {
              var data = [];
              element.attendance.map(i => {
                data.push(i.attendance);
                counts.push({ studentCount: i.studentCount, schoolCount: i.schoolCount });
              })
              this.currentData.push({ data: data, name: element.clusterName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);
    document.getElementById('errMsg').style.display = 'none';
  }

  getCurrentSchoolData() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData = [];
    this.counts = [];
    this.level = 'School';
    if (this.schoolData.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.schoolData.map(element => {
          item.id.map(id => {
            if (id == element.schoolId) {
              var data = [];
              element.attendance.map(i => {
                data.push(i.attendance);
                counts.push({ studentCount: i.studentCount, schoolCount: i.schoolCount });
              })
              this.currentData.push({ data: data, name: element.schoolName, color: this.currentColors[index], index: index });
            }
          })
        });
        this.counts.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);
    document.getElementById('errMsg').style.display = 'none';
  }


  resetAllData() {

  }
}

