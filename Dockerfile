FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip xz-utils zip \
    && rm -rf /var/lib/apt/lists/*

# Note: Flutter version must match with pubspec.yaml
RUN git clone --depth 1 --branch 3.44.8 https://github.com/flutter/flutter.git /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"

RUN flutter --version && flutter config --no-analytics && flutter precache --web
