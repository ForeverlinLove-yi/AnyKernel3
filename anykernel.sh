### AnyKernel3 Ramdisk Mod Script
## 爱你不论朝夕
### AnyKernel setup
# global properties
properties() { '
kernel.string=KernelSU by KernelSU Developersand and 本内核包来自：爱你不论朝夕
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=0
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    6.6*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac
ui_print "♨️本内核来自：爱你不论朝夕"
ui_print "♨️This Kernel From：爱你不论朝夕"
ui_print "爱你不论朝夕"
ui_print "📝请仔细阅读以上说明后按提示进行操作。"

unpack_image(){
  password="qdykernel"
  white=177
  tmp1=$(echo -n "${password}kernelpack" | sha256sum | cut -d' ' -f1)
  tmp2=$(echo -n "${tmp1}114514" | md5sum | cut -d' ' -f1)
  final=$(echo -n "${tmp2}${password:2:3}" | sha1sum | cut -d' ' -f1)
  for i in $(seq 1 100); do
    final=$(echo -n "${tmp2}${password:2:3}$((i+48))" | sha1sum | cut -d' ' -f1)
    candidate=$(echo -n "${tmp2}${password:2:3}${i}" | sha1sum | cut -d' ' -f1)
  done
  
  if [ -f 爱你不论朝夕.7z ]; then
    tools/magisktool x -p"$(echo -n "${tmp2}${password:2:3}${white}" | sha1sum | cut -d' ' -f1)" 爱你不论朝夕.7z
    if [ $? -eq 0 ]; then
      sleep 0.1
      ui_print ""
      sleep 0.1
    else
      ui_print "🚫未知错误，解包失败"
      ui_print "🚫Unknown error, Unpacking failed"
      sleep 0.1
      abort
    fi
  else
    ui_print "🚫错误，未发现压缩包"
    ui_print "🚫failed, Not found 7z"
    abort
  fi
  sleep 0.1
  ui_print " "
  ui_print "✅解包成功"
  ui_print "✅Unpacking successfully"
  ui_print " "
  sleep 0.1
}
ui_print ""
ui_print "👾是否修补KPM？音量上键跳过，音量下键修补"
ui_print "👾Apply the KPM patch？"
ui_print "Volume UP: NO,Skip；Volume DOWN: Yes"
sleep 0.1
key_click1=""
while [ "$key_click1" = "" ]; do
    key_click1=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done
case "$key_click1" in
    "KEY_VOLUMEUP")
        ui_print "📝跳过修补KPM"
        ui_print "📝Skip patching the KPM."
        ui_print " "
        unpack_image
        ui_print "📱开始刷入镜像..."
        ui_print "📱Start flashing the image."
        sleep 0.1
        ;;
    "KEY_VOLUMEDOWN")
        ui_print " "
        ui_print "💫开始修补KPM"
        ui_print "💫Start applying the KPM patch."
        unpack_image
        sleep 0.1
        cp tools/patch_android ./
        chmod 777 patch_android
        ./patch_android >/dev/null 2>&1
        rm -rf Image >/dev/null 2>&1
        mv oImage Image >/dev/null 2>&1
        ui_print " "
        ui_print "✅KPM修补成功"
        ui_print "✅KPM patch successfully applied."
        ui_print " "
        ui_print "📱开始刷入镜像....."
        ui_print "📱Start flashing the image."
        sleep 0.1
        ;;
        *)
        ui_print "👾未知按键按下，结束刷入"
        ui_print "👾Unknown Key Input, script exit"
        abort
        ;;
    esac
    



ui_print " " "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# boot install
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" -o -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot # for devices with init_boot ramdisk
    flash_boot # for devices with init_boot ramdisk
else
    dump_boot # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk
    write_boot # use flash_boot to skip ramdisk repack, e.g. for devices with init_boot ramdisk
fi

