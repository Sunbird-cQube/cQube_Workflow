import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../src/environments/environment';
import { KeycloakSecurityService } from './keycloak-security.service';
import * as config from '../assets/config.json';
import { ExportToCsv } from 'export-to-csv';
import { BehaviorSubject } from 'rxjs';

export var globalMap;
declare const $;

@Injectable({
    providedIn: 'root'
})
export class AppServiceComponent {
    toggleMenu = new BehaviorSubject<any>(false);
    callProgressCard = new BehaviorSubject<any>(false);
    public baseUrl = environment.apiEndpoint;
    public token;
    telemetryData: any;
    showBack = true;
    showHome = true;
    mapCenterLatlng = config.default[`${environment.stateName}`];

    public state = this.mapCenterLatlng.name;
    public mapName = environment.mapName;
    date = new Date();
    dateAndTime: string;
    static state: any;

    constructor(public http: HttpClient, public keyCloakService: KeycloakSecurityService) {
        this.token = keyCloakService.kc.token;
        localStorage.setItem('token', this.token);
        this.dateAndTime = `${("0" + (this.date.getDate())).slice(-2)}-${("0" + (this.date.getMonth() + 1)).slice(-2)}-${this.date.getFullYear()}`;

    }

    homeControl() {
        if (window.location.hash == '#/dashboard') {
            this.showBack = true;
            this.showHome = false;
        } else {
            this.showBack = false;
            this.showHome = true;
        }
    }

    changeingStringCases(str) {
        return str.replace(
            /\w\S*/g,
            function (txt) {
                return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
            }
        );
    }

    logoutOnTokenExpire() {
        if (this.keyCloakService.kc.isTokenExpired()) {
            localStorage.removeItem('management');
            localStorage.removeItem('category');
            let options = {
                redirectUri: environment.appUrl,
            }
            sessionStorage.clear();
            this.keyCloakService.kc.clearToken();
            this.keyCloakService.kc.logout(options);
        }
    }

    changePassword(data, id) {
        this.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/changePassword/${id}`, data);
    }

    getRoles() {
        this.logoutOnTokenExpire();
        return this.http.get(`${this.baseUrl}/changePassword/roles`);
    }

    addRole(id, role, otpConfig) {
        this.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/changePassword/setRoles`, { userId: id, role: role, otpConfig: otpConfig });
    }
    //localStorage.getItem('user_id'), this.roleIds.find(o => o.name == 'report_viewer'), this.otpConfig
    // to load and hide the spinner 
    loaderAndErr(data) {
        if (data.length !== 0) {
            document.getElementById('spinner').style.display = 'none';
        } else {
            document.getElementById('spinner').style.display = 'none';
            document.getElementById('errMsg') ? document.getElementById('errMsg').style.color = 'red' : "";
            document.getElementById('errMsg') ? document.getElementById('errMsg').style.display = 'block' : "";
            document.getElementById('errMsg') ? document.getElementById('errMsg').innerHTML = 'No data found' : "";
        }
    }
    errMsg() {
        document.getElementById('errMsg') ? document.getElementById('errMsg').style.display = 'none' : "";
        document.getElementById('spinner').style.display = 'block';
        document.getElementById('spinner').style.marginTop = '3%';
    }

    capitalize(key) {
        key = key.replace("Id", "ID");
        key = key.replace("Nsqf", "NSQF");
        key = key.replace("Ict", "ICT");
        key = key.replace("Crc", "CRC");
        key = key.replace("Cctv", "CCTV");
        key = key.replace("Cwsn", "CWSN");
        key = key.replace("Ff Uuid", "UUID");
        return key;
    }


    //Download reports....
    download(fileName, reportData) {
        if (reportData.length <= 0) {
            alert("No data found to download");
        } else {
            var keys = Object.keys(reportData[0]);
            var updatedKeys = [];
            keys.map(key => {
                key = key.replace(/_/g, ' ').toLowerCase()
                    .split(' ')
                    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                    .join(' ');
                key = this.capitalize(key);
                updatedKeys.push(key);
            });
            const options = {
                fieldSeparator: ',',
                quoteStrings: '"',
                decimalSeparator: '.',
                showLabels: true,
                showTitle: false,
                title: 'My Awesome CSV',
                useTextFile: false,
                useBom: true,
                // useKeysAsHeaders: true,
                headers: updatedKeys,
                filename: fileName
            };
            const csvExporter = new ExportToCsv(options);
            csvExporter.generateCsv(reportData);
        }
    }

    //color gredient generation....
    public color(data, filter) {
        var keys = Object.keys(this.colors);
        var dataSet = {};
        var setColor = '';
        dataSet = data;
        for (let i = 0; i < keys.length; i++) {
            if (dataSet[filter] <= parseInt(keys[i])) {
                setColor = this.colors[keys[i]];
                break;
            } else if (dataSet[filter] > parseInt(keys[i]) && dataSet[filter] <= parseInt(keys[i + 1])) {
                setColor = this.colors[keys[i + 1]];
                break;
            }
        }
        return setColor;
    }

    //generate table colors
    public tableCellColor(data) {
        var keys = Object.keys(this.colors);
        var setColor = '';
        for (let i = 0; i < keys.length; i++) {
            if (data <= parseInt(keys[i])) {
                setColor = this.colors[keys[i]];
                break;
            } else if (data > parseInt(keys[i]) && data <= parseInt(keys[i + 1])) {
                setColor = this.colors[keys[i + 1]];
                break;
            }
        }
        return setColor;
    }

    // color gredient based on intervals
    colorGredient(data, filter) {
        var keys = Object.keys(this.colors);
        var dataSet = {};
        var setColor = '';
        if (filter == 'Infrastructure_Score' || filter == 'infrastructure_score') {
            dataSet = data.details;
        } else {
            if (data.indices) {
                dataSet = data.indices;
            } else {
                dataSet = data.metrics;
            }
        }
        for (let i = 0; i < keys.length; i++) {
            if (dataSet[filter] <= parseInt(keys[i])) {
                setColor = this.colors[keys[i]];
                break;
            } else if (dataSet[filter] >= parseInt(keys[i]) && dataSet[filter] <= parseInt(keys[i + 1])) {
                setColor = this.colors[keys[i + 1]];
                break;
            }
        }
        return setColor;
    }

    //generating relative colors
    // color gredient based on intervals
    relativeColorGredient(data, filter, colors) {
        var keys = Object.keys(colors);
        var dataSet = {};
        var setColor = '';
        if (!filter.report) {
            if (filter == 'Infrastructure_Score' || filter == 'infrastructure_score') {
                dataSet = data.details;
            } else {
                if (data.indices) {
                    dataSet = data.indices;
                } else {
                    dataSet = data.metrics;
                }
            }
        } else {
            if (!filter.selected) {
                var objkeys = Object.keys(data);
                if (!objkeys.includes(filter.value)) {
                    filter.value = `total_schools_with_missing_data`;
                }
                dataSet = data;
            } else {
                if (filter.selected == 'G' || filter.selected == 'GS') {
                    if (data.Subjects) {
                        dataSet = data.Subjects;
                    } else {
                        dataSet = data['Grade Wise Performance'];
                    }
                } else {
                    dataSet = data.Details;
                }
            }
        }
        if (filter.report == 'exception') {
            keys = keys.sort(function (a: any, b: any) { return (a - b) });
        }
        for (let i = 0; i < keys.length; i++) {
            let val = filter.value ? filter.value : filter;
            if (dataSet[val] == null) setColor = "red";
            if (parseFloat(dataSet[val]) == parseFloat(keys[i])) {
                setColor = colors[keys[i]];
                break;
            }
        }
        return setColor;
    }

    getRelativeColors(markers, filter) {
        var values = [];
        markers.map(item => {
            if (!filter.report) {
                if (filter == 'infrastructure_score' || filter == 'Infrastructure_Score') {
                    values.push(item.details[`${filter}`]);
                } else {
                    if (item.metrics) {
                        values.push(item.metrics[`${filter}`]);
                    } else {
                        values.push(item.indices[`${filter}`]);
                    }
                }
            } else {
                if (!filter.selected) {
                    var keys = Object.keys(item);
                    if (keys.includes(filter.value)) {
                        values.push(item[`${filter.value}`]);
                    } else {
                        values.push(item[`total_schools_with_missing_data`]);
                    }
                } else {
                    if (filter.selected == 'G' || filter.selected == 'GS') {
                        if (item.Subjects) {
                            values.push(item.Subjects[`${filter.value}`]);
                        } else {
                            values.push(item['Grade Wise Performance'][`${filter.value}`]);
                        }
                    } else {
                        values.push(item.Details[`${filter.value}`]);
                    }
                }

            }
        });
        let uniqueItems = [...new Set(values)];
        uniqueItems = uniqueItems.map(a => {
            if (typeof (a) == 'object') {
                return a['percentage']
            } else {
                return a;
            }
        })
        uniqueItems = uniqueItems.sort(function (a, b) { return filter.report != 'exception' ? parseFloat(a) - parseFloat(b) : parseFloat(b) - parseFloat(a) });
        var colorsArr = uniqueItems.length == 1 ? (filter.report != 'exception' ? ['#00FF00'] : ['red']) : this.exceptionColor().generateGradient('#FF0000', '#00FF00', uniqueItems.length, 'rgb');
        var colors = {};
        uniqueItems.map((a, i) => {
            colors[`${a}`] = colorsArr[i]
        });
        return colors;
    }


    //capturing telemetry.....
    telemetry(date) {
        this.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/telemetry`, { telemetryData: this.telemetryData, date: date });
    }

    getTelemetry(data) {
        this.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/telemetry/data`, { period: data });
    }

    //data-source::::::::::::
    getDataSource() {
        this.logoutOnTokenExpire();
        return this.http.get(`${this.baseUrl}/dataSource`, {});
    }


    edate;
    getTelemetryData(reportId, event) {
        this.telemetryData = [];
        var obj = {};
        this.edate = new Date();
        var dateObj = {
            year: this.edate.getFullYear(),
            month: ("0" + (this.edate.getMonth() + 1)).slice(-2),
            date: ("0" + (this.edate.getDate())).slice(-2),
            hour: ("0" + (this.edate.getHours())).slice(-2),
            minut: ("0" + (this.edate.getMinutes())).slice(-2),
            seconds: ("0" + (this.edate.getSeconds())).slice(-2),
        }
        obj = {
            uid: this.keyCloakService.kc.tokenParsed.sub,
            eventType: event,
            reportId: reportId,
            time: dateObj.year + '-' + dateObj.month + '-' + dateObj.date + ' ' + dateObj.hour + ':' + dateObj.minut + ':' + dateObj.seconds
        }

        this.telemetryData.push(obj);

        this.telemetry(dateObj).subscribe(res => { }, err => { console.log(err) });
    }

    public colors = {
        10: '#a50026',
        20: '#d73027',
        30: '#f46d43',
        40: '#fdae61',
        50: '#fee08b',
        60: '#d9ef8b',
        70: '#a6d96a',
        80: '#66bd63',
        90: '#1a9850',
        100: '#006837'
    }
    //color gredient generation....
    public exceptionColor() {
        // Converts a #ffffff hex string into an [r,g,b] array
        function hex2rgb(hex) {
            const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
            return result ? [
                parseInt(result[1], 16),
                parseInt(result[2], 16),
                parseInt(result[3], 16)
            ] : null;
        }

        // Inverse of the above
        function rgb2hex(rgb) {
            return '#' + ((1 << 24) + (rgb[0] << 16) + (rgb[1] << 8) + rgb[2]).toString(16).slice(1);
        }

        // Interpolates two [r,g,b] colors and returns an [r,g,b] of the result

        function _interpolateRgb(color1, color2, factor) {
            if (arguments.length < 3) { factor = 0.5; }

            let result = color1.slice();

            for (let i = 0; i < 3; i++) {
                result[i] = Math.round(result[i] + factor * (color2[i] - color1[i]));
            }
            return result;
        }

        function generateGradient(color1, color2, total, interpolation) {
            const colorStart = typeof color1 === 'string' ? hex2rgb(color1) : color1;
            const colorEnd = typeof color2 === 'string' ? hex2rgb(color2) : color2;

            // will the gradient be via RGB or HSL
            switch (interpolation) {
                case 'rgb':
                    return colorsToGradientRgb(colorStart, colorEnd, total);
                case 'hsl':
                //   return colorsToGradientHsl(colorStart, colorEnd, total);
                default:
                    return false;
            }
        }

        function colorsToGradientRgb(startColor, endColor, steps) {
            // returns array of hex values for color, since rgb would be an array of arrays and not strings, easier to handle hex strings
            let arrReturnColors = [];
            let interimColorRGB;
            let interimColorHex;
            const totalColors = steps;
            const factorStep = 1 / (totalColors - 1);

            for (let idx = 0; idx < totalColors; idx++) {
                interimColorRGB = _interpolateRgb(startColor, endColor, factorStep * idx);
                interimColorHex = rgb2hex(interimColorRGB);
                arrReturnColors.push(interimColorHex);
            }
            return arrReturnColors;
        }
        return {
            generateGradient
        };
    }

    //Get table columns
    getColumns(dataSet) {
        var my_columns = [];
        $.each(dataSet[0], function (key, value) {
            var my_item = {};
            my_item['data'] = key;
            my_item['value'] = value;
            my_columns.push(my_item);
        });
        return my_columns;
    }

    //management category metadata
    management_category_metaData() {
        this.logoutOnTokenExpire();
        return this.http.post(`${this.baseUrl}/management-category-meta`, {});
    }

    //getDefaultOptions
    getDefault() {
        this.logoutOnTokenExpire();
        return this.http.get(`${this.baseUrl}/getDefault`);
    }


    //
    setProgressCardValue(status) {
        this.callProgressCard.next(status);
    }

    setToggleMenuValue(status) {
        this.toggleMenu.next(status);
    }
}