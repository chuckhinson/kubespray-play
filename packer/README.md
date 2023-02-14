A Packer project for building an AMI that can be used for a 'managment' server.
Mostly just to give us an ubuntu image with docker installed on it.
## Quick Start

- Review input variables and determine whether defaults need to be change
  - if so, `cp docker-ubuntu.auto.pkvars.hcl.tmpl docker-ubuntu.auto.pkvars.hcl`
  - edit docker.auto.pkvars.hcl and provide appropriate values
- `packer init .` 
- `packer validate .`
- `packer build .`

## Configuration information

Note that we assume aws credential and region information is provided by specifying
an aws profile name and that your .aws/config and .aws/credntials file have
credentials and regions defined

There are a few variables that can be defined to control output.

- **aws_profile** - the name of the profile to be used for aws credentials and region defintion.
  - Leave this undefined if you are using environment variable to define credentials and region
- **source_ami_owner_id** - owner id used to find that ami to be used as the source image.
  - Unless you have special needs, it is probably best to stick with images owned by amazon rather than aws-marketplace
  - Note that the owner id for amazon-owned images in gov cloud regions is different than commercial regions
- **source_ami_name_filter** - a filter string to be used to find the correct ami
- **target_ami_base_name** - a prefix to use when naming the target ami.  The AMI name will consist of the base name with a timestamp appended to it.

## Finding source image information

The aws console does not always make it easy to find what images are available. In most cases, you probably
want to use images that are available under the Quick Start tab on the EC2 Launch Instance page.

Unless you need a very specific AMI, it is suggested that you dont use an AMI ID since most instances get
updated over time.  Instead, we specify a name filter and an owner id and then specify `most_recent = true` so 
that we always have the latest version of the source image.

The easiest way to do that is to go to the Quick Start page and find the ami id for the AMI that you want to
use as your source image.  Then use the following command to get the name and owner id information

```
aws ec2 describe-images --region us-east-2 --image-ids=ami-00eeedc4036573771
```

The output will include OwnerId and Name properties that you can use.  Note that the name usually contains
date the images was created, so you'll want to wildcard that section of the name.  For example,
the name of the above image is `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230208`.  In order
to be able to always get the latest image, you'll want to use `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*` 
as the image filter (Note that we specify architecture=x86_64).  You can use the following command to help
verify the value for your source_ami_name_filter value
```
aws ec2 describe-images --region us-east-2 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" "Name=architecture,Values=x86_64" --image-ids=ami-00eeedc4036573771
```
See the [AWS CLI Command Reference][https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html] for additional information on using the describe-instances command.
