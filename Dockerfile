FROM python:3.8 AS build

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        cmake \
        build-essential \
        libboost-all-dev \
        python3-dev \
        unzip; \
    rm -rf /var/lib/apt/lists/*

COPY ./cprocsp /cprocsp

WORKDIR /cprocsp

RUN set -ex && \
    GOST=$(./cpverify -mk ./cpverify) && \
    if [ $GOST != "B1D823D61CD3081DB18D160D8EC510A16938EBAD1DFA38868E939073ABA18300" ]; then \
        exit 1; \
    fi;

RUN set -ex && \
    GOST=$(./cpverify -mk ./linux-amd64_deb.tgz) && \
    if [ $GOST != "D092502B77D2AAC3E92F644A426F9C6982787AFBF566DF8B60BFE0A4BE42BCED" ]; then \
        exit 1; \
    fi && \
    tar xvf linux-amd64_deb.tgz && \
    ./linux-amd64_deb/install.sh && \
    apt-get install ./linux-amd64_deb/lsb-cprocsp-devel_5.0.11998-6_all.deb

RUN set -ex && \
    GOST=$(./cpverify -mk ./cades_linux_amd64.tar.gz) && \
    if [ $GOST != "A0F68B4DFCDCF858A51BD713A167B6BB2FC652581B5B43A8ADD79F59D741E689" ]; then \
        exit 1; \
    fi && \
    tar xvf cades_linux_amd64.tar.gz && \
    apt-get install ./cades_linux_amd64/cprocsp-pki-cades-64_2.0.14071-1_amd64.deb

RUN set -ex && \
    GOST=$(./cpverify -mk ./pycades.zip) && \
    if [ $GOST != "37A047105C57F927937DA0AD99FE9E0CB490FFEE80B035F9C9A591A9C712B6DA" ]; then \
        exit 1; \
    fi && \
    cd /cprocsp; \
    unzip pycades.zip;

ENV PYCADES="pycades_0.1.22769"

COPY CMakeLists.txt /cprocsp/$PYCADES/CMakeLists.txt

RUN set -ex; \
    cd /cprocsp/$PYCADES; \
    mkdir build; \
    cd build; \
    cmake ..; \
    make -j4

FROM python:3.8

ENV PYCADES="pycades_0.1.22769"

COPY --from=build /cprocsp/$PYCADES/pycades.so /usr/local/lib/python3.8/pycades.so

COPY --from=build /opt/cprocsp /opt/cprocsp/

COPY --from=build /var/opt/cprocsp /var/opt/cprocsp/

COPY --from=build /etc/opt/cprocsp /etc/opt/cprocsp/