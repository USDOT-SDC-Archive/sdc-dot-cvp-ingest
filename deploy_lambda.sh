if [[ -z $1 ]]; then
  echo "You must provide an environment parameter"
  exit 1
fi

zip -r data_processor.zip data_processor.py

aws s3 cp data_processor.zip s3://$1-lambda-bucket-505135622787/sdc-dot-oss4its-ingest/data_processor.zip --region us-east-1
