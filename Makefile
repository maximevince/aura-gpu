# For building for the current running version of Linux
ifndef TARGET
TARGET = $(shell uname -r)
endif
# Or specific version
#TARGET = 2.6.33.5

CONFIG_MODULE_SIG=n
CONFIG_STACK_VALIDATION=n
DRIVER = aura-gpu

SRCS = \
	asic/asic-polaris.c \
	asic/asic-vega.c \
	asic/asic-navi.c \
	atom/atom.c \
	aura-gpu-reg.c \
	aura-gpu-i2c.c \
	aura-gpu-bios.c \
	aura-gpu-hw.c \
	main.c

KERNEL_MODULES = /lib/modules/$(TARGET)

ifneq ("","$(wildcard /usr/src/linux-headers-$(TARGET)/*)")
	# Ubuntu
	KERNEL_BUILD = /usr/src/linux-headers-$(TARGET)
else
	ifneq ("","$(wildcard /usr/src/kernels/$(TARGET)/*)")
		# Fedora
		KERNEL_BUILD = /usr/src/kernels/$(TARGET)
	else
		KERNEL_BUILD = $(KERNEL_MODULES)/build
	endif
endif

ifneq ("","$(wildcard .git/*)")
	DRIVER_VERSION := $(shell echo "$(shell git rev-list --count HEAD).$(shell git rev-parse --short HEAD)")
else
	ifneq ("", "$(wildcard VERSION)")
		DRIVER_VERSION := $(shell cat VERSION)
	else
		DRIVER_VERSION := unknown
	endif
endif

# DKMS
DKMS_ROOT_PATH=/usr/src/$(DRIVER)-$(DRIVER_VERSION)
MODPROBE_OUTPUT=$(shell lsmod | grep ${DRIVER})

# Directory below /lib/modules/$(TARGET)/kernel into which to install
# the module:
MOD_SUBDIR = drivers/hwmon
MODDESTDIR=$(KERNEL_MODULES)/kernel/$(MOD_SUBDIR)

OBJS = $(SRCS:.c=.o)

all: modules

modules:
	@$(MAKE) EXTRA_CFLAGS="-I$(CURDIR)/" -C $(KERNEL_BUILD) M=$(CURDIR) $@

clean:
	@$(MAKE) -C $(KERNEL_BUILD) M=$(CURDIR) $@

dkms:
	@sed -i -e '/^PACKAGE_VERSION=/ s/=.*/=\"$(DRIVER_VERSION)\"/' dkms.conf
	@echo "$(DRIVER_VERSION)" >VERSION
	@mkdir -p $(DKMS_ROOT_PATH)
	@cp `pwd`/dkms.conf $(DKMS_ROOT_PATH)
	@cp `pwd`/VERSION $(DKMS_ROOT_PATH)
	@cp `pwd`/Makefile $(DKMS_ROOT_PATH)
	@cp ${SRCS} $(DKMS_ROOT_PATH)

	dkms add -m $(DRIVER) -v $(DRIVER_VERSION)
	dkms build -m $(DRIVER) -v $(DRIVER_VERSION) --kernelsourcedir=$(KERNEL_BUILD)
	dkms install --force -m $(DRIVER) -v $(DRIVER_VERSION)
	@modprobe $(DRIVER)

dkms_clean:
	@if [ ! -z "$(MODPROBE_OUTPUT)" ]; then \
		rmmod $(DRIVER);\
	fi
	@dkms remove -m $(DRIVER) -v $(DRIVER_VERSION) --all
	@rm -rf $(DKMS_ROOT_PATH)

apa:
	@echo ${DRIVER_VERSION}

.PHONY: all clean modules dkms dkms_clean apa
