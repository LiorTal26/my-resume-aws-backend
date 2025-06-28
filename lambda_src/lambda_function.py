# lambda_function.py
import json, boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("resume_visitors")

def lambda_handler(event, context):
    method = event["requestContext"]["http"]["method"]
    inc    = method == "POST"

    if inc:
        resp = table.update_item(
            Key={"id": "counter"},
            UpdateExpression="SET #c = if_not_exists(#c,:zero)+:one",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":one": 1, ":zero": 0},
            ReturnValues="UPDATED_NEW"
        )
        count = int(resp["Attributes"]["count"])
    else:
        count = int(table.get_item(Key={"id": "counter"})["Item"]["count"])

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,POST"
        },
        "body": json.dumps({"visitors": count})
    }
