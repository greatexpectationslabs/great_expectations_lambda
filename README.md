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

```
terraform plan
terraform apply
```

Now we should have an S3 bucket and a lambda layer.

The lambda layer contains great_expectations and most of its dependencies. We're going to use the S3 bucket to "side load" a additional python libraries: numpy, scipy, pandas, pytz, dateutil, and six.

These additional dependencies would exceed lambda's 250MB limit for layers. To get around that problem, we will load them into lambda's tmp/ directory at run time. Since this directory doesn't count towards the 250MB limit, we can squeeze our extra packages in there.

6. Prepare the side load in S3.

This is the one stage of the setup that I haven't yet made fully reproducible. ge_deps.zip contains the



5. Update [chalice config](api/.chalice/config.json), if needed

6. Deploy chalice

```
cd api
chalice deploy
```

By default, this will deploy to the dev stage. The deploy will create lambdas, the API gateway resources, and a Cloudfront distribution.
