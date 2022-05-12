import { Component, OnInit, ChangeDetectorRef, ViewChild, ElementRef, AfterViewInit, HostListener } from '@angular/core';
import { Router } from '@angular/router';
import { AppServiceComponent } from 'src/app/app.service';
import { environment } from 'src/environments/environment';
import * as _ from "lodash"
import { progressCardService } from 'src/app/services/progress-card.service';

@Component({
  selector: 'app-progress-card',
  templateUrl: './progress-card.component.html',
  styleUrls: ['./progress-card.component.css']
})
export class progressCardComponent implements OnInit, AfterViewInit {
  innerWidth = 772;
  @HostListener('window:resize', ['$event'])
  onResize(event) {
    this.innerWidth = window.innerWidth;
  }
  tooltip: any = "";
  state = '';
  placeHolder = "First Choose Level From Drop-down";
  level;
  keys;
  updatedKeys: any;
  yourData: any;
  districtName: any;
  names = [];
  blocks = [];
  clusters = [];
  schools = [];
  ids = [];
  blockIds = [];
  clusterIds = [];
  schoolIds = [];
  districtObjArr = [];
  progressCardData = {};



  schoolInfra = [];
  schoolInfraKey = [];
  schoolInfraRank = [];
  schoolInfraRankKye = [];

  schoolAttendance = [];
  schoolAttendanceKeys = [];
  schoolAttendanceRank = [];
  schoolAttendanceRankKey = [];
  schoolAttendanceCategory = [];
  schoolAttendanceCategoryKey = [];

  semPerformance = [];
  semPerformanceKeys = [];
  semPerfromanceRank = [];
  semPerformanceRankKey = [];
  semPerformanceCategory = [];
  semPerformanceCategoryKey = [];

  patPerformance = [];
  patPerformanceKeys = [];
  patPerformanceRank = [];
  patPerformanceRankKey = [];
  patPerformanceCategory = [];
  patPerformanceCategoryKay = [];

  crcVisit = [];
  crcVisitKeys = [];

  UDISE = [];
  UDISEKeys = [];
  UDISERank = [];
  UDISERankKeys = [];
  UDISECategory = [];
  UDISECategoryKey = [];

  tooltipInfra = [];
  toolTipInfraKeys = [];
  tooltipStdAttendance = [];
  tooltipStdAttendanceKeys = [];
  tooltimSem = [];
  tooltipSemKeys = [];
  tooltipPat = [];
  tooltipPatKeys = [];
  tooltipCrc = [];
  tooltipCrcKeys = [];
  tooltipUDISE = [];
  tooltipUDISEKyes = [];

  allData: any;
  showAll = false;
  height;
  selectedLevelData: any;
  showLink = true;
  params: any;

  public semLength;
  public udiseLength;
  public crcLength;
  public infraLength;

  placement = 'bottom-left';

  timeRange = [{ key: 'overall', value: "Overall" }, { key: 'last_30_days', value: "Last 30 Days" }];
  period = 'overall';

  @ViewChild('searchInput') searchInput: ElementRef;
  semPerformTooltip: any[];
  semPerformTooltipKeys: any[];

  //for Progress circle
  progress = 50.5;
  progressBar = document.querySelector('.progress-bar');

  // for Progress card category values
  progressCardValues = environment.progressCardConfig;
  // progressCardCategory = [`value_below_${this.progressCardValues[0]}`, `value_between_${this.progressCardValues[1]}`, `value_between_${this.progressCardValues[2]}`, `value_above_${this.progressCardValues[3]}`];

  progressCardCategory = ["poor", "average", "good", "excellent"];

  AttendanceCategoryKey = [`Attendance Less Than ${this.progressCardValues[0]}%`,
  `Attendance Between ${this.progressCardValues[1].split("-")[0]}% to ${this.progressCardValues[1].split("-")[1]}%`,
  `Attendance Between ${this.progressCardValues[2].split("-")[0]}% to ${this.progressCardValues[2].split("-")[1]}%`,
  `Attendance Above ${this.progressCardValues[3]}%`];

  performanceCategoryKey = [`Performance Less Than ${this.progressCardValues[0]}%`,
  `Performance Between ${this.progressCardValues[1].split("-")[0]}% to ${this.progressCardValues[1].split("-")[1]}%`,
  `Performance Between ${this.progressCardValues[2].split("-")[0]}% to ${this.progressCardValues[2].split("-")[1]}%`,
  `Performance Above ${this.progressCardValues[3]}%`];

  schoolCategoryKey = [`Schools Less Than ${this.progressCardValues[0]}%`,
  `Schools Between ${this.progressCardValues[1].split("-")[0]}% to ${this.progressCardValues[1].split("-")[1]}%`,
  `Schools Between ${this.progressCardValues[2].split("-")[0]}% to ${this.progressCardValues[2].split("-")[1]}%`,
  `Schools Above ${this.progressCardValues[3]}%`];

  infraCategoryKey = [`Infrastructure Score Less Than ${this.progressCardValues[0]}%`,
  `Infrastructure Score Between ${this.progressCardValues[1].split("-")[0]}% to ${this.progressCardValues[1].split("-")[1]}%`,
  `Infrastructure Score Between ${this.progressCardValues[2].split("-")[0]}% to ${this.progressCardValues[2].split("-")[1]}%`,
  `Infrastructure Score Above ${this.progressCardValues[3]}%`];


  managementName;
  management;
  category;


  constructor(private cdr: ChangeDetectorRef, public commonService: AppServiceComponent, public service: progressCardService, private readonly _router: Router, private readonly _cd: ChangeDetectorRef) { }

  public userAccessLevel = localStorage.getItem("userLevel");
  public hideIfAccessLevel: boolean = false
  public hideAccessBtn: boolean = false

  ngOnInit(): void {
    document.getElementById('backBtn') ? document.getElementById('backBtn').style.display = 'none' : "";
    document.getElementById('accessProgressCard').style.display = 'none';
    document.getElementById('myInput')['disabled'] = true;
    this.state = this.commonService.state;

    this.managementName = this.management = JSON.parse(localStorage.getItem('management')).id;
    this.category = JSON.parse(localStorage.getItem('category')).id;
    this.managementName = this.commonService.changeingStringCases(
      this.managementName.replace(/_/g, " ")
    );

    this.params = JSON.parse(sessionStorage.getItem('progress-card-info'));

    if (this.params) {
      if (this.params.timePeriod == 'overall' || this.params.timePeriod == 'last_30_days') {
        this.period = this.params.timePeriod;
      } else {
        this.period = 'overall';
      }
    }

    if (this.params && this.params.level) {
      this.level = this.params.level;
      if (this.level == 'state') {
        this.stateData();
      }
    } else {
      this.stateData();
    }

    this.hideAccessBtn = (environment.auth_api === 'cqube' || this.userAccessLevel === '' || undefined) ? true : false;
  }

  onPeriodSelect() {
    if (this.level == 'state') {
      this.stateData();
    } else {
      this.onSubmit();
    }
  }

  ngAfterViewInit(): void {
    this.exist = true;
    this.cdr.detectChanges();
    if (this.params && this.params.level) {
      if (this.params.level != 'state') {
        this.len = 2;
        this.value = this.params.value;
        this.searchInput.nativeElement.value = this.params.value;
        this._cd.detectChanges();
        this.selectedLevel(true);
      }
    }
  }

  onHomeSelect() {
    this.period = "overall";
    this.stateData();
  }
  stateData() {
    document.getElementById('spinner').style.display = 'block';
    this.semLength = 2;
    this.udiseLength = -1;
    this.crcLength = 1;
    this.infraLength = -1;
    this.height = '380px';
    this.level = "state";
    document.getElementById('myInput')['disabled'] = true;
    document.getElementById('myInput')['value'] = '';
    this.placeHolder = "First Choose Level From Drop-down";
    this.service.stateData({ ...{ timePeriod: this.period }, ...{ management: this.management, category: this.category } }).subscribe(res => {
      this.progressCardData = res['data'];
      this.schoolInfra = ['infra_score'];
      this.schoolInfraKey = ['Infrastructure Score'];
      this.schoolInfraRank = ['district_level_rank_within_the_state'];
      this.schoolInfraRankKye = ['State'];

      this.schoolAttendance = ['attendance'];
      this.schoolAttendanceKeys = ['Attendance'];
      // this.schoolAttendanceCategory = ['poor', 'average', 'good', 'excellent'];
      this.schoolAttendanceCategory = this.progressCardCategory;
      this.schoolAttendanceCategoryKey = this.AttendanceCategoryKey
      this.semPerformance = ['performance'];
      this.semPerformanceKeys = ['Performance']
      // this.semPerformanceCategory = ['poor', 'average', 'good', 'excellent'];
      this.semPerformanceCategory = this.progressCardCategory;
      this.semPerformanceCategoryKey = this.performanceCategoryKey;

      this.patPerformance = ['school_performance'];
      this.patPerformanceKeys = ['Performance'];
      // this.patPerformanceCategory = ['poor', 'average', 'good', 'excellent'];
      this.patPerformanceCategory = this.progressCardCategory;
      this.patPerformanceCategoryKay = this.schoolCategoryKey;
      // if(this.progressCardData['crc_visit'])
      //   this.crcVisit = Object.keys(this.progressCardData['crc_visit']);
      // this.crcVisitKeys = [];

      this.crcVisit = ['schools_0', 'schools_1_2', 'schools_3_5', 'schools_6_10', 'schools_10'];
      this.crcVisitKeys = ['Schools Visited 0 Times', 'Schools Visited 1-2 Times', 'Schools Visited 3-5 Times', 'Schools Visited 6-10 Times', 'Schools Visited more Than 10 Times'];

      this.UDISE = ['infrastructure_score'];
      this.UDISEKeys = ['Infrastructure Score'];
      // this.UDISECategory = ['poor', 'average', 'good', 'excellent'];
      this.UDISECategory = this.progressCardCategory;
      this.UDISECategoryKey = this.infraCategoryKey;

      this.showData(this.progressCardData);
      document.getElementById('spinner').style.display = 'none';
    }, err => {
      this.err = true;
      this.showAll = false;
      document.getElementById('spinner').style.display = 'none';
    });
  }

  public err = false;
  onSubmit() {
    this.err = false;
    this.showAll = false;
    this.showLink = true;
    document.getElementById('spinner').style.display = 'block';
    this.exist = false;
    this.cdr.detectChanges();
    this.districtName = document.getElementById('myInput')['value'];
    var id;
    if (this.ids.includes(this.districtName) || this.names.includes(this.districtName)) {
      document.getElementById('warning').style.display = 'none';
      document.getElementById('warning1').style.display = 'block';
    }
    if (this.districtName) {
      if (this.level == 'district') {
        this.semLength = 2;
        this.udiseLength = 4;
        this.crcLength = 1;
        this.infraLength = 3;
        this.height = '380px';
        var dist;
        if (this.districtName.match(/^\d/)) {
          id = parseInt(this.districtName);
          dist = this.districtObjArr.find(a => a.id === id);
        } else {
          dist = this.districtObjArr.find(a => a.name == this.districtName);
          if (dist) {
            id = dist.id;
          }
        }

        this.selectedLevelData = dist;
        this.service.districtWiseData({ ...{ id: id, timePeriod: this.period }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.progressCardData = res['districtData'][0];
          this.schoolInfra = ['infra_score'];
          this.schoolInfraKey = ['Infrastructure Score'];
          this.schoolInfraRank = ['district_level_rank_within_the_state'];
          this.schoolInfraRankKye = ['State'];

          this.schoolAttendance = ['attendance'];
          this.schoolAttendanceKeys = ['Attendance'];
          this.schoolAttendanceCategory = this.progressCardCategory;
          // this.schoolAttendanceCategoryKey = ['Attendance Less Than 33%', 'Attendance Between 33% to 60%', 'Attendance Between 60% to 75%', 'Attendance Above 75%'];
          this.schoolAttendanceCategoryKey = this.AttendanceCategoryKey;
          this.semPerformance = ['performance'];
          this.semPerformanceKeys = ['Performance']
          this.semPerformanceCategory = this.progressCardCategory;
          // this.semPerformanceCategoryKey = ['Performance Less Than 33%', 'Performance Between 33% to 60%', 'Performance Between 60% to 75%', 'Performance Above 75%'];
          this.semPerformanceCategoryKey = this.performanceCategoryKey;

          this.patPerformance = ['district_performance'];
          this.patPerformanceKeys = ['Performance'];
          // this.patPerformanceCategory = ['poor', 'average', 'good', 'excellent'];
          this.patPerformanceCategory = this.progressCardCategory;
          // this.patPerformanceCategoryKay = ['Schools Less Than 33%', 'Schools Between 33% to 60%', 'Schools Between 60% to 75%', 'Schools Above 75%'];
          this.patPerformanceCategoryKay = this.schoolCategoryKey;

          this.crcVisit = ['schools_0', 'schools_1_2', 'schools_3_5', 'schools_6_10', 'schools_10'];
          this.crcVisitKeys = ['Schools Visited 0 Times', 'Schools Visited 1-2 Times', 'Schools Visited 3-5 Times', 'Schools Visited 6-10 Times', 'Schools Visited more Than 10 Times'];

          this.UDISE = ['infrastructure_score'];
          this.UDISEKeys = ['Infrastructure Score'];
          this.UDISECategory = this.progressCardCategory;
          // this.UDISECategoryKey = ['Infrastructure Score Less Than 33%', 'Infrastructure Score Between 33% to 60%', 'Infrastructure Score Between 60% to 75%', 'Infrastructure Score Above 75%'];

          this.UDISECategoryKey = this.infraCategoryKey;
          this.showData(this.progressCardData);
          document.getElementById('spinner').style.display = 'none';
        }, err => {
          this.err = true;
          this.showAll = false;
          document.getElementById('spinner').style.display = 'none';
        });
      } else if (this.level == 'block') {
        this.semLength = 4;
        this.udiseLength = 5;
        this.crcLength = 3;
        this.infraLength = 5;
        this.height = '380px';
        var block;
        id;
        if (this.districtName.match(/^\d/)) {
          id = parseInt(this.districtName);
          block = this.districtObjArr.find(a => a.id == id);
        } else {
          block = this.districtObjArr.find(a => a.name == this.districtName);
          if (block) {
            id = block.id;
          }
        }

        this.selectedLevelData = block;
        this.service.blockWiseData({ ...{ id: id, timePeriod: this.period }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.progressCardData = res['blockData'][0];
          this.schoolInfra = ['infra_score'];
          this.schoolInfraKey = ['Infrastructure Score'];
          this.schoolInfraRank = ['block_level_rank_within_the_state', 'block_level_rank_within_the_district'];
          this.schoolInfraRankKye = ['State', 'District'];

          this.schoolAttendance = ['attendance'];
          this.schoolAttendanceKeys = ['Attendance'];
          this.schoolAttendanceCategory = this.progressCardCategory;
          // this.schoolAttendanceCategoryKey = ['Attendance Less Than 33%', 'Attendance Between 33% to 60%', 'Attendance Between 60% to 75%', 'Attendance Above 75%'];
          this.schoolAttendanceCategoryKey = this.AttendanceCategoryKey;
          this.semPerformance = ['performance'];
          this.semPerformanceKeys = ['Performance'];
          this.semPerformanceCategory = this.progressCardCategory;
          // this.semPerformanceCategoryKey = ['Performance Less Than 33%', 'Performance Between 33% to 60%', 'Performance Between 60% to 75%', 'Performance Above 75%'];
          this.semPerformanceCategoryKey = this.performanceCategoryKey;

          this.patPerformance = ['block_performance'];
          this.patPerformanceKeys = ['Performance'];

          this.crcVisit = ['schools_0', 'schools_1_2', 'schools_3_5', 'schools_6_10', 'schools_10'];
          this.crcVisitKeys = ['Schools Visited 0 Times', 'Schools Visited 1-2 Times', 'Schools Visited 3-5 Times', 'Schools Visited 6-10 Times', 'Schools Visited more Than 10 Times'];

          this.UDISE = ['infrastructure_score'];
          this.UDISEKeys = ['Infrastructure Score'];
          this.UDISECategory = this.progressCardCategory;
          // this.UDISECategoryKey = ['Infrastructure Score Less Than 33%', 'Infrastructure Score Between 33% to 60%', 'Infrastructure Score Between 60% to 75%', 'Infrastructure Score Above 75%'];
          this.UDISECategoryKey = this.infraCategoryKey;
          this.showData(this.progressCardData);
          document.getElementById('spinner').style.display = 'none';
        }, err => {
          this.err = true;
          this.showAll = false;
          document.getElementById('spinner').style.display = 'none';
        });
      } else if (this.level == 'cluster') {
        this.semLength = 6;
        this.udiseLength = 6;
        this.crcLength = 5;
        this.infraLength = 7;
        this.height = '380px';
        var cluster;
        let blkId;
        if (this.districtName.match(/^\d/)) {
          cluster = this.districtObjArr.find(a => a.id == this.districtName);
          id = parseInt(this.districtName);
          blkId = cluster.blockId;
        } else {
          cluster = this.districtObjArr.find(a => a.name == this.districtName);
          if (cluster) {
            id = cluster.id;
            blkId = cluster.blockId;
          }
        }

        this.selectedLevelData = cluster;
        this.service.clusterWiseData({ ...{ id: id, blockId: blkId, timePeriod: this.period }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.progressCardData = res['clusterData'][0];
          this.schoolInfra = ['infra_score'];
          this.schoolInfraKey = ['Infrastructure Score'];
          this.schoolInfraRank = ['cluster_level_rank_within_the_state', 'cluster_level_rank_within_the_district', 'cluster_level_rank_within_the_block'];
          this.schoolInfraRankKye = ['State', 'District', 'Block'];

          this.schoolAttendance = ['attendance'];
          this.schoolAttendanceKeys = ['Attendance'];
          this.schoolAttendanceCategory = this.progressCardCategory;
          // this.schoolAttendanceCategoryKey = ['Attendance Less Than 33%', 'Attendance Between 33% to 60%', 'Attendance Between 60% to 75%', 'Attendance Above 75%'];
          this.schoolAttendanceCategoryKey = this.AttendanceCategoryKey;

          this.semPerformance = ['performance'];
          this.semPerformanceKeys = ['Performance'];
          this.semPerformanceCategory = this.progressCardCategory;
          // this.semPerformanceCategoryKey = ['Performance Less Than 33%', 'Performance Between 33% to 60%', 'Performance Between 60% to 75%', 'Performance Above 75%'];

          this.semPerformanceCategoryKey = this.performanceCategoryKey;
          this.patPerformance = ['cluster_performance'];
          this.patPerformanceKeys = ['Performance'];

          this.crcVisit = ['schools_0', 'schools_1_2', 'schools_3_5', 'schools_6_10', 'schools_10'];
          this.crcVisitKeys = ['Schools Visited 0 Times', 'Schools Visited 1-2 Times', 'Schools Visited 3-5 Times', 'Schools Visited 6-10 Times', 'Schools Visited more Than 10 Times'];

          this.UDISE = ['infrastructure_score'];
          this.UDISEKeys = ['Infrastructure Score'];
          this.UDISECategory = this.progressCardCategory;
          // this.UDISECategoryKey = ['Infrastructure Score Less Than 33%', 'Infrastructure Score Between 33% to 60%', 'Infrastructure Score Between 60% to 75%', 'Infrastructure Score Above 75%'];

          this.UDISECategoryKey = this.infraCategoryKey;
          this.showData(this.progressCardData);
          document.getElementById('spinner').style.display = 'none';
        }, err => {
          this.err = true;
          this.showAll = false;
          document.getElementById('spinner').style.display = 'none';
        });
      } else if (this.level == 'school') {
        this.semLength = 9;
        this.udiseLength = 8;
        this.crcLength = 7;
        this.infraLength = 9;
        this.height = '280px';
        var school;
        var blok;
        this.showLink = false;
        if (this.districtName.match(/^\d/)) {
          school = this.districtObjArr.find(a => a.id == this.districtName);
          id = parseInt(this.districtName);
          blok = school.blockId;
        } else {
          school = this.districtObjArr.find(a => a.name == this.districtName);
          if (school) {
            id = school.id;
            blok = school.blockId;
          }
        }
        this.service.schoolWiseData({ ...{ id: id, blockId: blok, timePeriod: this.period }, ...{ management: this.management, category: this.category } }).subscribe(res => {
          this.progressCardData = res['schoolData'][0];
          this.schoolInfra = ['infra_score'];
          this.schoolInfraKey = ['Infrastructure Score'];
          this.schoolInfraRank = ['school_level_rank_within_the_state', 'school_level_rank_within_the_district', 'school_level_rank_within_the_block', 'school_level_rank_within_the_cluster'];
          this.schoolInfraRankKye = ['State', 'District', 'Block', 'Cluster'];

          this.schoolAttendance = ['attendance'];
          this.schoolAttendanceKeys = ['Attendance'];
          this.schoolAttendanceCategory = this.progressCardCategory;
          // this.schoolAttendanceCategoryKey = ['Attendance Less Than 33%', 'Attendance Between 33% to 60%', 'Attendance Between 60% to 75%', 'Attendance Above 75%'];
          this.schoolAttendanceCategoryKey = this.AttendanceCategoryKey;
          this.semPerformance = ['performance'];
          this.semPerformanceKeys = ['Performance'];
          this.semPerformanceCategory = this.progressCardCategory;
          // this.semPerformanceCategoryKey = ['Performance Less Than 33%', 'Performance Between 33% to 60%', 'Performance Between 60% to 75%', 'Performance Above 75%'];

          this.semPerformanceCategoryKey = this.performanceCategoryKey;
          this.patPerformance = ['school_performance'];
          this.patPerformanceKeys = ['Performance'];

          this.crcVisit = ['schools_0', 'schools_1_2', 'schools_3_5', 'schools_6_10', 'schools_10'];
          this.crcVisitKeys = ['Schools Visited 0 Times', 'Schools Visited 1-2 Times', 'Schools Visited 3-5 Times', 'Schools Visited 6-10 Times', 'Schools Visited more Than 10 Times'];

          this.UDISE = ['infrastructure_score'];
          this.UDISEKeys = ['Infrastructure Score'];
          this.UDISECategory = this.progressCardCategory;
          // this.UDISECategoryKey = ['Infrastructure Score Less Than 33%', 'Infrastructure Score Between 33% to 60%', 'Infrastructure Score Between 60% to 75%', 'Infrastructure Score Above 75%'];

          this.UDISECategoryKey = this.infraCategoryKey;
          this.showData(this.progressCardData);
          document.getElementById('spinner').style.display = 'none';
        }, err => {
          this.err = true;
          this.showAll = false;
          document.getElementById('spinner').style.display = 'none';
        });
      }
    } else {
      alert("Please enter valid id/name");
      document.getElementById('spinner').style.display = 'none';
    }

  }

  infraColor;
  stdAttendanceColor;
  semColor;
  patColor;
  crcColor;
  udiseColor;
  patPerformTooltip = [];
  patPerformTooltipKeys = [];
  infraTooltipMetrics = [];
  semPerformancePercent = ['percent_below_33', 'percent_between_33_60', 'percent_between_60_75', 'percent_above_75', 'state_level_score'];
  stdAttdRankMatrixColor;
  semRankMatrixColor;
  patRankMatrixColor;
  infraRankMatrixColor;
  udiseRankMatrixColor;
  crcRankMatrixColor;

  stdAttdRankMatrixValue;
  semRankMatrixValue;
  patRankMatrixValue;
  infraRankMatrixValue;
  udiseRankMatrixValue;
  crcRankMatrixValue;

  showData(progressCardData) {
    if (this.level != 'state') {
      if (this.level != 'school')
        progressCardData['total_schools'] = progressCardData['total_schools'] ? progressCardData['total_schools'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : "";
      progressCardData['total_students'] = progressCardData['total_students'] ? progressCardData['total_students'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,") : "";
      if (progressCardData['school_management_type'])
        progressCardData['school_management_type'] = this.commonService.changeingStringCases(progressCardData['school_management_type'].replace(/_/g, ' '))
      this.updatedKeys = [];
      this.keys = Object.keys(progressCardData);
      let index = this.keys.indexOf('district_id');
      if (index > -1) {
        this.keys.splice(index, 1);
      }
      index = this.keys.indexOf('block_id');
      if (index > -1) {
        this.keys.splice(index, 1);
      }
      index = this.keys.indexOf('cluster_id');
      if (index > -1) {
        this.keys.splice(index, 1);
      }
      index = this.keys.indexOf('school_id');
      if (index > -1) {
        this.keys.splice(index, 1);
      }
      this.keys = this.keys.filter(key => {
        if (typeof progressCardData[`${key}`] != 'object') {
          let myKey = this.stringConverter(key);
          this.updatedKeys.push(myKey);
          return key;
        }
      });
    } else {
      this.updatedKeys = [];
      progressCardData['basic_details']['total_schools'] = !progressCardData['basic_details']['total_schools'] ? "" : progressCardData['basic_details']['total_schools'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      progressCardData['basic_details']['total_students'] = !progressCardData['basic_details']['total_students'] ? "" : progressCardData['basic_details']['total_students'].toString().replace(/(\d)(?=(\d\d)+\d$)/g, "$1,");
      if (progressCardData['basic_details']['school_management_type'])
        progressCardData['basic_details']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['basic_details']['school_management_type'].replace(/_/g, ' '))
      this.keys = Object.keys(progressCardData['basic_details']);
      this.keys = this.keys.filter(key => {
        let myKey = this.stringConverter(key);
        this.updatedKeys.push(myKey);
        return key;
      });
    }

    this.showAll = true;
    this.err = false;
    var myKey;
    this.tooltipInfra = [];
    this.toolTipInfraKeys = [];
    this.tooltipStdAttendance = [];
    this.tooltipStdAttendanceKeys = [];
    this.tooltimSem = [];
    this.tooltipSemKeys = [];
    this.tooltipPat = [];
    this.tooltipPatKeys = [];
    this.tooltipUDISE = [];
    this.tooltipUDISEKyes = [];
    this.tooltipCrc = [];
    this.tooltipCrcKeys = [];
    this.infraTooltipMetrics = [];
    this.semPerformTooltip = [];
    this.semPerformTooltipKeys = [];
    if (progressCardData['school_infrastructure'] && progressCardData['school_infrastructure'] != null) {
      /* if(progressCardData['school_infrastructure']['school_management_type'])
        progressCardData['school_infrastructure']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['school_infrastructure']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltipInfra = Object.keys(progressCardData['school_infrastructure']);
      this.tooltipInfra = this.tooltipInfra.filter((key) => {
        return !this.schoolInfra.includes(key) && !this.schoolAttendanceCategory.includes(key) && !this.schoolInfraRank.includes(key) && key != 'areas_to_focus' && key !== 'school_management_type';
      });
      this.tooltipInfra.map(key => {
        myKey = this.stringConverter(key);
        this.toolTipInfraKeys.push(myKey);
      });

      this.infraColor = this.service.colorGredient(progressCardData['school_infrastructure']['infra_score']);
      this.toolTipInfraKeys.map(key => {
        this.infraTooltipMetrics.push(key.includes('Percent'));
      });
      let index = this.tooltipInfra.indexOf('school_category');
      if (index !== -1) {
        this.tooltipInfra.splice(index, 1);
      }
      this.infraRankMatrixValue = progressCardData['school_infrastructure']['state_level_score'] * 10;
      this.infraRankMatrixColor = this.service.colorRankMatrics(this.infraRankMatrixValue);
    }
    if (progressCardData['student_attendance'] && progressCardData['student_attendance'] != null) {
      /* if(progressCardData['student_attendance']['school_management_type'])
        progressCardData['student_attendance']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['student_attendance']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltipStdAttendance = Object.keys(progressCardData['student_attendance']);
      this.tooltipStdAttendance = this.tooltipStdAttendance.filter((key) => {
        return !this.schoolAttendance.includes(key) && !this.schoolAttendanceCategory.includes(key) && !this.schoolInfraRank.includes(key) && key !== 'school_management_type';
      });
      this.tooltipStdAttendance.filter(key => {
        myKey = this.stringConverter(key);
        this.tooltipStdAttendanceKeys.push(myKey);
      });
      this.stdAttendanceColor = this.service.colorGredient(progressCardData['student_attendance']['attendance']);
      this.stdAttdRankMatrixValue = progressCardData['student_attendance']['state_level_score'] * 10;
      this.stdAttdRankMatrixColor = this.service.colorRankMatrics(this.stdAttdRankMatrixValue);
    }
    if (progressCardData['student_semester'] && progressCardData['student_semester'] != null) {
      /* if(progressCardData['student_semester']['school_management_type'])
        progressCardData['student_semester']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['student_semester']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltimSem = Object.keys(progressCardData['student_semester']);
      this.tooltimSem = this.tooltimSem.filter((key) => {
        return !this.semPerformance.includes(key) && !this.semPerformancePercent.includes(key) && !this.schoolAttendanceCategory.includes(key) && !this.schoolInfraRank.includes(key) && key !== 'grade_wise_performance' && key !== 'school_management_type';
      });
      this.tooltimSem.filter(key => {
        myKey = this.stringConverter(key);
        this.tooltipSemKeys.push(myKey);
      });
      if (progressCardData['student_semester']['grade_wise_performance']) {
        const ordered = Object.keys(progressCardData['student_semester']['grade_wise_performance']).sort().reduce(
          (obj, key) => {
            obj[key] = progressCardData['student_semester']['grade_wise_performance'][key];
            return obj;
          },
          {}
        );
        progressCardData['student_semester']['grade_wise_performance'] = ordered;
        this.semPerformTooltip = Object.keys(progressCardData['student_semester']['grade_wise_performance']);
        this.semPerformTooltip.filter(key => {
          myKey = this.stringConverter(key);
          this.semPerformTooltipKeys.push(myKey);
        });
      }
      this.semColor = this.service.colorGredient(progressCardData['student_semester']['performance']);
      this.semRankMatrixValue = progressCardData['student_semester']['state_level_score'] * 10;
      this.semRankMatrixColor = this.service.colorRankMatrics(this.semRankMatrixValue);
    }
    if (progressCardData['pat_performance'] && progressCardData['pat_performance'] != null) {
      /* if(progressCardData['pat_performance']['school_management_type'])
        progressCardData['pat_performance']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['pat_performance']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltipPat = Object.keys(progressCardData['pat_performance']);
      if (progressCardData['pat_performance']['grade_wise_performance']) {
        const ordered = Object.keys(progressCardData['pat_performance']['grade_wise_performance']).sort().reduce(
          (obj, key) => {
            obj[key] = progressCardData['pat_performance']['grade_wise_performance'][key];
            return obj;
          },
          {}
        );
        progressCardData['pat_performance']['grade_wise_performance'] = ordered;
        this.patPerformTooltip = Object.keys(progressCardData['pat_performance']['grade_wise_performance']);
        this.patPerformTooltip.filter(key => {
          myKey = this.stringConverter(key);
          this.patPerformTooltipKeys.push(myKey);
        });
      }
      this.tooltipPat = this.tooltipPat.filter((key) => {
        return !this.patPerformance.includes(key) && !this.schoolAttendanceCategory.includes(key) && !this.schoolInfraRank.includes(key) && key !== 'school_management_type';
      });
      this.tooltipPat.filter(key => {
        if (key != 'grade_wise_performance') {
          var myKey = this.stringConverter(key);
          this.tooltipPatKeys.push(myKey);
        }
      });
      let i = this.tooltipPat.indexOf('grade_wise_performance');
      this.tooltipPat.splice(i, 1);
      if (this.level == 'state') {
        this.patColor = this.service.colorGredient(progressCardData['pat_performance'][`school_performance`]);
      } else {
        this.patColor = this.service.colorGredient(progressCardData['pat_performance'][`${this.level}_performance`]);
      }
      this.patRankMatrixValue = progressCardData['pat_performance']['state_level_score'] * 10;
      this.patRankMatrixColor = this.service.colorRankMatrics(this.patRankMatrixValue);
    }
    if (progressCardData['crc_visit'] && progressCardData['crc_visit'] != null) {
      /* if(progressCardData['crc_visit']['school_management_type'])
        progressCardData['crc_visit']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['crc_visit']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltipCrc = Object.keys(progressCardData['crc_visit']);
      this.tooltipCrc = this.tooltipCrc.filter((key) => {
        return !this.crcVisit.includes(key) && key !== 'school_management_type';
      });

      this.tooltipCrc.filter(key => {
        var myKey = this.stringConverter(key);
        this.tooltipCrcKeys.push(myKey);
      });

      this.crcColor = this.service.colorGredient(progressCardData['crc_visit']['visit_score']);
      this.crcRankMatrixValue = progressCardData['crc_visit']['state_level_score'] * 10;
      this.crcRankMatrixColor = this.service.colorRankMatrics(this.crcRankMatrixValue);
    }
    if (progressCardData['udise'] && progressCardData['udise'] != null) {
      /* if(progressCardData['udise']['school_management_type'])
        progressCardData['udise']['school_management_type'] = this.commonService.changeingStringCases(progressCardData['udise']['school_management_type'].replace(/_/g, ' ')) */
      this.tooltipUDISE = Object.keys(progressCardData['udise']);
      this.tooltipUDISE = this.tooltipUDISE.filter((key) => {
        return !this.UDISE.includes(key) && !this.UDISECategory.includes(key) && !this.schoolInfraRank.includes(key) && key != "district_latitude" && key != "block_latitude" && key != "cluster_latitude" && key != "school_latitude" && key != "district_longitude" && key != "block_longitude" && key != "cluster_longitude" && key != "school_longitude" && key !== 'school_management_type';
      });
      this.tooltipUDISE.filter(key => {
        var myKey = this.stringConverter(key);
        this.tooltipUDISEKyes.push(myKey);
      });
      let index = this.tooltipUDISE.indexOf('school_category');
      if (index !== -1) {
        this.tooltipUDISE.splice(index, 1);
      }
      this.udiseColor = this.service.colorGredient(progressCardData['udise']['school_infrastructure']);
      this.udiseRankMatrixValue = progressCardData['udise']['state_level_score'] * 10;
      this.udiseRankMatrixColor = this.service.colorRankMatrics(this.udiseRankMatrixValue);
    }
  }

  stringConverter(key) {
    key = key.replace(
      /\w\S*/g,
      function (txt) {
        txt = txt.replace(/_/g, ' ');
        return txt.replace(/\s(.)/g, function ($1) { return $1.toUpperCase(); })
          .replace(/\s/g, ' ')
          .replace(/^(.)/, function ($1) { return $1.toUpperCase(); });
      });
    key = key.replace("Id", "ID");
    key = key.replace("Nsqf", "NSQF");
    key = key.replace("Ict", "ICT");
    key = key.replace("Crc", "CRC");
    key = key.replace("Cctv", "CCTV");
    key = key.replace("Cwsn", "CWSN");
    return key;
  }

  value: any;
  val;
  len;
  exist = false;
  onChange() {
    document.getElementById('warning').style.lineHeight = "1.7em";

    this.exist = true;
    this.cdr.detectChanges();
    this.val = document.getElementById('myInput')['value'];
    this.len = this.val.length;
    this.showAll = false;
    document.getElementById('warning').style.display = 'block';
    document.getElementById('warning1').style.display = 'none';
    if (this.value.match(/^\d/)) {
      if (this.value.toString().length > 1) {
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      }
      this.autocomplete(document.getElementById("myInput"), this.ids);
    }
    if (!this.value.match(/^\d/)) {
      if (this.value.length > 1) {
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      }
      this.autocomplete(document.getElementById("myInput"), this.names);
    }
  }

  levels = [{ key: 'district', name: 'District' }, { key: 'block', name: 'Block' }, { key: 'cluster', name: 'Cluster' }, { key: 'school', name: 'School' }];
  selectedLevel(callSubmit = false) {
    document.getElementById('warning').style.lineHeight = "1.8em"
    this.exist = true;
    this.cdr.detectChanges();
    document.getElementById('spinner').style.display = 'block';
    sessionStorage.removeItem('progress-card-info');
    this.allData = [];
    this.ids = [];
    this.names = [];
    document.getElementById('warning').style.display = 'block';
    document.getElementById('warning1').style.display = 'none';
    this.showAll = false;
    document.getElementById('myInput')['disabled'] = false;
    if (!callSubmit)
      this.value = '';

    if (this.level == 'district') {
      this.service.metaData(this.level).subscribe(res => {
        this.allData = res;
        this.placeHolder = "Search Districts With Name/ID";
        this.names = this.allData['districtNames'];
        this.ids = this.allData['districtIds'];
        this.districtObjArr = this.allData['districts'];
        document.getElementById('spinner').style.display = 'none';
        if (callSubmit) {
          this.onSubmit();
        }
      }, err => {
        document.getElementById('myInput')['disabled'] = true;
        this.placeHolder = "No districts name/id available";
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      });
    }

    if (this.level == 'block') {
      this.service.metaData(this.level).subscribe(res => {
        this.allData = res;
        this.placeHolder = "Search Blocks With Name/ID";
        this.names = this.allData['blockNames'];
        this.ids = this.allData['blockIds'];
        this.districtObjArr = this.allData['blocks'];
        document.getElementById('spinner').style.display = 'none';
        if (callSubmit) {
          this.onSubmit();
        }
      }, err => {
        document.getElementById('myInput')['disabled'] = true;
        this.placeHolder = "No blocks name/id available";
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      });
    }

    if (this.level == 'cluster') {
      this.service.metaData(this.level).subscribe(res => {
        this.allData = res;
        this.placeHolder = "Search Clusters With Name/ID";
        this.names = this.allData['clusterNames'];
        this.ids = this.allData['clusterIds'];
        this.districtObjArr = this.allData['clusters'];
        document.getElementById('spinner').style.display = 'none';
        if (callSubmit) {
          this.onSubmit();
        }
      }, err => {
        document.getElementById('myInput')['disabled'] = true;
        this.placeHolder = "No clusters name/id available";
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      });
    }

    if (this.level == 'school') {
      this.service.metaData(this.level).subscribe(res => {
        this.allData = res;
        this.placeHolder = "Search Schools With Name/ID";
        this.names = this.allData['schoolNames'];
        this.ids = this.allData['schoolIds'];
        this.districtObjArr = this.allData['schools'];
        document.getElementById('spinner').style.display = 'none';
        if (callSubmit) {
          this.onSubmit();
        }
      }, err => {
        document.getElementById('myInput')['disabled'] = true;
        this.placeHolder = "No schools name/id available";
        document.getElementById('spinner').style.display = 'none';
        document.getElementById('warning').style.display = 'none';
        document.getElementById('warning1').style.display = 'block';
      });
    }
  }

  autocomplete(inp, arr) {
    /*the autocomplete function takes two arguments,
    the text field element and an array of possible autocompleted values:*/
    var currentFocus;
    /*execute a function when someone writes in the text field:*/
    inp.addEventListener("input", function (e) {
      var a, b, i, val = this.value;
      /*close any already open lists of autocompleted values*/
      closeAllLists(e);
      if (!val) { return false; }
      currentFocus = -1;
      /*create a DIV element that will contain the items (values):*/
      a = document.createElement("DIV");
      a.setAttribute("id", this.id + "autocomplete-list");
      a.setAttribute("class", "autocomplete-items");
      /*append the DIV element as a child of the autocomplete container:*/
      this.parentNode.appendChild(a);
      /*for each item in the array...*/
      for (i = 0; i < arr.length; i++) {
        /*check if the item starts with the same letters as the text field value:*/
        if (arr[i].substr(0, val.length).toUpperCase() == val.toUpperCase()) {
          /*create a DIV element for each matching element:*/
          b = document.createElement("DIV");
          /*make the matching letters bold:*/
          b.innerHTML = "<strong>" + arr[i].substr(0, val.length) + "</strong>";
          b.innerHTML += arr[i].substr(val.length);
          /*insert a input field that will hold the current array item's value:*/
          b.innerHTML += "<input id='dist' type='hidden' value='" + arr[i] + "'>";
          /*execute a function when someone clicks on the item value (DIV element):*/
          b.addEventListener("click", function (e) {
            /*insert the value for the autocomplete text field:*/
            inp.value = this.getElementsByTagName("input")[0].value;
            /*close the list of autocompleted values,
            (or any other open lists of autocompleted values:*/
            closeAllLists(e);
          });
          a.appendChild(b);
        }
      }
    });
    /*execute a function presses a key on the keyboard:*/
    inp.addEventListener("keydown", function (e) {
      var x = document.getElementById(this.id + "autocomplete-list");
      // if (x) x = x.getElementsByTagName("div");
      if (e.keyCode == 40) {
        /*If the arrow DOWN key is pressed,
        increase the currentFocus variable:*/
        currentFocus++;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 38) { //up
        /*If the arrow UP key is pressed,
        decrease the currentFocus variable:*/
        currentFocus--;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 13) {
        /*If the ENTER key is pressed, prevent the form from being submitted,*/
        e.preventDefault();
        if (currentFocus > -1) {
          /*and simulate a click on the "active" item:*/
          if (x) x[currentFocus].click();
        }
      }
    });
    function addActive(x) {
      /*a function to classify an item as "active":*/
      if (!x) return false;
      /*start by removing the "active" class on all items:*/
      removeActive(x);
      if (currentFocus >= x.length) currentFocus = 0;
      if (currentFocus < 0) currentFocus = (x.length - 1);
      /*add class "autocomplete-active":*/
      // x[currentFocus].classList.add("autocomplete-active");
    }
    function removeActive(x) {
      /*a function to remove the "active" class from all autocomplete items:*/
      for (var i = 0; i < x.length; i++) {
        x[i].classList.remove("autocomplete-active");
      }
    }
    function closeAllLists(elmnt) {
      /*close all autocomplete lists in the document,
      except the one passed as an argument:*/
      var x = document.getElementsByClassName("autocomplete-items");
      for (var i = 0; i < x.length; i++) {
        if (elmnt != x[i] && elmnt != inp) {
          x[i].parentNode.removeChild(x[i]);
        }
      }
    }
    /*execute a function when someone clicks in the document:*/
    document.addEventListener("click", function (e) {
      closeAllLists(e.target);
    });
  }

  goToReport(route: string): void {
    sessionStorage.setItem('report-level-info', JSON.stringify({ level: this.level == 'state' ? undefined : this.level, data: this.level == 'state' ? null : this.selectedLevelData, timePeriod: this.period }));
    this._router.navigate([route]);
  }

}