FROM amazon/aws-cli
LABEL maintainer "Bray Almini <bray@coreforge.com>"
RUN yum install -y jq && yum clean all
COPY spotWatch.sh /opt/spotWatch.sh
RUN chmod +x /opt/spotWatch.sh
ENTRYPOINT ["/opt/spotWatch.sh"]
