FROM python:3.7-alpine

ENV TERRAFORM_VERSION=0.11.11
ENV PATH "$PATH:/usr/bin"

RUN mkdir /tf
WORKDIR /tf

COPY python-package-requirements.txt python-package-requirements.txt

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

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

LABEL maintainer="Jon Gasparini, <jon@gasparini.org.uk>" \
	version="0.1"

ENTRYPOINT [ "sh"]