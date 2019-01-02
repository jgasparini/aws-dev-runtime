# aws-dev-runtime
AWS developer runtime environment using Docker including tools such as AWS CLI and Terraform plus Python 3.7.2

# building the docker image
To build the docker image use the following command from the directory with the Dockerfile:

  docker image build -t aws-dev-rte .
  
# running the docker image
To run the docker image use the command below.  This will drop you into a new shell where you can directly access AWSCLI and Terraform.  

  docker container run -it --rm --name aws-dev-rt aws-dev-rt
