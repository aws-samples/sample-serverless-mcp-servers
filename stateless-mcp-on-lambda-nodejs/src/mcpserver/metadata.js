import packageInfo from './package.json' with { type: 'json'};

const metadata = {
}

async function init() {
    metadata.version = packageInfo.version;
    metadata.logStreamName = process.env.AWS_LAMBDA_LOG_STREAM_NAME || 'unknown';
}

export default {
    init,

    get all() {
        return metadata;
    },

    get version() {
        return metadata.version;
    },
    
    get logStreamName() {
        return metadata.logStreamName;
    }
};
