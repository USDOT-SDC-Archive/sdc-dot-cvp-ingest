if [[ -z $1 ]]; then
  echo "You must provide an environment parameter ('dev' or 'prod')"
  exit 1
fi

ACCT_NUM='505135622787'

if [ $1 == 'prod' ]
then
   ACCT_NUM='004118380849'
fi

ZIP_NAME="firehose_replicator.zip"
CODE_DIR="firehose_replicator"

# install requirements in a virtual environment
python3.7 -m venv .venv
. .venv/bin/activate
pip3 install -r requirements-prod.txt --upgrade
deactivate

# Remove existing zip to avoid any bugs related to updating it
echo "Removing existing zip (if applicable)"
rm -f $ZIP_NAME

# Zip python files and dependencies
export CURRENT_DIR=$(pwd)
PYV=`python3.7 -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)";`
pushd .venv/lib/python$PYV/site-packages
echo "Zipping site-packages..."
zip -rq $CURRENT_DIR/$ZIP_NAME .
popd
echo "Zipping $ZIP_NAME..."

pushd $CODE_DIR
zip -g ../$ZIP_NAME *.py 
popd

# Push zipped files up to S3
echo "Copying to s3..."
aws s3 cp $ZIP_NAME s3://$1-lambda-bucket-$ACCT_NUM/sdc-dot-oss4its-ingest/$ZIP_NAME --region us-east-1

echo ""
echo "Done!"
