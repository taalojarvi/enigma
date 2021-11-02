#!/bin/bash

KERNEL_NAME="Enigma"
DATE=$(date +"%d-%m-%Y-%I-%M")
SHORTDATE=$(date +"%d-%m-%Y")
LOG_DIR=~/logs
LOG="Build"-$SHORTDATE
FINAL_ZIP=$KERNEL_NAME-$DATE.zip

if [ "$(cat /sys/devices/system/cpu/smt/active)" = "1" ]; then
                export THREADS=$(expr $(nproc --all) \* 2)
        else
                export THREADS=$(nproc --all)
        fi

## Funtions
# Clean Compile
function clean_compile() {
echo "---------------------------------------"
make O=out clean
echo "---------------------------------------"
make O=out mrproper
echo "---------------------------------------"
make O=out ARCH=arm64 enigma_defconfig
echo "---------------------------------------"

PATH="/home/thanuj/clang/bin:/home/thanuj/arm64-gcc/bin:/home/thanuj/arm-gcc/bin:${PATH}" \
make -j$THREADS O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android- \
                      CROSS_COMPILE_ARM32=arm-linux-androideabi-
echo "---------------------------------------"
}

# Dity Compile
function dirty_compile() {
echo "---------------------------------------"
make O=out ARCH=arm64 enigma_defconfig
echo "---------------------------------------"

PATH="/home/thanuj/clang/bin:/home/thanuj/arm64-gcc/bin:/home/thanuj/arm-gcc/bin:${PATH}"
make -j$THREADS O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android- \
                      CROSS_COMPILE_ARM32=arm-linux-androideabi-
echo "---------------------------------------"
}

# Regenerate defconfig
function regen() {
echo "---------------------------------------"
make O=out clean
echo "---------------------------------------"
make O=out mrproper
export ARCH=arm64
echo "---------------------------------------"
make enigma_defconfig
echo "Done!"
echo "---------------------------------------"
}

# Zip Kernel
function make_zip() {
cp /home/thanuj/sdm660/out/arch/arm64/boot/Image.gz-dtb /home/thanuj/sdm660/AnyKernel3/
cd && mkdir -p ENIGMA_BUILDS
cd /home/thanuj/sdm660/AnyKernel3/
zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
mv /home/thanuj/sdm660/AnyKernel3/UPDATE-AnyKernel2.zip /home/thanuj/ENIGMA_BUILDS/$FINAL_ZIP
echo "---------------------------------------"
}

# Clean Up
function cleanup(){
rm -rf /home/thanuj/sdm660/AnyKernel3/Image.gz-dtb
}

# Menu
function menu() {
echo "---------------------------------------"
echo -e "1. Dirty"
echo -e "2. Clean"
echo -e "3. Regenerate Defconfig"
echo -n "Choose :"
read choose

case $choose in
 1) dirty_compile | tee -a "$LOG_DIR"/"$LOG"
    make_zip | tee -a "$LOG_DIR"/"$LOG" ;;
 2) clean_compile | tee -a "$LOG_DIR"/"$LOG" 
    make_zip | tee -a "$LOG_DIR"/"$LOG" ;;
 3) regen | tee -a "$LOG_DIR"/"$LOG" ;;
esac
}


menu
cleanup
