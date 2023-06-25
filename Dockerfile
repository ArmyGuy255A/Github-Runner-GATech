#Derived from: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
#Author: Marcel L
#Author Email: pwd9000@hotmail.co.uk
#Modified by Phil Dieppa
#Modification Email: pdieppa3@gatech.edu

# base image
# FROM alpine:latest
FROM ubuntu:20.04

#input GitHub runner version argument
ENV RUNNER_VERSION=2.299.2
ENV MAVEN_VERSION=3.9.2
ENV GRADLE_VERSION=8.1.1
ENV ANDROID_SDK_ROOT="/usr/lib/android-sdk"
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Phil Dieppa"
LABEL Email="pdieppa3@gatech.edu"
LABEL GitHub="https://github.gatech.edu/pdieppa3"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages + add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev \
    python3 python3-venv python3-dev python3-pip zip openjdk-17-jdk pandoc texlive \
    texlive-xetex lmodern sudo && \
    adduser --disabled-password --gecos '' docker && \
    adduser docker sudo

# Add 'docker' to sudoers list without requiring a password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# cd into the user directory, download and unzip the github actions runner
# Note: this runner needs to be consistent/compatible with the Enterprise Github server
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# add over the start.sh script
ADD scripts/start.sh start.sh

# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

#Install maven
RUN cd /root && curl -O -L https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar xzf ./apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm ./apache*

#Setup maven
ADD scripts/maven.sh /etc/profile.d/maven.sh

RUN chmod +x /etc/profile.d/maven.sh

#Download Gradle and unzip it in /opt
RUN curl -o gradle.zip -O -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle.zip -d /opt \
    && rm gradle.zip

# Set Gradle in the PATH
ENV PATH $PATH:/opt/gradle-${GRADLE_VERSION}/bin

# Install Android SDK Command line tools
# RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
#     && curl -o android.zip -O -L https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip \
#     && unzip android.zip -d ${ANDROID_SDK_ROOT} \
#     && rm android.zip

# ENV PATH $PATH:${ANDROID_SDK_ROOT}/cmdline-tools/bin

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

#Load Maven
RUN . /etc/profile.d/maven.sh

# Accept Android SDK licenses
# RUN yes | sdkmanager --licenses

# Install Android SDK packages
# RUN sdkmanager "platforms;android-30" "build-tools;30.0.2" "emulator" "system-images;android-30;google_apis;x86_64"

# Create an Android emulator
# RUN echo no | avdmanager create avd --name myEmulator --package "system-images;android-30;google_apis;x86_64"

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
# ENTRYPOINT ["/bin/sh"]