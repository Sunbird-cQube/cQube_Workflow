import { Component, OnInit } from '@angular/core';
import { NifiShedularService } from '../../services/nifi-shedular.service';
declare const $;

@Component({
  selector: 'app-nifi-shedular',
  templateUrl: './nifi-shedular.component.html',
  styleUrls: ['./nifi-shedular.component.css']
})
export class NifiShedularComponent implements OnInit {
  //Bootstrap Date picker
  myDateValue = [];
  myDateValue1 = [];
  placeHolder;
  model = '';

  result: any = [];
  data: any = [];
  user_status = 1;
  err;
  msg;
  showMsg;
  timeArr = [];
  selectedTime = [];
  selectedTime1 = [];
  selectedShedule = '';
  selectMin = '';
  hoursArr = [];
  minsArr = [];
  selectedHour = [];
  selectedHour1 = [];
  selectedMinuts = [];
  selectedMinuts1 = [];
  selectedDuration = '';
  processorId;
  commonProcessor

  timeRange = [{ key: "daily", value: "Daily" }, { key: "weekly", value: "Weekly" }, { key: "monthly", value: "Monthly" }, { key: "yearly", value: "Yearly" }];
  selectedTimeRange = [];
  selectedTimeRange1 = [];
  oneTimeRange = '';

  allDays = [{ key: 1, name: "Monday" }, { key: 2, name: "Tuesday" }, { key: 3, name: "Wednesday" }, { key: 4, name: "Thursday" }, { key: 5, name: "Friday" }, { key: 6, name: "Saturday" }, { key: 7, name: "Sunday" }];
  selectedDay = [];
  selectedDay1 = [];
  day;

  allMonths = [];
  selectedMonth = [];
  month;

  allDates = [];
  selectedDate = [];
  date;

  showDay = [];
  showMonth = [];
  showDate = [];

  showDay1 = [];
  showMonth1 = [];
  showDate1 = [];

  today = new Date();
  minDate = `${this.today.getFullYear()}-${("0" + (this.today.getMonth() + 1)).slice(-2)}-${("0" + (this.today.getDate())).slice(-2)}`;

  constructor(private service: NifiShedularService) {
    this.service.commonScheduleProcessor().subscribe(res => {
      this.commonProcessor = res["data"]


    })

    for (let i = 1; i <= 10; i++) {
      this.hoursArr.push({ hours: i });
    }
    for (let i = 0; i < 60; i++) {
      this.minsArr.push({ mins: `${("0" + (i)).slice(-2)}` });
    }
    for (let i = 1; i < 13; i++) {
      this.allMonths.push({ key: i });

    }
    for (let i = 1; i < 29; i++) {
      this.allDates.push({ key: i });
    }
  }

  ngOnInit(): void {
    document.getElementById('backBtn').style.display = "none";
    this.showTable();
    document.getElementById('homeBtn').style.display = "Block";
    //get 24 hours time
    var date, array = [];
    date = new Date();

    while (date.getMinutes() % 60 !== 0) {
      date.setMinutes(date.getMinutes() + 1);
    }
    for (var i = 0; i < 24; i++) {
      array.push({ time: ("0" + (date.getHours())).slice(-2) });
      date.setMinutes(date.getMinutes() + 60);
    }
    array.sort((a, b) => (a.time > b.time) ? 1 : ((b.time > a.time) ? -1 : 0));

    this.timeArr = array;
  }

  onSelectTimeRange(i) {
    this.oneTimeRange = this.selectedTimeRange[i];
    if (this.selectedTimeRange[i] == 'daily') {
      this.showDay[i] = true;
      this.showMonth[i] = true;
      this.showDate[i] = true;
    }
    if (this.selectedTimeRange[i] == 'weekly') {
      this.showDay[i] = false;
      this.showMonth[i] = true;
      this.showDate[i] = true;
    }
    if (this.selectedTimeRange[i] == 'monthly') {
      this.showDay[i] = true;
      this.showMonth[i] = false;
      this.showDate[i] = true;
      this.placeHolder = "Select Date"
    }
    if (this.selectedTimeRange[i] == 'yearly') {
      this.showDay[i] = true;
      this.showMonth[i] = false;
      this.showDate[i] = false;
      this.placeHolder = "Select Date"
    }
  }

  onSelectDay(i) {
    this.myDateValue = [];
    this.day = this.selectedDay[i];
    this.month = undefined;
    this.date = undefined;
    this.myDateValue = [];
  }

  onSelectMonth(event) {
    if (event) {
      this.month = undefined;
      this.date = undefined;
      this.day = undefined;
      this.date = event.getDate();
    }
  }

  onSelectDate(event) {
    if (event) {
      this.month = undefined;
      this.day = undefined;
      this.date = event.getDate();
      this.month = event.getMonth() + 1;
    }
  }

  onSelectTime(i) {
    this.selectedShedule = this.selectedTime[i];
  }

  onSelectMinutes(i) {
    this.selectMin = this.selectedMinuts[i];
  }

  onSelectHour(i) {
    this.selectedDuration = this.selectedHour[i];
  }

  showTable() {
    document.getElementById('spinner').style.display = 'block';
    if (this.result.length! > 0) {
      $('#table').DataTable().destroy();
    }
    this.service.nifiGetProcessorId().subscribe(res => {
      this.processorId = res['processorId'];

      this.service.nifiGetProcessorDetails(this.processorId).subscribe(details => {
        this.result = details;

        let processors = this.result.filter(a => {
          return a.name != "cQube_data_storage";
        })
        processors = processors.filter(a => {
          return a.name != 'diksha_transformer_custom'
        })
        processors = processors.filter(a => {
          return a.name != "transaction_and_aggregation"
        })
        processors = processors.filter(a => {
          return a.name != "validate_datasource"
        })

        this.data = processors;

        for (let i = 0; i < this.result.length; i++) {
          this.showDay.push(true);
          this.showDate.push(true);
          this.showMonth.push(true);
          this.showDay1.push(true);
          this.showDate1.push(true);
          this.showMonth1.push(true);
        }

        $(document).ready(function () {
          $('#table').DataTable({
            destroy: true, bLengthChange: false, bInfo: false,
            bPaginate: false, scrollY: 380, scrollX: true,
            scrollCollapse: true, paging: false, searching: true,
            fixedColumns: {
              leftColumns: 1
            }
          });
        });
        document.getElementById('spinner').style.display = 'none';
      });
    })
  }

  onClickSchedule(data, i) {
    if (this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange == 'daily' || this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.day ||
      this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.date || this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.date && this.month) {
      this.service.nifiScheduleProcessor(data.id, data.name, { state: "STOPPED", time: { day: this.day, date: this.date, month: this.month, hours: this.selectedShedule, minutes: this.selectMin }, stopTime: this.selectedDuration }).subscribe(res => {
        if (res['msg']) {
          this.msg = res['msg'];
          this.err = '';
          document.getElementById('success').style.display = "block";
          this.selectedTime = [];
          this.selectedHour = [];
          this.selectedMinuts = [];
          this.selectedShedule = '';
          this.selectMin = '';
          this.selectedDuration = '';
          this.day = undefined;
          this.date = undefined;
          this.month = undefined;
          this.selectedTimeRange = [];
          this.selectedDay = [];
          this.myDateValue = [];
          this.showDay[i] = true;
          this.showMonth[i] = true;
          this.showDate[i] = true;

          setTimeout(() => {
            document.getElementById('success').style.display = "none";
          }, 2000);
        }
      }, err => {
        this.err = err.error['errMsg'];
      })

    } else if (this.selectedDuration == '' && this.selectedShedule == '' && this.oneTimeRange == '') {
      this.err = "please select timeRange, schedule time and stopping hours";
    } else if (this.selectedDuration == '' && this.selectedShedule == '') {
      this.err = "please select schedule time and stopping hours";
    } else if (this.selectedShedule == '') {
      this.err = "please select schedule time";
    } else if (this.selectedDuration == '') {
      this.err = "please select stopping hours";
    } else if (this.day == undefined && this.oneTimeRange == 'weekly') {
      this.err = "please select day";
    } else if (this.date == undefined && this.oneTimeRange == 'monthly') {
      this.err = "please select date";
    } else if (this.month == undefined && this.oneTimeRange == 'yearly') {
      this.err = "please select month";
    }


  }




  onSelectTimeRange1(i) {
    this.oneTimeRange = this.selectedTimeRange1[i];
    if (this.selectedTimeRange1[i] == 'daily') {
      this.showDay1[i] = true;
      this.showMonth1[i] = true;
      this.showDate1[i] = true;
    }
    if (this.selectedTimeRange1[i] == 'weekly') {
      this.showDay1[i] = false;
      this.showMonth1[i] = true;
      this.showDate1[i] = true;
    }
    if (this.selectedTimeRange1[i] == 'monthly') {
      this.showDay1[i] = true;
      this.showMonth1[i] = false;
      this.showDate1[i] = true;
      this.placeHolder = "Select Date"
    }
    if (this.selectedTimeRange1[i] == 'yearly') {
      this.showDay1[i] = true;
      this.showMonth1[i] = false;
      this.showDate1[i] = false;
      this.placeHolder = "Select Date"
    }
  }

  onSelectDay1(i) {
    this.myDateValue1 = [];
    this.day = this.selectedDay1[i];
    this.month = undefined;
    this.date = undefined;
    this.myDateValue1 = [];
  }

  onSelectMonth1(event) {
    if (event) {
      this.month = undefined;
      this.date = undefined;
      this.day = undefined;
      this.date = event.getDate();
    }
  }

  onSelectDate1(event) {
    if (event) {
      this.month = undefined;
      this.day = undefined;
      this.date = event.getDate();
      this.month = event.getMonth() + 1;
    }
  }

  onSelectTime1(i) {
    this.selectedShedule = this.selectedTime1[i];
  }

  onSelectMinutes1(i) {
    this.selectMin = this.selectedMinuts1[i];
  }

  onSelectHour1(i) {
    this.selectedDuration = this.selectedHour1[i];
  }

  onClickSchedule1(data, i) {
    if (this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange == 'daily' || this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.day ||
      this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.date || this.selectedDuration != '' && this.selectedShedule != '' && this.oneTimeRange != '' && this.date && this.month) {

      this.service.ScheduleProcessor(data.name,{ reportName: { data }, time: { day: this.day, date: this.date, month: this.month, hours: this.selectedShedule, minutes: this.selectMin }, stopTime: this.selectedDuration }
      ).subscribe(res => {
        if (res['msg']) {
          this.msg = res['msg'];
          this.err = '';
          document.getElementById('success').style.display = "block";
          this.selectedTime1 = [];
          this.selectedHour1 = [];
          this.selectedMinuts1 = [];
          this.selectedShedule = '';
          this.selectMin = '';
          this.selectedDuration = '';
          this.day = undefined;
          this.date = undefined;
          this.month = undefined;
          this.selectedTimeRange1 = [];
          this.selectedDay1 = [];
          this.myDateValue1 = [];
          this.showDay1[i] = true;
          this.showMonth1[i] = true;
          this.showDate1[i] = true;

          setTimeout(() => {
            document.getElementById('success').style.display = "none";
          }, 2000);
        }
      }, err => {
        this.err = err.error['errMsg'];
      })

    } else if (this.selectedDuration == '' && this.selectedShedule == '' && this.oneTimeRange == '') {
      this.err = "please select timeRange, schedule time and stopping hours";
    } else if (this.selectedDuration == '' && this.selectedShedule == '') {
      this.err = "please select schedule time and stopping hours";
    } else if (this.selectedShedule == '') {
      this.err = "please select schedule time";
    } else if (this.selectedDuration == '') {
      this.err = "please select stopping hours";
    } else if (this.day == undefined && this.oneTimeRange == 'weekly') {
      this.err = "please select day";
    } else if (this.date == undefined && this.oneTimeRange == 'monthly') {
      this.err = "please select date";
    } else if (this.month == undefined && this.oneTimeRange == 'yearly') {
      this.err = "please select month";
    }


  }
}
