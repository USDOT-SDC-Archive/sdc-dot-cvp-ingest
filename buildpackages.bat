@echo off
rem this batch script will generate the packages for the python files.
rem more info: http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html

echo deleting existing packages
del /Q *.zip

echo creating new packages for deployment
..\Tools\7z\7za.exe a dataProcessor.zip lambdas\dataProcessor.py lambdas\utils.py

..\Tools\7z\7za.exe a wydot_upload.zip wydot_upload.py utils.py
..\Tools\7z\7za.exe a thea_upload.zip thea_upload.py utils.py

echo Finished

pause
