#
# Copyright (c) 2018, 2019 Intel
#
# SPDX-License-Identifier: Apache-2.0
#

# FROM golang:1.11-alpine AS builder
# ARG BUILD_PATH
# ARG GOARCH

# RUN sed -e 's/dl-cdn[.]alpinelinux.org/nl.alpinelinux.org/g' -i~ /etc/apk/repositories

# # add git for go modules
# RUN apk update && apk add make git

# WORKDIR $BUILD_PATH

# COPY . .

# RUN GOPROXY="https://mirrors.aliyun.com/goproxy/" go get -d -v ./...

# RUN make build-$GOARCH

# Next image - Copy built Go binary into new workspace
FROM ubuntu:16.04
# ARG BUILD_PATH
ARG GOARCH

ENV APP_PORT=80
#expose command data port
EXPOSE $APP_PORT

WORKDIR /app
# COPY --from=builder $BUILD_PATH/bin/device-service-$GOARCH /app/device-service
# COPY --from=builder $BUILD_PATH/cmd/device-service/res /app/res
# COPY --from=builder $BUILD_PATH/cmd/device-service/res/docker/configuration.toml /app/res/configuration.toml
COPY bin/device-service-$GOARCH /app/device-service
COPY bin/res /app/res
COPY bin/res/docker/configuration.toml /app/res/configuration.toml
COPY bin/gatt-python /app/gatt-python
COPY bin/bluez-5.54.tar.xz /app/bluez-5.54.tar.xz
COPY CHANGELOG.md /app

# install python3-dbus and gatt
RUN apt-get update &&\
    apt-get install -y python3 &&\
    apt-get install -y python3-pip &&\
    apt-get install -y python3-dbus
RUN pip3 install gatt

# bluez dependencies
RUN cd /app/ && \
    apt-get install -y udev libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev libdbus-glib-1-dev unzip && \
    apt-get install -y blueman bluetooth && \
    tar xvf bluez-5.54.tar.xz

# install bluez
RUN cd /app/bluez-5.54 && \
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-library && \
    # ./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var && \
    make  && \
    make install

# config bluez
RUN  mv /usr/lib/bluetooth/bluetoothd /usr/lib/bluetooth/bluetoothd.orig && \
    ln -s /usr/libexec/bluetooth/bluetoothd /usr/lib/bluetooth/bluetoothd && \
    install -v -dm755 /etc/bluetooth && \
    bluetoothd --version

# rm bluez-5.54.tar.xz bluez-5.54
RUN cd /app && \
    rm bluez-5.54.tar.xz && \
    rm -r bluez-5.54

ENTRYPOINT [ "/app/device-service"]
