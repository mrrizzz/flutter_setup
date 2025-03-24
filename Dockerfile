FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    openjdk-17-jdk \
    wget \
    libgl1-mesa-dev \
    cmake \
    ninja-build \
    clang \
    pkg-config \
    libgtk-3-dev \
    udev

# Set environment variables
ENV ANDROID_HOME=/sdk
ENV ANDROID_SDK_ROOT=/sdk
ENV FLUTTER_HOME=/flutter
ENV PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# Install Android SDK
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mv cmdline-tools latest

# Download and install nvm, Node.js, and npm
ENV NVM_DIR=/root/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install 22 && \
    nvm use 22 && \
    nvm alias default 22

# Add node and npm to PATH
ENV PATH="$NVM_DIR/versions/node/v22.14.0/bin:$PATH"

# Install Firebase tools
RUN npm install -g firebase-tools

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    flutter precache

# Accept Android licenses and install required components
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses && \
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Tell Flutter where the Android SDK is located
RUN flutter config --android-sdk $ANDROID_HOME

# Run flutter doctor to verify installation
RUN flutter doctor -v

# Add Android USB rules for device detection
RUN mkdir -p /etc/udev/rules.d && \
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' > /etc/udev/rules.d/51-android.rules && \
    chmod a+r /etc/udev/rules.d/51-android.rules

# Expose ports (if needed)
EXPOSE 8000

# Set work directory
WORKDIR /app

CMD ["bash"]