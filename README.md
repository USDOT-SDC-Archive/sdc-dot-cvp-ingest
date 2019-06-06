[![Build Status](https://travis-ci.org/usdot-jpo-sdc/sdc-dot-cvp-ingest.svg?branch=master)](https://travis-ci.org/usdot-jpo-sdc/sdc-dot-cvp-ingest)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=usdot-jpo-sdc_sdc-dot-cvp-ingest&metric=alert_status)](https://sonarcloud.io/dashboard?id=usdot-jpo-sdc_sdc-dot-cvp-ingest)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=usdot-jpo-sdc_sdc-dot-cvp-ingest&metric=coverage)](https://sonarcloud.io/dashboard?id=usdot-jpo-sdc_sdc-dot-cvp-ingest)
# sdc-dot-cvp-ingest
US Department of Transportation (USDOT) Intelligent Transportation Systems Secure Data Commons (ITS SDC). Connected Vehicle Pilots (CVP) tools to support data ingest into the Data Lake.

## Secure Data Commons - Introduction
The Secure Data Commons (SDC) is a United States Department of Transportation (U.S DOT) sponsored cloud-based analytical sandbox designed to create wider access to sensitive transportation data sets, with the goal of advancing the state of the art of transportation research and state/local traffic management. 

The SDC stores sensitive transportation data made available by participating data providers, and grants access to approved researchers to these datasets. The SDC also provides access to open-source tools, and allow researchers to collaborate and share code with other system users.

The SDC platform is a research environment that allows users to conduct analyses and do development and testing of new tools and software products.  It is not intended to be an alternative to any local jurisdiction’s traffic management center or local data repository.  The existing SDC provides users with the following data, tools, and features:

* Data: The SDC is ingesting several datasets currently. Additional data sets will be added to the environment over time.
* Tools: The environment provides access to open source tools including Python, RStudio, Microsoft R, SQL Workbench, Power BI, Jupyter Notebook, and others. These tools are available on a virtual machine in the system enabling data analytics in the cloud. 
* Functionality: Users can access and analyze data within the environment, save their work to a virtual machine, and publish processes and results to share with others.

The SDC platform supports two major roles:

* Data Providers: These are entities that provide data hosted on the SDC platform. The data provider establishes the data protection needs and acceptable use terms for the data analysts. 
* Data Analysts: These are entities that conduct analysis of the datasets hosted in the SDC system.  Note that analysts can bring their own data and tools into the SDC system.

The following diagram represents a high level overview of the SDC Platform:

![SDC System Diagram](https://github.com/usdot-jpo-sdc/sdc-dot-cvp-staging/blob/master/images/sdc_system_diagram.jpg)

Looking from the bottom up, the [ITS ODE service](https://github.com/usdot-jpo-ode) performs near-real time data ingest via Kinesis Firehose, while data ingest trhough S3 ingest buckets are done either with automated scripts or manually.

## AWS S3 Data Ingest Repository

There are 2 methods of ingesting data sets into the SDC: near-real time ingest through a Kinesis Firehose endpoint, and data ingest through an S3 ingest bucket.

For a Kinesis Firehose ingest, data files are copied directly into a Data Lake S3-based message repository according to Firehose's configuration. For an S3 ingest, data files are uploaded into an S3 ingest bucket and moved into the Data Lake with a Lambda function.

This repository contains Lambda function implementation for the S3 data ingest flow as well as unit test and corresponding scrits to exercise this function.


