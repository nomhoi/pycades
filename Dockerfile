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
    echo "ba1d8b945e9e9ecdf3766eb6701e5ef8  linux-amd64_deb.tgz" >> MD5SUM && md5sum -c MD5SUM && \
    tar xvf linux-amd64_deb.tgz && \
    ./linux-amd64_deb/install.sh && \
    apt-get install ./linux-amd64_deb/lsb-cprocsp-devel_5.0.11998-6_all.deb

RUN set -ex && \
    echo "11ec1def2383ba5644066ab73163785f  cades_linux_amd64.tar.gz" >> MD5SUM && md5sum -c MD5SUM && \
    tar xvf cades_linux_amd64.tar.gz && \
    apt-get install ./cades_linux_amd64/cprocsp-pki-cades-64_2.0.14071-1_amd64.deb

RUN set -ex && \
    echo "de2cb68510a6bb8f6962e3ccda892e68  pycades.zip" >> MD5SUM && md5sum -c MD5SUM && \
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
