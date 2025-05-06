import log4js from 'log4js';

const layout = {
    type: 'pattern',
    pattern: '%p [%f{1}:%l:%M] %m%'
}

log4js.configure({
    appenders: {
        stdout: {
            type: 'stdout',
            enableCallStack: true,
            layout
        }
    },
    categories: {
        default: {
            appenders: ['stdout'],
            level: 'debug',
            enableCallStack: true
        }
    }
});
