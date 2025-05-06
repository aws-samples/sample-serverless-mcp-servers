const TEMPLATE = {
    jsonrpc: '2.0',
    error: {
        code: 0,
        message: 'n/a',
    },
    id: null,
};

function build(code, message){
    const result = {...TEMPLATE};
    result.error.code = code;
    result.error.message = message;
    return result;
}


export default {
    get internalServerError(){
        return build(-32603, 'Internal Server Error');
    },

    get noValidSessionId(){
        return build(-32000, 'No valid session ID');
    },

    get invalidOrMissingSessionId(){
        return build(-32000, 'Invalid or missing session ID');
    },

    get methodNotAllowed(){
        return build(-32000, 'Method not allowed');
    }

}