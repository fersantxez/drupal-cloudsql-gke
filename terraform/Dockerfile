ARG SDK_VERSION=latest
FROM google/cloud-sdk:${SDK_VERSION}

#ENV ACCOUNT_ID
#ENV ORG_ID
#ENV BILLING_ACCOUNT
#ENV PROJECT
ENV REGION "us-east4"
ENV ZONE "us-east4-c"
#ENV MASTER_PASSWORD

RUN mkdir /terraform
ADD . /terraform
WORKDIR /terraform

CMD . run.sh