const { app, BrowserWindow, screen } = require('electron');
const url = require('url');
const path = require('path');

let mainWindow;

function createWindow() {
    const { width, height } = screen.getPrimaryDisplay().workAreaSize; // Get screen dimensions

    mainWindow = new BrowserWindow({
        width: width, // Set to full screen width
        height: height, // Set to full screen height
        webPreferences: {
            nodeIntegration: true,
        },
    });

    mainWindow.loadURL(
        url.format({
            pathname: path.join(__dirname, "dist/client/index.html"),
            protocol: 'file:',
            slashes: true,
        }),
    );

    mainWindow.once('ready-to-show', () => {
        mainWindow.webContents.setZoomFactor(0.8);
    });

    mainWindow.on('closed', function () {
        mainWindow = null;
    });
}

// Wait for the app to be ready before creating the window
app.whenReady().then(createWindow);

app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
    if (mainWindow === null) createWindow();
});
