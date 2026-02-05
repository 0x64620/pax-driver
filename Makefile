MODULE=ttyPos
KERNEL_VER:=$(shell uname -r)
KERNEL_DIR:=/lib/modules/$(KERNEL_VER)/build
OUT_DIR:=$(CURDIR)/out
INSTALL_DIR:=/lib/modules/$(KERNEL_VER)/extra

KBUILD_CFLAGS1:=$(call cc-option,-Wno-error=implicit-function-declaration,)
KBUILD_CFLAGS2:=$(call cc-option,-Wno-error=incompatible-pointer-types,)
KBUILD_CFLAGS+=$(KBUILD_CFLAGS1)
KBUILD_CFLAGS+=$(KBUILD_CFLAGS2)
obj-m := $(MODULE).o

.PHONY: all clean install uninstall load unload reload info logs status

all: $(OUT_DIR)
	$(MAKE) -C $(KERNEL_DIR) M=$(CURDIR) MO=$(OUT_DIR) modules

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

clean:
	$(RM) -r $(OUT_DIR)
	$(RM) *.o *.ko *.mod *.mod.* .*.o .*.ko .*.mod .*.mod.* .*.cmd *~
	$(RM) -r .tmp_versions
	$(RM) *.order *.symvers

install: all
	install -D -m 644 $(OUT_DIR)/$(MODULE).ko $(INSTALL_DIR)/$(MODULE).ko
	/sbin/depmod -a

uninstall:
	modprobe -r $(MODULE) ; echo -n
	$(RM) $(INSTALL_DIR)/$(MODULE).ko
	/sbin/depmod -a

load: install
	modprobe $(MODULE)

unload:
	modprobe -r $(MODULE)

reload:
	-$(MAKE) unload
	$(MAKE) load

info:
	modinfo $(OUT_DIR)/$(MODULE).ko

logs:
	journalctl -k -n 100 --no-pager | grep -Ei "$(MODULE)|pos_tty|2fb8|110b|3890|0101" || true

status:
	lsmod | grep -i $(MODULE) || true
