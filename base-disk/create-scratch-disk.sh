#! /usr/bin/env bash

# Check arguments are present
[ $# -eq 0 ] && {
    echo "ERROR: Arguments missing."
    exit 1
}


# Process arguments
OPTSTRING=":d:"
while getopts ${OPTSTRING} OPT; do
  case ${OPT} in
    d)
      TARGET_DISK="${OPTARG}.img"
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    \?)
      echo "Invalid option: -${OPTARG}"
      exit 1
      ;;
  esac
done


# Check image file does not exist and create
if [ ! -f "${TARGET_DISK}" ]; then
    dd if=/dev/zero of="${TARGET_DISK}" bs=1M count=2048
else
    echo "Image ${TARGET_DISK} already exists."
    exit 1
fi

# Create partitions
sfdisk debian-scratch.img <<EOF
label: gpt
label-id: 96FB8779-1172-4C01-A0DC-6048AB5CB0F2
device: debian-scratch.img
unit: sectors
first-lba: 2048
last-lba: 4194270
sector-size: 512

debian-scratch.img1 : start=        2048, size=      524288, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
debian-scratch.img2 : start=      526336, size=     3665920, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
EOF

# Create filesystems
mkfs.vfat -F 32 -I -n EFI --offset=2048 "${TARGET_DISK}" $((256*1024))
mkfs.ext4 -L ROOT -E offset=$((257*1024*1024)) "${TARGET_DISK}" 1790M

