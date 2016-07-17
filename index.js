const electron = require('electron')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const ipc = electron.ipcMain
const path = require('path')
var mainWindow = null
const argv = process.argv;
const startupLocation = argv[argv.length -1]
const browserPath = path.join( __dirname, 'browser.html')
console.log(browserPath)

ipc.on('get-startup-location', function(ev){
  ev.sender.send('startup-location',startupLocation)
});
app.on('window-all-closed', function() {
  if (process.platform != 'darwin') {
    app.quit()
  }
})

app.on('ready', function () {
  mainWindow = new BrowserWindow({ width: 1030, height: 720, frame: false })
  mainWindow.loadURL(path.join('file://', __dirname, 'browser.html'))
  mainWindow.show()
  mainWindow.on('closed', function() {
    mainWindow = null
  })
})
