FROM python:3.7-alpine

# Set environment variables for AWSCLI and Terraform
ENV AWS_DEFAULT_REGION=us-west-1
ENV TERRAFORM_VERSION=0.11.11
ENV PATH "$PATH:/usr/bin"

RUN mkdir /tf
WORKDIR /tf

# Copy file which contains a list of python packages required (including AWSCLI)
COPY python-package-requirements.txt python-package-requirements.txt

# Install packages and dependencies.  Cleans up dependencies afterwards
RUN apk add --no-cache --virtual .build-deps \
    && pip install -r python-package-requirements.txt \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps

#Download and install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

LABEL maintainer="Jon Gasparini, <jon@gasparini.org.uk>" \
	version="0.1"

# Expose volume for adding AWS credentials
VOLUME ["~/.aws"]

ENTRYPOINT [ "sh"]