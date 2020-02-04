# great_expectations_lambda
Minimal deployment of Great Expectations on lambda


## Architecture

All of the AWS infrastructure is created and managed by automated tools - nothing is created from the command line or the AWS console.*

The AWS resources are divided between chalice and terraform.

* Chalice is responsible for lambda functions, API gateway, the execution role, and Cloudfront
* Terraform is used to manage the S3 bucket and lambda layer


## Deploy

Combination of terraform and chalice. In general, terraform should precede chalice.

1. Install tools

- [Terraform 0.12](https://www.terraform.io/downloads.html)
- [AWS Chalice](https://chalice.readthedocs.io/en/latest/)

2. Clone this repo

3. Configure terraform remote state 

```
cd terraform
terraform init
terraform refresh
```

4. Create terraform-managed resources

```
terraform plan
terraform apply
```

Now we should have an S3 bucket, dynamo table, and SQS queue

5. Update [chalice config](api/.chalice/config.json), if needed

6. Deploy chalice

```
cd api
chalice deploy
```

By default, this will deploy to the dev stage. The deploy will create lambdas, the API gateway resources, and a Cloudfront distribution.
