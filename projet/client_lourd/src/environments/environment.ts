// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
    production: false,
    serverUrl: 'http://localhost:3000/api',
    firebase : {
        apiKey: "AIzaSyDyZJZmbrP_Phc8C9SNoqZWrioatX89Pzk",
        authDomain: "polyquiz-103.firebaseapp.com",
        projectId: "polyquiz-103",
        storageBucket: "polyquiz-103.firebasestorage.app",
        messagingSenderId: "278944080772",
        appId: "1:278944080772:web:3b2c748ffd601ee94a73d1"
    }
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
