// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
    production: false,
    serverUrl: 'http://localhost:3000/api',
    firebase : {
        apiKey: "AIzaSyAurHesdch5GUNG0at-Ek2PeTrSQCv1xmg",
        authDomain: "polyquiz-app.firebaseapp.com",
        projectId: "polyquiz-app",
        storageBucket: "polyquiz-app.appspot.com",
        messagingSenderId: "98437822234",
        appId: "1:98437822234:web:eb97250f2dd5957eaa5ea3",
        measurementId: "G-LYRYDVNRLW"
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
