# great_expectations_lambda
Minimal deployment of Great Expectations on lambda

Managing python dependencies in AWS lambda can be very painful. As of this writing (February 2020), lambda has a 250MB limit for layers. Since the numpy, scipy, and pandas alone are well over 200MB, deploying `great_expectations` on lambda takes some ingenuity.

This guide shows how to manage dependencies for deploying `great_expectations` on AWS lambda. It doesn't (yet) actually execute anything in `great_expectations`. That part is up to you.


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

3. Build your layer:
```
cd layer
bash build_layer.sh
cd ..
```

4. Configure terraform remote state 

```
cd terraform
terraform init
terraform refresh
```

Note: if you haven't configured a terraform state for your environment, you may need to do so here.
See terraform's docs (https://www.terraform.io/docs/state/remote.html) for more information.

5. Create terraform-managed resources

In `terraform/variables.tf`, replace `{{{YOUR BUCKET NAME GOES HERE}}}` with the name of a new S3 bucket to create. This bucket will be used to load additional dependencies into lambda.

```
terraform plan
terraform apply
```

Now we should have an S3 bucket and a lambda layer.

The lambda layer contains great_expectations and most of its dependencies. We're going to use the S3 bucket to "side load" a additional python libraries: numpy, scipy, pandas, pytz, dateutil, and six.

These additional dependencies would exceed lambda's 250MB limit for layers. To get around that problem, we will load them into lambda's tmp/ directory at run time. Since this directory doesn't count towards the 250MB limit, we can squeeze our extra packages in there.

6. Prepare the side load in S3.

NOTE: There is the one stage of the setup that I haven't yet made fully reproducible: building ge_deps.zip. For now, you can just use my pre-built zip. If you're the enterprising type, you can inspect its contents and rebuild it yourself. IIR, you need to do it within an EC2 or docker instance with the same operating system that lambda runs on.

ge_deps.zip contains the libraries for the side load. You will need to (1) upload it to your s3 bucket and (2) make it public, so that lambda can access it. You can do both from the AWS console or using the cli:

`aws s3 cp ge_deps.zip s3://your-bucket-name/ --acl public-read`

7. Update [chalice config](api/.chalice/config.json).

There are two places to update:

* `{{{REPLACE THIS WITH THE LAMBDA LAYER ARN RETURNED BY TERRAFORM}}}`
* `{{{REPLACE THIS WITH YOUR BUCKET NAME}}}`

8. Deploy chalice

```
cd api
chalice deploy
```

By default, this will deploy to the dev stage. The deploy will create lambdas, the API gateway resources, and a Cloudfront distribution.

The output should look something like this:
```
$ chalice deploy
Creating deployment package.
Updating policy for IAM role: api-dev
Updating lambda function: api-dev
Updating rest API
Resources deployed:
  - Lambda ARN: arn:aws:lambda:us-east-2:726754635241:function:api-dev
  - Rest API URL: https://jvw99y5fbp.execute-api.us-east-2.amazonaws.com/api/
```

9. Test it with curl:

`curl https://jvw99y5fbp.execute-api.us-east-2.amazonaws.com/api/`

If everything is working, your lambda should return:
`{"great_expectations":"is loaded!"}`

If not everything is working, you will most likely see :
`{"Code":"InternalServerError","Message":"An internal server error occurred."}`

If this happens, you should probably start by using CloudWatch logs to debug.

Note: the first time your lambda runs, it will pause for a couple seconds to load ge_deps.zip from S3.

## What does it do?

Nothing, actually. This lambda loads `great_expectations`, but doesn't actually execute anything. That part is us to you.

## Contributions welcome!

Ideas

* Reproducible steps for creating `ge_deps.zip`
* Actually do something with Great Expectations. :)