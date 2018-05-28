ARG SDK_VERSION=latest

FROM google/cloud-sdk:${SDK_VERSION}

ENV TF_VERSION "0.11.7"
ENV TF_FILENAME terraform_"${TF_VERSION}"_linux_amd64.zip
ENV TF_URL "https://releases.hashicorp.com/terraform/"${TF_VERSION}"/"${TF_FILENAME}
ENV TF_BIN "terraform"

#These variables must be passed in the docker run invocation and have no default
#ENV ACCOUNT_ID
#ENV ORG_ID
#ENV BILLING_ACCOUNT
#ENV PROJECT
#ENV REGION
#ENV ZONE
#ENV MASTER_PASSWORD

RUN mkdir /terraform
ADD . /terraform
WORKDIR /terraform

#download and install terraform
RUN curl -O ${TF_URL}
RUN apt-get install -y unzip
RUN unzip ${TF_FILENAME}
RUN mv ${TF_BIN} /usr/bin

#run init script
RUN ["chmod", "+x", "/terraform/run.sh"]
RUN ["chmod", "+x", "/terraform/post-install-rook-ceph.sh"]
ENTRYPOINT ["/terraform/run.sh"]