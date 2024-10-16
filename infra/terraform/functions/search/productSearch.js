const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const tableName = process.env.DYNAMODB_TABLE;

  console.log('Received event:', JSON.stringify(event, null, 2));

  // Extracting id and name from query parameters
  const { id, name } = event.queryStringParameters;

  const params = {
    TableName: tableName,
    KeyConditionExpression: 'id = :id', // Query by primary key (id)
    FilterExpression: '#name = :name', // Filter by non-key attribute (name)
    ExpressionAttributeValues: {
      ':id': id,
      ':name': name,
    },
    ExpressionAttributeNames: {
      '#name': 'name', // Dynamodb reserved word, use ExpressionAttributeNames
    },
  };

  try {
    const data = await dynamoDB.query(params).promise();
    console.log('DynamoDB Query Success:', data);
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify(data.Items),
    };
  } catch (err) {
    console.error('DynamoDB Query Error:', err);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({ error: 'Could not retrieve data', details: err.message }),
    };
  }
};
