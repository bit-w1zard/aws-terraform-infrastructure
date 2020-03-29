## aws-terraform-infrastructure
Contains infrastructure configuration of aws resources for an authentication module.

## Introduction
The purpose of this configuration is to setup aws resources for an authentication module that aims to
make an application compliance with ISO - 27001. For this purpose different set of AWS services are used in
order to achieve this functionality.

## AWS Services
* Cognito
* S3
* DynamoDB
* Lambda
* SNS
* SSM

## Terraform files
The setup consists of following files along with their specifications:

1- ```cognito.tf```
This file consists of configuration needed for AWS Cognito services. It defines various schema attributes, variables
and resources to be used for the module of user pool in cognito.

2- ```data.tf```
This is the main state management file for the data configuration to be used across all the services. It includes
provisioning of resource policies, names along with Access Control rules and mechanisms.

3- ```dynamodb.tf```
It consists of configurations for all the dynamodb tables. Each module defines following for each table:
* schema-attributes
* Indexes
* providers
* other options

4- ```frontend.tf```
It includes setup of a frontend that is served statically through a S3 bucket. The S3 bucket serves the frontend
statically after applying proper procedures in place. In order to make the frontend while serving, it is connected with
Cloudfront and custom TLS certificates are also attached.

5- ```lambdas.tf```
Provides configuration for all type of lambda functions necessary for execution of the module. Each set of
lambda function module contains following information:
* Policy rules
* existing runtime packages from S3
* environment variables
* allowed triggers

6- ```locals.tf```
All types of variables for the infrastructure are defined in this file.

7- ```main.tf```
Defines sources, policies, providers for main resources of the application.

8- ```providers.tf```
Consists of list of providers to be used by various cloud services.

9- ```sns.tf```
Defines rules for the AWS SNS service.

10- ```ssm.tf```
Consists of secure resource provisions to be stored in aws SSM.