#!/bin/bash

# Pastikan skrip dijalankan sebagai root jika diperlukan untuk instalasi paket
if [ "$(id -u)" -ne 0 ]; then
    echo "Harap jalankan skrip ini sebagai root atau gunakan sudo untuk instalasi paket."
fi

# Update dan install dependensi
sudo apt-get update && sudo apt-get install -y \
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

# Buat direktori environment di $HOME/.local
mkdir -p $HOME/.local/sdk $HOME/.local/flutter $HOME/.local/nvm

# Set environment variables
export ANDROID_HOME=$HOME/.local/sdk
export ANDROID_SDK_ROOT=$HOME/.local/sdk
export FLUTTER_HOME=$HOME/.local/flutter
export NVM_DIR=$HOME/.local/nvm
export PATH="$HOME/.local/bin:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$NVM_DIR/versions/node/v22.14.0/bin:$PATH"

# Install Android SDK
mkdir -p $ANDROID_HOME/cmdline-tools && cd $ANDROID_HOME/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip
unzip cmdline-tools.zip && rm cmdline-tools.zip
mv cmdline-tools latest

# Install nvm, Node.js, dan npm
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install 22
nvm use 22
nvm alias default 22

# Install Firebase tools
npm install -g firebase-tools

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
cd $FLUTTER_HOME && flutter precache

# Accept Android licenses dan install komponen yang dibutuhkan
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Konfigurasi Flutter untuk Android SDK
flutter config --android-sdk $ANDROID_HOME

# Verifikasi instalasi Flutter
flutter doctor -v

# Tambahkan aturan udev untuk mendeteksi perangkat Android
sudo mkdir -p /etc/udev/rules.d
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules

echo "Setup Flutter selesai! Tambahkan berikut ini ke ~/.bashrc atau ~/.zshrc agar environment dikenali:"
echo "export PATH=\"$HOME/.local/bin:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$NVM_DIR/versions/node/v22.14.0/bin:$PATH\""

