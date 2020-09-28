zip -r data_processor.zip data_processor.py

# Push zipped files up to S3
aws s3 cp data_processor.zip s3://prod-lambda-bucket-004118380849/sdc-dot-cvp-ingest/data_processor.zip