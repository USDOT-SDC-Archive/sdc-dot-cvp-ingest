[![Build Status](https://travis-ci.org/USDOT-SDC/sdc-dot-cvp-ingest.svg?branch=master)](https://travis-ci.org/usdot-jpo-sdc/sdc-dot-cvp-ingest)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=KBRPurchase1_sdc-dot-cvp-ingest&metric=alert_status)](https://sonarcloud.io/dashboard?id=KBRPurchase1_sdc-dot-cvp-ingest)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=KBRPurchase1_sdc-dot-cvp-ingest&metric=coverage)](https://sonarcloud.io/dashboard?id=KBRPurchase1_sdc-dot-cvp-ingest)

# sdc-dot-cvp-ingest

US Department of Transportation (USDOT) Intelligent Transportation Systems Secure Data Commons (ITS SDC). Connected Vehicle Pilots (CVP) tools to support data ingest into the Data Lake.

The Secure Data Commons (SDC) is a cloud-based analytics platform that enables access to traffic engineers, researchers, and data scientists to various transportation related datasets. The SDC platform is a prototype created as part of the U.S. Department of Transportation (USDOT) research project.  The objective of this prototype is to provide a secure platform, which will enable USDOT and the broader transportation sector to share and collaborate their research, tools, algorithms, analysis, and more around sensitive datasets using modern, commercially available tools without the need to install tools or software locally.  Secure Data Commons (SDC) enables collaborative but controlled integration and analysis of research data at the moderate sensitivity level (PII & CBI).

The SDC platform allows users to conduct analyses and do development and testing of new tools and software products.  It is not intended to be an alternative to any local jurisdiction’s traffic management center or local data repository.  The existing SDC provides users with the following data, tools, and features:

* Data: The SDC is ingesting several datasets currently. Additional data sets will be added to the environment over time.
* Tools: The environment provides access to open source tools including Python, RStudio, Microsoft R, SQL Workbench, Power BI, Jupyter Notebook, and others. These tools are available on a virtual machine in the system enabling data analytics in the cloud. 
* Functionality: Users can access and analyze data within the environment, save their work to a virtual machine, and publish processes and results to share with others.

The SDC platform supports two major roles:

* Data Providers: These are entities that provide data hosted on the SDC platform. The data provider establishes the data protection needs and acceptable use terms for the data analysts. 
* Data Analysts: These are entities that conduct analysis of the datasets hosted in the SDC system.  Note that analysts can bring their own data and tools into the SDC system.


<!---                           -->
<!---     Table of Contents     -->
<!---                           -->
## Table of Contents

[I. Release Notes](#release-notes)

[II. Usage Example](#usage-example)

[III. Configuration](#configuration)

[IV. Installation](#installation)

[V. Design and Architecture](#design-architecture)

[VI. Unit Tests](#unit-tests)

[VII.  File Manifest](#file-manifest)

[VIII.  Development Setup](#development-setup)

[IX.  Release History](#release-history)

[X. Contact Information](#contact-information)

[XI. Contributing](#contributing)

[XII. Known Bugs](#known-bugs)

[XIII. Credits and Acknowledgment](#credits-and-acknowledgement)

[XIV.  CODE.GOV Registration Info](#code-gov-registration-info)


<!---                           -->
<!---     Release Notes         -->
<!---                           -->

<a name="release-notes"/>

## I. Release Notes
**August 13, 2020. SDC sdc-cvp-ingest Release 1.0**
* Import/reconcile additional manually created resources with Terraform
* Configuration for Kinesis Firehose Delivery Streams are uniform
* Update tags and resource descriptions to match naming conventions

**August 7, 2020. SDC sdc-cvp-ingest Release 1.0**
* Import/reconcile manually created resources with Terraform
* Configuration for Lambdas are uniform
* Update tags to match proper team

<a name="usage-example"/>

## II. Usage Example



<!---                           -->
<!---     Configuration         -->
<!---                           -->

<a name="configuration"/>

## III. Configuration


<!---                           -->
<!---     Installation          -->
<!---                           -->

<a name="installation"/>

## IV. Installation


<!---                                 -->
<!---     Design and Architecture     -->
<!---                                 -->

<a name="design-architecture"/>

## V. Design and Architecture

The following diagram represents a high level overview of the SDC Platform:

![SDC System Diagram](https://github.com/usdot-jpo-sdc/sdc-dot-cvp-staging/blob/master/images/sdc_system_diagram.jpg)

Looking from the bottom up, the [ITS ODE service](https://github.com/usdot-jpo-ode) performs near-real time data ingest via Kinesis Firehose, while data ingest trhough S3 ingest buckets are done either with automated scripts or manually.

### AWS S3 Data Ingest Repository

There are 2 methods of ingesting data sets into the SDC: near-real time ingest through a Kinesis Firehose endpoint, and data ingest through an S3 ingest bucket.

For a Kinesis Firehose ingest, data files are copied directly into a Data Lake S3-based message repository according to Firehose's configuration. For an S3 ingest, data files are uploaded into an S3 ingest bucket and moved into the Data Lake with a Lambda function.

This repository contains Lambda function implementation for the S3 data ingest flow as well as unit test and corresponding scrits to exercise this function.


<!---                           -->
<!---     Unit Tests          -->
<!---                           -->

<a name="unit-tests"/>

## VI. Unit Tests




<!---                           -->
<!---     File Manifest         -->
<!---                           -->

<a name="file-manifest"/>

## VII. File Manifest


<!---                           -->
<!---     Development Setup     -->
<!---                           -->

<a name="development-setup"/>

## VIII. Development Setup

### Installing Python on build box

You can run the following on the ECS build box to install a different version of python (e.g. `3.7.9`):

```
# assuming you are SSHed as ec2-user
sudo su
cd ~/

# make sure libffi is installed
yum install libffi-devel

# install python 3.7
curl -O https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz
tar -xzf Python-3.7.9.tgz
cd Python-3.7.9
./configure --enable-optimizations
make altinstall

# and now you can use python3.7 as an alias
```



<!---                           -->
<!---     Release History       -->
<!---                           -->

<a name="release-history"/>

## IX. Release History


<!---                             -->
<!---     Contact Information     -->
<!---                             -->

<a name="contact-information"/>

## X. Contact Information

<!-- Your Name – @YourTwitter – YourEmail@example.com
Distributed under the XYZ license. See LICENSE for more information.
https://github.com/yourname/github-link -->

For any queries you can reach to support@securedatacommons.com


<!---                           -->
<!---     Contributing          -->
<!---                           -->

<a name="contributing"/>

## XI. Contributing


<!---                           -->
<!---     Known Bugs            -->
<!---                           -->

<a name="known-bugs"/>

## XII. Known Bugs


<!---                                    -->
<!---     Credits and Acknowledgment     -->
<!---                                    -->

<a name="credits-and-acknowledgement"/>

## XIII. Credits and Acknowledgment
Thank you to the Department of Transportation for funding to develop this project.


<!---                                    -->
<!---     CODE.GOV Registration Info     -->
<!---                                    -->

<a name="code-gov-registration-info">

## XIV. CODE.GOV Registration Info
Agency:  DOT

Short Description:  US Department of Transportation (USDOT) Intelligent Transportation Systems Secure Data Commons (ITS SDC). Connected Vehicle Pilots (CVP) tools to support data ingest into the Data Lake.

Status: Beta

Tags: transportation, connected vehicles, intelligent transportation systems

Labor Hours:

Contact Name: support@securedatacommons.com

<!-- Contact Phone: -->
