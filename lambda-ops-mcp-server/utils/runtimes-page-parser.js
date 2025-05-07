import log4js from 'log4js';
const l = log4js.getLogger();

import {JSDOM} from 'jsdom';
import $ from 'jquery';

const deprecatedRuntimes = [];

const LAMBDA_RUNTIMES_DOC_URL = 'https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html';

const bootstrap = async ()=>{
    l.debug('>');
    const html = await getLambdaRuntimesHtml();
    await parseLambdaRuntimesHtml(html);
    return;
}

const get = async()=>{
    l.debug('>');
    if (!deprecatedRuntimes || deprecatedRuntimes.length===0) {
        await bootstrap();
    }
    return deprecatedRuntimes;
}

const getLambdaRuntimesHtml = async () => {
    l.debug(`retrieving from ${LAMBDA_RUNTIMES_DOC_URL}`);
    
    const resp = await fetch(LAMBDA_RUNTIMES_DOC_URL);
    if (resp.status !== 200) {
        l.error(`unable to retrieve data from ${LAMBDA_RUNTIMES_DOC_URL}`);
        l.error(`resp.status=${resp.status} resp.statusText=${resp.statusText}`);
        return '<html/>';
    }
    const html = await resp.text();
    l.debug(`retrieved successfully html.length=${html.length}`);
    return html;
}

const parseLambdaRuntimesHtml = async (html)=> {
    l.debug(`parsing html.length=${html.length}]`);
    const dom = new JSDOM(html);
    const $window = $(dom.window);

    const $tableContainers = $window('.table-container');
    const $supportedRuntimesTable = $tableContainers.eq(0);
    const $deprecatedRuntimesTable = $tableContainers.eq(2);
    l.debug(`parsed successfully`);

    l.debug(`processing tables`);
    processTable($supportedRuntimesTable);
    processTable($deprecatedRuntimesTable);
    l.debug(`success, found ${deprecatedRuntimes.length} runtimes with deprecation dates`);
}

const processTable = ($sourceTable) => {
    const $tableRows = $sourceTable.find('table').find('tbody').find('tr');
    for (let i = 0; i < $tableRows.length; i++) {
        const $tableRow = $tableRows.eq(i);
        const $tableCells = $tableRow.find('td');
        const name = $tableCells.eq(0).text().trim();
        const id = $tableCells.eq(1).text().trim();
        const os = $tableCells.eq(2).text().trim();
        const deprecationDate = $tableCells.eq(3).text().trim();
        const blockFunctionCreateDate = $tableCells.eq(4).text().trim();
        const blockFunctionUpdateDate = $tableCells.eq(5).text().trim();

        if (deprecationDate || blockFunctionUpdateDate || blockFunctionCreateDate) {
            deprecatedRuntimes.push({
                name,
                id,
                os,
                deprecationDate,
                blockFunctionCreateDate,
                blockFunctionUpdateDate,
            });
        }
    }

}


export default {bootstrap, get};