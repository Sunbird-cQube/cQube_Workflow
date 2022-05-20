import { ChangeDetectorRef, Component, OnInit, QueryList, ViewChild, ViewChildren } from '@angular/core';
import { AppServiceComponent } from 'src/app/app.service';
import { MultiSelectComponent } from 'src/app/common/multi-select/multi-select.component';
import { PatReportService } from 'src/app/services/pat-report.service';
import { environment } from 'src/environments/environment';
import { LineChartComponent } from '../../../common/line-chart/line-chart.component';

@Component({
  selector: 'app-sat-trends-chart',
  templateUrl: './sat-trends-chart.component.html',
  styleUrls: ['./sat-trends-chart.component.css']
})
export class SatTrendsChartComponent implements OnInit {
  state;
  level = 'state';
  chartId1 = 'chartid1';
  chartId2 = 'chartid2';

  allGrades = [];
  grade = "AllGrades";

  public waterMark = environment.water_mark

  //For multi-select dropdown options::::::::::::::::::
  counts: any = [];
  counts1: any = [];
  districtList: any = [];
  blockList: any = [];

  districtData = [];
  districtData1 = [];

  blockData: any = [];
  blockData1: any = [];
  selectedBlock: any = [];
  clusterList: any = [];
  clusterData: any = [];
  clusterData1: any = [];
  selectedCluster: any = [];
  schoolList: any = [];
  schoolData: any = [];
  schoolData1: any = [];
  selectedSchool: any = [];
  selectedDistricts = [];

  //For academic year selection::::::::::::::::::::::::::::::::
  years = [];
  selectedYear;
  selectedYear1;

  //For management and category
  managementName;
  management;
  category;

  data: any = [];
  data1: any = [];
  currentData = [];
  currentData1 = [];

  //the order of academic year months to sort options accordingly
  xAxisLabels = ['Semester 1', "Semester 2"];

  height = window.innerHeight;

  constructor(public commonService: AppServiceComponent, public service: PatReportService, private changeDetection: ChangeDetectorRef) { }

  @ViewChildren(MultiSelectComponent) multiSelect: QueryList<MultiSelectComponent>;
  @ViewChild('multiSelect1') multiSelect1: MultiSelectComponent;
  @ViewChild('multiSelect2') multiSelect2: MultiSelectComponent;
  @ViewChild('multiSelect3') multiSelect3: MultiSelectComponent;
  @ViewChild('multiSelect4') multiSelect4: MultiSelectComponent;

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false


  ngOnInit(): void {

    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById("backBtn") ? document.getElementById("backBtn").style.display = "none" : "";

    this.state = this.commonService.state;
    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );
    this.service
      .gradeMetaData({
        period: 'all',
        report: "sat",
        year: this.selectedYear
      })
      .subscribe(
        (res) => {
          if (res["data"]["block"]) {
            this.allGrades = res["data"]["block"];
          }
          this.allGrades.sort((a, b) =>
            a.grade > b.grade ? 1 : b.grade > a.grade ? -1 : 0
          );
          this.allGrades.unshift({ grade: 'AllGrades' });
        });
    this.service.getAcademicYears().subscribe(res => {
      this.years = res['years'];
      this.selectedYear = this.years[0];
      this.selectedYear1 = this.years[1];
      this.onResize();
      this.onHomeClick(false);
    }, err => {
    })
    this.changeDetection.detectChanges();

    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? true : false;
  }

  onResize() {
    this.height = window.innerHeight;
  }

  selected = "relative";
  getSelected(data) {
    this.selected = data;
  }

  //on select of year drop down:::::::::::::::::::::::
  onSelectYear() {
    this.commonService.errMsg();
    if (this.level == 'State') {
      this.currentColors = [];
      this.dataWithColors = [];
      this.onHomeClick(true);
    } else if (this.level == 'District') {
      this.districtData = [];
      this.service.getDistrictData({ ...{ year: this.selectedYear }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.districtData = res['data'];
        var districtList = this.districtList.map(district => {
          if (this.selectedDistricts.includes(district.id)) {
            district.status = true;
          } else {
            district.status = false;
          }
          return district;
        });
        this.districtList = districtList;
        this.districtList = this.districtList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        this.getCurrentDistData();
      }, err => {
        this.currentData = [];
      });
      this.districtData1 = [];
      this.service.getDistrictData({ ...{ year: this.selectedYear1 }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.districtData1 = res['data'];
        this.getCurrentDistData1();
      }, err => {
        this.currentData1 = [];
      });
    } else if (this.level == 'Block') {
      this.blockData = [];
      this.service.getBlockData({ ...{ year: this.selectedYear, districtId: this.selectedDistricts[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.blockData = res['data'];
        var blockList = this.blockList.map(block => {
          if (this.selectedBlock.includes(block.id)) {
            block.status = true;
          } else {
            block.status = false;
          }
          return block;
        });
        this.blockList = blockList;
        this.blockList = this.blockList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        this.getCurrentBlockData();
      }, err => {
        this.currentData = [];
      });
      this.blockData1 = [];
      this.service.getBlockData({ ...{ year: this.selectedYear1, districtId: this.selectedDistricts[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.blockData1 = res['data'];
        this.getCurrentBlockData1();
      }, err => {
        this.currentData1 = [];
      })
    } else if (this.level == 'Cluster') {
      this.clusterData = [];
      this.service.getClusterData({ ...{ year: this.selectedYear, blockId: this.selectedBlock[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.clusterData = res['data'];
        var clusterList = this.clusterList.map(cluster => {
          if (this.selectedCluster.includes(cluster.id)) {
            cluster.status = true;
          } else {
            cluster.status = false;
          }
          return cluster;
        });
        this.clusterList = clusterList;
        this.clusterList = this.clusterList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        this.getCurrentClusterData();
      }, err => {
        this.currentData = [];
      })
      this.clusterData1 = [];
      this.service.getClusterData({ ...{ year: this.selectedYear1, blockId: this.selectedBlock[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.clusterData1 = res['data'];
        this.getCurrentClusterData1();
      }, err => {
        this.currentData1 = [];
      })
    } else if (this.level == 'School') {
      this.schoolData = [];
      this.service.getSchoolData({ ...{ year: this.selectedYear, clusterId: this.selectedCluster[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.schoolData = res['data'];
        var schoolList = this.schoolList.map(school => {
          if (this.selectedSchool.includes(school.id)) {
            school.status = true;
          } else {
            school.status = false;
          }
          return school;
        });
        this.schoolList = schoolList;
        this.schoolList = this.schoolList.sort((a, b) => (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0));
        this.getCurrentSchoolData();
      }, err => {
        this.currentData = [];
      })
      this.schoolData1 = [];
      this.service.getSchoolData({ ...{ year: this.selectedYear1, clusterId: this.selectedCluster[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
        this.schoolData1 = res['data'];
        this.getCurrentSchoolData1();
      }, err => {
        this.currentData1 = [];
      })
    }

  }

  onGradeSelect(grade) {
    this.grade = grade;
    this.currentColors = [];
    this.dataWithColors = [];
    this.onHomeClick(true);
  }

  //this will reset the page content::::::::::::::::::::::::::::
  onHomeClick(defYear) {
    this.commonService.errMsg();
    if (!defYear) {
      this.selectedYear = this.years[0];
      this.selectedYear1 = this.years[1];
    }
    this.grade = "AllGrades";
    this.getStateData();
    this.getStateData1();
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

  }

  //this is to get state level data::::::::::
  getStateData() {
    this.level = 'State';
    this.service.getStateData({ ...{ year: this.selectedYear }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe(res => {
      this.data = res['data'];
      var data = [];
      this.counts = [];
      var counts = [];
      this.currentData = [];
      this.data.map(item => {
        item.performance.map(i => {
          data.push(i.performance);
          counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount, index: 0 });
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

  getStateData1() {
    this.level = 'State';
    this.service.getStateData({ ...{ year: this.selectedYear1 }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe(res => {
      this.data1 = res['data'];
      var data = [];
      this.counts1 = [];
      var counts = [];
      this.currentData1 = [];
      this.data1.map(item => {
        item.performance.map(i => {
          data.push(i.performance);
          counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount, index: 0 });
        });
        this.counts1.push(counts);
        this.currentData1.push({ data: data, name: this.state, color: '#00FF00' });
        this.commonService.loaderAndErr(this.currentData1);
      });
      this.getDistrictData1();
    }, err => {
      this.data1 = [];
      this.currentData1 = [];
      this.commonService.loaderAndErr(this.data1);
    })
  }

  //this is to get district level data:::::::::::::::::::::
  getDistrictData() {
    this.districtList = [];
    this.districtData = [];
    this.service.getDistrictData({ ...{ year: this.selectedYear }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
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
      this.currentData = [];
    })
  }

  getDistrictData1() {
    this.districtData1 = [];
    this.service.getDistrictData({ ...{ year: this.selectedYear1 }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
      this.districtData1 = res['data'];
    }, err => {
      this.currentData1 = [];
    })
  }


  //this is to get block level data
  getBlockData() {
    this.blockList = [];
    this.blockData = [];
    if (this.selectedDistricts.length == 1) {
      this.service.getBlockData({ ...{ year: this.selectedYear, districtId: this.selectedDistricts[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
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
        this.currentData = [];
      })
    }
    else {
      this.blockData = [];
    }
  }

  getBlockData1() {
    this.blockData1 = [];
    this.service.getBlockData({ ...{ year: this.selectedYear1, districtId: this.selectedDistricts[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
      this.blockData1 = res['data'];
    }, err => {
      this.currentData1 = [];
    })
  }

  //This is to get cluster level data::::::::::::
  getClusterData() {
    this.clusterList = [];
    this.clusterData = [];
    if (this.selectedBlock.length == 1) {
      this.service.getClusterData({ ...{ year: this.selectedYear, blockId: this.selectedBlock[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
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
        this.currentData = [];
      })
    } else {
      this.clusterData = [];
    }
  }

  getClusterData1() {
    this.clusterData1 = [];
    this.service.getClusterData({ ...{ year: this.selectedYear1, blockId: this.selectedBlock[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
      this.clusterData1 = res['data'];
    }, err => {
      this.currentData1 = [];
    })
  }

  //This is to get school level data::::::::::
  getSchoolData() {
    this.schoolList = [];
    this.schoolData = [];
    if (this.selectedCluster.length == 1) {
      this.service.getSchoolData({ ...{ year: this.selectedYear, clusterId: this.selectedCluster[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
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
        this.currentData = [];
      })
    } else {
      this.schoolData = [];
    }
  }

  getSchoolData1() {
    this.schoolData1 = [];
    this.service.getSchoolData({ ...{ year: this.selectedYear1, clusterId: this.selectedCluster[0] }, ...{ management: this.management, category: this.category, grade: this.grade != "AllGrades" ? this.grade : "" } }).subscribe((res: any) => {
      this.schoolData1 = res['data'];
    }, err => {
      this.currentData1 = [];
    })
  }

  //This is to set line colors::::::::::
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
        this.getBlockData1();
      }
      this.getCurrentDistData();
      this.getCurrentDistData1();

      this.changeDetection.detectChanges();
    } else {
      this.onHomeClick(false);
      this.changeDetection.detectChanges();

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
        this.getClusterData1();
      }
      this.getCurrentBlockData();
      this.getCurrentBlockData1();

      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect2)
        this.multiSelect2.showDropDown = false;
      this.shareCheckedList(this.selectedDistricts);
      this.changeDetection.detectChanges();

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
        this.getSchoolData1();
      }
      this.getCurrentClusterData();
      this.getCurrentClusterData1();

      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect3)
        this.multiSelect3.showDropDown = false;

      this.shareCheckedList1(this.selectedBlock);
      this.changeDetection.detectChanges();

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
      this.getCurrentSchoolData1();

      this.changeDetection.detectChanges();
    } else {
      if (this.multiSelect2)
        this.multiSelect2.showDropDown = false;
      this.shareCheckedList2(this.selectedCluster);
      this.changeDetection.detectChanges();

    }
  }


  //get selected district data::::::::::::::::
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
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
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

  }

  getCurrentDistData1() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData1 = [];
    this.counts1 = [];
    this.level = 'District';
    if (this.districtData1.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.districtData1.map(element => {
          item.id.map(id => {
            if (id == element.districtId) {
              var data = [];
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
              })
              this.currentData1.push({ data: data, name: element.districtName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts1.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);

  }

  //get selected block data:::::::::::
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
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
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

  }

  getCurrentBlockData1() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData1 = [];
    this.counts1 = [];
    this.level = 'Block';
    if (this.blockData1.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.blockData1.map(element => {
          item.id.map(id => {
            if (id == element.blockId) {
              var data = [];
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
              })
              this.currentData1.push({ data: data, name: element.blockName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts1.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);

  }

  //get selected cluster data:::::::::::::::::::::
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
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
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

  }

  getCurrentClusterData1() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData1 = [];
    this.counts1 = [];
    this.level = 'Cluster';
    if (this.clusterData1.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.clusterData1.map(element => {
          item.id.map(id => {
            if (id == element.clusterId) {
              var data = [];
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
              })
              this.currentData1.push({ data: data, name: element.clusterName, color: this.currentColors[index], index: index });
            }
          })
        })
        this.counts1.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);

  }

  //get selected school data:::::::::::::::::::::::::
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
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
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

  }

  getCurrentSchoolData1() {
    document.getElementById('spinner').style.display = 'block';
    this.currentData1 = [];
    this.counts1 = [];
    this.level = 'School';
    if (this.schoolData1.length > 0) {
      this.dataWithColors.map((item, index) => {
        var counts = [];
        this.schoolData1.map(element => {
          item.id.map(id => {
            if (id == element.schoolId) {
              var data = [];
              element.performance.map(i => {
                data.push(i.performance);
                counts.push({ studentCount: i.studentCount, studentAttended: i.studentAttended, grade: this.grade, schoolCount: i.schoolCount });
              })
              this.currentData1.push({ data: data, name: element.schoolName, color: this.currentColors[index], index: index });
            }
          })
        });
        this.counts1.push(counts);
      });
    }
    setTimeout(() => {
      document.getElementById('spinner').style.display = 'none';
    }, 400);

  }


  resetAllData() {

  }
}