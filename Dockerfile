# FROM openjdk:8-alpine
FROM openjdk:13-alpine3.9
ENV BUILD_TOOLS "30.0.2"
ENV SDK_TOOLS_API "31"
ENV ANDROID_HOME "/opt/sdk"
ENV GLIBC_VERSION "2.35-r0"

# Install required dependencies
# RUN apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash && \
#     wget https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
#     wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk && \
#     wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk && \
#     apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
#     rm -rf /tmp/*

RUN apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash git py-pip && \
    wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk && \
    apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
    pip install --upgrade pip && \
    pip install grip && \
    rm -rf /tmp/*

# Download Android SDK tools
# RUN wget http://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O /tmp/tools.zip && \
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -O /tmp/tools.zip && \
    mkdir -p ${ANDROID_HOME} && \
    unzip /tmp/tools.zip -d ${ANDROID_HOME}
RUN mkdir -p ${ANDROID_HOME}/tools && \
    mv ${ANDROID_HOME}/cmdline-tools/* ${ANDROID_HOME}/tools/ && \
    mv ${ANDROID_HOME}/tools ${ANDROID_HOME}/cmdline-tools/ && \
    rm -v /tmp/tools.zip
# Install Android packages & libraries
RUN export PATH=$PATH:$ANDROID_HOME/cmdline-tools/tools/bin && \
    mkdir -p /root/.android/ && touch /root/.android/repositories.cfg

RUN yes | $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "--licenses" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager --verbose "build-tools;${BUILD_TOOLS}" "platform-tools" "platforms;android-${SDK_TOOLS_API}" \
    && $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager --verbose "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"
# Install pip for grip export README.md to html
# RUN apk add  --update --no-cache py-pip \
#     && pip install --upgrade pip \
#     && pip install grip

# RUN pip install --upgrade pip

# Install git
# RUN apk add --no-cache git
# Install application dependencies
WORKDIR /app
# COPY . /app
# RUN tree .
# RUN ./android/gradlew bundleRelease \
#     # && ./android/gradlew testDebugUnitTest \
#     && ./android/gradlew clean