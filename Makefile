ROOT     := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

NR_CORES := 20

# linux image
buildroot_defconfig = configs/buildroot_defconfig
linux_defconfig = configs/linux_defconfig
busybox_defconfig = configs/busybox.config

Image: $(buildroot_defconfig) $(linux_defconfig) $(busybox_defconfig) rootfs
	make -C buildroot defconfig BR2_DEFCONFIG=../$(buildroot_defconfig)
	make -C buildroot -j$(NR_CORES)
	cp buildroot/output/images/Image Image

fw_payload.bin: Image
	PATH=$(PATH):$(PWD)/buildroot/output/host/bin ARCH=riscv CROSS_COMPILE=riscv64-linux- make -C opensbi PLATFORM=fpga/openpiton FW_PAYLOAD_PATH=../Image -j$(NR_CORES)
	cp opensbi/build/platform/fpga/openpiton/firmware/fw_payload.bin fw_payload.bin

clean:
	rm -rf Image
	make -C buildroot distclean
	make -C opensbi distclean

help:
	@echo "usage: $(MAKE) [tool/img] ..."
	@echo ""
	@echo "build linux images for ariane"
	@echo "    build linux Image with"
	@echo "        make Image"
	@echo "    build opensbi fw_payload.bin (with Image) with"
	@echo "        make fw_payload.bin"
	@echo ""
	@echo "There is one clean target:"
	@echo "        make clean"
