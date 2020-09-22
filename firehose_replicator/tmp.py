
#
# Little helper for verifying s3 put from quarantine into ECS
#
import boto3

s3_client = boto3.client('s3')
target_bucket = 'dev-dot-sdc-raw-submissions-505135622787-us-east-1'
file_content = b'hello'
file_key = 'hello_from_quarantine.txt'
# target bucket must allow PUT from source ARN:
# arn:aws:lambda:us-east-1:911061262852:function:dev-put-s3-object-into-ecs

response = s3_client.put_object(
    Body=file_content, 
    Bucket=target_bucket,
    Key=file_key)

print(f"Uploaded object with ETag {response['ETag']}")