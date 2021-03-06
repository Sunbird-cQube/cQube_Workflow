// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: false,
  apiEndpoint: "http://localhost:3000/api",
  adminUrl: "http://localhost:4201",
  appUrl: "http://localhost:4200",
  keycloakUrl: "http://localhost:8080/auth",
  realm: "cQube",
  clientId: "cQube_Application",
  stateName: "GJ",
  useCase: "education_usecase",
  diksha_columns: false,
  theme: "theme2",
  mapName: "mapmyindia",
  progressCardConfig: ['33', '33-60', '60-75', '75'],
  report_viewer_config_otp: false
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.