ARG SDK_VERSION=latest

FROM google/cloud-sdk:${SDK_VERSION}

ENV TF_VERSION "0.11.7"
ENV TF_FILENAME terraform_"${TF_VERSION}"_linux_amd64.zip
ENV TF_URL "https://releases.hashicorp.com/terraform/"${TF_VERSION}"/"${TF_FILENAME}
ENV TF_BIN "terraform"
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

#download and install terraform
RUN curl -O ${TF_URL}
RUN apt-get install -y unzip
RUN unzip ${TF_FILENAME}
RUN mv ${TF_BIN} /usr/bin
RUN ["chmod", "+x", "/terraform/run.sh"]
RUN echo "**DEBUG: contents of CWD: "$(ls -la)
ENTRYPOINT ["/terraform/run.sh"]
