const ECS_METADATA_URI = process.env.ECS_CONTAINER_METADATA_URI_V4;
import packageInfo from './package.json' with { type: 'json'};

const metadata = {
}

async function init() {
    metadata.version = packageInfo.version;

    if (!ECS_METADATA_URI) return;

    const resp = await fetch(`${ECS_METADATA_URI}/task`);
    const respJson = await resp.json();
    metadata.taskId = respJson.TaskARN.split(':')[5];
}

export default {
    init,

    get all() {
        return metadata;
    },

    get version() {
        return metadata.version;
    },
    
    get taskId() {
        return metadata.taskId;
    }
};
