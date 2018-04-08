FROM alpine:3.7

RUN apk -Uuv add ca-certificates openssl groff less git bash wget make jq curl unzip sed

WORKDIR /app

ENTRYPOINT ["/bin/terraform"]

CMD ["--help"]

ENV TERRAFORM_VERSION=0.11.6
ENV TERRAFORM_FILENAME=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ENV TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILENAME}
ENV TERRAFORM_SHA256SUM=aed5c7388a3c54dc816986903d4dea32e182a002d746295e1016f6db741f472d

RUN wget -q ${TERRAFORM_URL} \
  && echo "${TERRAFORM_SHA256SUM}  ${TERRAFORM_FILENAME}" | sha256sum -c
RUN unzip ${TERRAFORM_FILENAME} -d /bin
RUN rm -f ${TERRAFORM_FILENAME}

ENV HCLOUD_VERSION=1.1.0
ENV HCLOUD_FILENAME=terraform-provider-hcloud_v${HCLOUD_VERSION}_linux_amd64.zip
ENV HCLOUD_TERRAFORM_URL=https://github.com/hetznercloud/terraform-provider-hcloud/releases/download/v${HCLOUD_VERSION}/${HCLOUD_FILENAME}
ENV HCLOUD_TERRAFORM_SHA256SUM=

RUN echo "Install Terraform plugin from:" \
  && echo "${HCLOUD_TERRAFORM_URL}"
RUN mkdir -p ~/.terraform.d/plugins/
RUN wget -q ${HCLOUD_TERRAFORM_URL}
RUN unzip ${HCLOUD_FILENAME} -d ~/.terraform.d/plugins/
RUN rm -f ${HCLOUD_FILENAME}

RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

RUN terraform --version

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/insekticid/docker-terraform-hcloud-example"