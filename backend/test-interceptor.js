
require('dotenv').config();
const dbService = require('./services/dbService');
const { DynamoDBDocumentClient, UpdateCommand } = require('@aws-sdk/lib-dynamodb');

const originalSend = dbService.ddbDocClient.send;
dbService.ddbDocClient.send = async (command, ...args) => {
  if (command.constructor.name === 'UpdateCommand') {
    console.log('Intercepted UpdateCommand!', command.input.ExpressionAttributeValues);
  }
  // DO NOT actually send to DynamoDB to prevent errors, just return {}
  return { Attributes: {} };
};

dbService.updateSession('sess_123', { events: [{ ts: 1, event: 'test' }] })
  .then(() => console.log('Done'))
  .catch(console.error);

