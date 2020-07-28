# Terraform 101

Terraform is a tool from Hashicorp. Terraform comes latin and means to create earth.

The naming convention is because the tool is used to orchestrate our infrastructure and is part of IAC.


IAC:
- Configuration Management tool
  - i.e. Chef, puppet and Ansible
  - helps us create immutable infrastructure
  - if we ssh into our testing server and install `sudo apt get install type-script` we now need to do this to all our machines
  - if we have a configuration management tool we can make this change more immutable and it will be easier to replicate everywhere
  - the idea is you should be able to terminate a machine, run a script and endup exactly at the same location/state as the previous machine
  - end game should be a AMI of some sort
- Orchestration tools
  - Terraform, AWScloudformation and others
  - this will create the infrastructure, not only specific machine but the networking, monitoring, security and all the setup around the machine that creates a production environment.
  - ex:
    1. automation server gets triggered
    2. test are run in machine created from AMI (configuration)
    3. Passing test trigger next step on automation server
    4. New AMI is created with previous AMI + new code
    5. Successful creation triggers next step in automation server
    6. Calls terraform script to create infrastructure and deploy new AMI (with new code)

  - ex:
    1. Terraform creates VPC
    2. creates two subnets
    3. Adds rules and security
    4. Deploys AMIs and runs scripts

The conjuction of the two allows us to define our infrastructure as code.

Along with Version control - such as Git - it allows us to maintain and manipulate infrastructure in ways that were not possible before.

### Terraform terminology
- providers
- resources
  - ec2
- variables

### Terraform commands

##### Installation
$ brew install terraform

##### Launch
$ terraform init

##### Create plan
$ terraform plan

##### Create instance
$ terraform apply

##### Terminate instance
$ terraform destroy
