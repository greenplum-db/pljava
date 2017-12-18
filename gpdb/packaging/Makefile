all: gppkg


PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLD_ARCH)))
ARCH=$(shell uname -p)

PLJAVA_DIR=$(shell cd ../.. && pwd)
include $(PLJAVA_DIR)/release.mk

include gppkg.mk

PLJAVA_GPPKG_VER=$(PLJAVA_PIVOTAL_VERSION).$(PLJAVA_PIVOTAL_RELEASE)-gp$(GP_VERSION_NUM)

GPPKG_VERSION=$(PLJAVA_GPPKG_VER)
PLJAVA_RPM_FLAGS="--define 'pljava_dir $(PLJAVA_DIR)' --define 'pljava_ver $(PLJAVA_PIVOTAL_VERSION)' --define 'pljava_rel $(PLJAVA_PIVOTAL_RELEASE)'"
PLJAVA_RPM=pljava-$(PLJAVA_PIVOTAL_VERSION)-$(PLJAVA_PIVOTAL_RELEASE).$(ARCH).rpm
PLJAVA_GPPKG=pljava-$(PLJAVA_GPPKG_VER)-$(OS)-$(ARCH).gppkg

TARGET_GPPKG=$(PLJAVA_GPPKG)
EXTRA_CLEAN+=$(PLJAVA_RPM) $(PLJAVA_GPPKG)

#
# Generic rules to build gppkgs included here
#

.PHONY: gppkg
gppkg: clean
	$(MAKE) $(PLJAVA_RPM) RPM_FLAGS=$(PLJAVA_RPM_FLAGS)
	$(MAKE) $(PLJAVA_GPPKG) MAIN_RPM=$(PLJAVA_RPM)

.PHONY: cleanall
cleanall: clean
	rm -rf BUILDROOT
	rm -rf SOURCES
	rm -rf SRPMS
	rm -rf $(PLJAVA_RPM)
	rm -rf $(PLJAVA_GPPKG)
