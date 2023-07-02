#Derived from: https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh
#Author: Marcel L
#Author Email: pwd9000@hotmail.co.uk
#Modified by Phil Dieppa
#Modification Email: pdieppa3@gatech.edu

# base image
# FROM alpine:latest
FROM ubuntu:20.04

#input GitHub runner version argument
ARG RUNNER_VERSION=2.299.2
ENV MAVEN_VERSION=3.9.3
ENV GRADLE_VERSION=7.5
ENV ANDROID_SDK_ROOT="/usr/lib/android-sdk"
ENV DEBIAN_FRONTEND=noninteractive

LABEL Author="Phil Dieppa"
LABEL Email="pdieppa3@gatech.edu"
LABEL GitHub="https://github.gatech.edu/pdieppa3"
LABEL BaseImage="ubuntu:20.04"
LABEL RunnerVersion=${RUNNER_VERSION}

# update the base packages
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl nodejs wget unzip vim git azure-cli jq build-essential libssl-dev libffi-dev

RUN apt-get install -y --no-install-recommends \
    python3 python3-venv python3-dev python3-pip zip openjdk-17-jdk android-sdk pandoc texlive \
    texlive-xetex lmodern sudo 

# cd into the directory, download and unzip the github actions runner
RUN mkdir /actions-runner && cd /actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# add over the start.sh script
ADD scripts/start.sh start.sh

# add maven setup script
ADD scripts/maven.sh /etc/profile.d/maven.sh

# make the scripts executable
RUN chmod +x /etc/profile.d/maven.sh && \
    chmod +x ./start.sh

# install some additional dependencies
RUN /actions-runner/bin/installdependencies.sh

#Install maven
RUN curl -O -L https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar xzf ./apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm ./apache*

#Download Gradle and unzip it in /opt
RUN curl -o gradle.zip -O -L https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip gradle.zip -d /opt \
    && rm gradle.zip

# Install Android SDK Command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && curl -o android.zip -O -L https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip \
    && unzip android.zip -d ${ANDROID_SDK_ROOT} \
    && rm android.zip

RUN cd ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv bin/ latest/ \
    && mv lib/ latest/ \
    && mv NOTICE.txt latest/ \
    && mv source.properties latest/

#Load Maven
RUN . /etc/profile.d/maven.sh

# Set Gradle in the PATH, but after maven since maven also comes with an older version of gradle.
ENV PATH /opt/gradle-${GRADLE_VERSION}/bin:$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

# Load Maven and Accept Android SDK licenses and install additional packages
RUN . /etc/profile.d/maven.sh && \
    yes | sdkmanager --licenses && \
    yes | sdkmanager "platforms;android-31" "build-tools;30.0.3" "emulator" "patcher;v4" "platform-tools" "tools" && \
    yes | sdkmanager --licenses

# set the entrypoint to the start.sh script
ENTRYPOINT ["./start.sh"]
