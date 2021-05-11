zip -r data_processor.zip data_processor.py

# Push zipped files up to S3
aws s3 cp data_processor.zip s3://dev-lambda-bucket-505135622787/sdc-dot-cvp-ingest/data_processor.zip