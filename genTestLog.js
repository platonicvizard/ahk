var fs = require('fs');
var yargs = require('yargs');
var INTERVAL = (Number(yargs.argv.i || yargs.argv.interval || process.argv[2]) || 1) * 1000 || 1000;
var TIMER_DELAY = Number(yargs.argv.t || yargs.argv.timerDelay ||process.argv[3]) || 0;
var i = 0;

var newLine = false;
//console.log('INTERVAL',INTERVAL,'TIMER_DELAY',TIMER_DELAY)
setInterval(() => {
  newLine = true;
  i++;
  fs.appendFile('log.txt', `${i} content\n`, function(err) {
    if (err) throw err;
    //console.log(`${i} -- Saved!`);
  });
}, INTERVAL);

var cur_interval = 0;

setInterval(() => {
  cur_interval++;
  process.stdout.write(`-${cur_interval}-`);
  if (newLine) {
    console.log(i);
    cur_interval = 0;
  }
  newLine = false;
}, TIMER_DELAY);





//generates a test log file
yargs.command(['[interval]', '[i]'], 'Integer describing how often to run the update in seconds.', (yargs) => {
    yargs
      .positional('interval', {
        describe: 'Integer describing how often to run the update',
        default: 1
      });

  }, (argv) => {
    if (argv.verbose) console.info(`start server on :${argv.port}`)
    serve(argv.port)
  })
  .command(['[timerDelay]', '[t]'], 'Integer describing how often show the progress in seconds', (yargs) => {
    yargs
    .positional('timerDelay', {
      describe: 'Integer describing how often show the progress in seconds',
      default: 1
    })

  }, (argv) => {
    if (argv.verbose) console.info(`start server on :${argv.port}`)
    serve(argv.port)
  })
  .option('timerDelay', {
    alias: 't',
    type: 'number',
    description: 'Integer describing how often show the progress in seconds'
  })
  .option('interval', {
    alias: 'i',
    type: 'number',
    description: 'Integer describing how often to run the update in seconds'
  })
  .argv
