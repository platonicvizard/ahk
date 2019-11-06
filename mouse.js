var robot = require("robotjs");  
var exec = require('child_process').execFile;

var startExternalProcess = function(name){

	console.log(`ExternalProcess started => ${name}`);	  
	exec(name, function(err, data) {
		console.log(err);
		console.log(data.toString());
	});  
}


// Speed up the mouse. 
robot.setMouseDelay(2);  
var twoPI = Math.PI * 2.0; 
var screenSize = robot.getScreenSize(); 

var height = (screenSize.height / 2) - 10; 
var width = screenSize.width;  
setInterval(() => {

for (var x = 0; x < width; x++) { 	
	y = height * Math.sin((twoPI * x) / width) + height; 	robot.moveMouse(x, y); 
}
}, 5000);


process.stdin.setRawMode(true);
process.stdin.resume();


var exitProcess = process.exit.bind(process, 0);
process.stdin.on('data', () => {
	startExternalProcess('key.exe');
	exitProcess(); 
});

