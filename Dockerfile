# based on Martijn Koster's "https://github.com/makuk66/docker-oracle-java7"

FROM vixns/base
MAINTAINER Stéphane Cottin <stephane.cottin@vixns.com>

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    JAVA_VERSION=8u121 \
    JAVA_DEBIAN_VERSION=8u121-b13-1~bpo8+1 \
    CA_CERTIFICATES_JAVA_VERSION=20161107~bpo8+1

RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \    
    && chmod +x /usr/local/bin/docker-java-home \
    && set -ex; \
    \
    apt-get update; \
    apt-get install -y \
        openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
        ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
    ; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
    \
# verify that "docker-java-home" returns what we expect
    [ "$JAVA_HOME" = "$(docker-java-home)" ]; \
    \
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
    update-alternatives --get-selections | awk -v home="$JAVA_HOME" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
    update-alternatives --query java | grep -q 'Status: manual'; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure 
