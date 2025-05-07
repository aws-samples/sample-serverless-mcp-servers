import log4js from 'log4js';
const l = log4js.getLogger();

const LOG_FILE = `${import.meta.dirname}/../server.log`;

const layout = {
    type: 'pattern',
    pattern: '%[%p [%f{1}:%l:%M] %m%]'
}

log4js.configure({
    appenders: {
        stdout: {
            type: 'stdout',
            enableCallStack: true,
            layout
        },
        file: {
            type: 'file',
            filename: LOG_FILE,
            enableCallStack: true,
            layout
        }
    },
    categories: {
        default: {
            // appenders: ['stdout'],
            appenders: ['file'],
            level: 'debug',
            enableCallStack: true
        }
    }
});

