if [[ -z $1 ]]; then
  echo "You must provide an environment parameter"
  exit 1
fi

zip -r data_processor.zip data_processor.py

aws s3 cp --profile sdc data_processor.zip s3://$1-dot-sdc-regional-lambda-bucket-911061262852-us-east-1/sdc-dot-cvp-ingest/data_processor.zip --region us-east-1 --acl public-read
