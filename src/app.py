
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3
import os
import json
import logging

from decimal import Decimal

# Convert Decimal to float
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return json.JSONEncoder.default(self, obj)

logger = logging.getLogger()
logger.setLevel(logging.ERROR)

dynamodb_client = boto3.client('dynamodb')
dynamodb_resource = boto3.resource('dynamodb')

def lambda_handler(event, context):
    table_name = os.environ.get('DDB_TABLE')
    table = dynamodb_resource.Table(table_name)
    logging.info(f"## Loaded table name from environemt variable DDB_TABLE: {table}")

    http_method = event['httpMethod']

    if http_method == 'POST': 
        if event["body"]:
            item = json.loads(event["body"])
            logging.info(f"## Received payload: {item}")
            id = str(item["news-item-id"])
            logging.info(f"## Received payload: {id}")
            title = str(item["desc-news-item"])
            date = str(item["date-news-item"])
            dynamodb_client.put_item(TableName=table,Item={"news-item-id": {'N':id}, "desc-news-item": {'S':title}, "date-news-item": {'S':date}})
            message = "Successfully inserted data!"
            return {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"message": message})
            }
        else:
            logging.info("## Received request without a payload")
            dynamodb_client.put_item(TableName=table,Item={"news-item-id": {'N':'1'}, "desc-news-item": {'S':'The Amazing Faile News Item'}, "date-news-item": {'S':"Someday"}})
            message = "Successfully inserted data!"
            return {
                "statusCode": 200,
                "headers": {
                    "Content-Type": "application/json"
                },
                "body": json.dumps({"message": message})
            }
    elif http_method == 'GET':
                try:
                    #response = table.scan()
                    while 'LastEvaluatedKey' in response:
                        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
                        data.extend(response['Items'])
                        items = response['Items']
                    return {
                        "statusCode": 200,
                        "headers": {
                            "Content-Type": "application/json"
                        },
                        "body": json.dumps(items)
                    }
                except Exception as e:
                    logging.error(f"Error fetching data from table: {str(e)}")
                    return {
                        "statusCode": 500,
                        "headers": {
                            "Content-Type": "application/json"
                        },
                        "body": json.dumps({"message": "Error fetching data"})
                    }

    else:
                return {
                    "statusCode": 405,
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "body": json.dumps({"message": "Method Not Allowed"})
                }
