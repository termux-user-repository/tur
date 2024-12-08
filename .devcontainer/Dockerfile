FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install git

RUN git clone https://github.com/termux/termux-packages
USER vscode
RUN ./termux-packages/scripts/setup-ubuntu.sh
RUN ./termux-packages/scripts/setup-android-sdk.sh

USER root
RUN rm -rf termux-packages
