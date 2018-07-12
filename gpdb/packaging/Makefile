all: gppkg


PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLD_ARCH)))
ARCH=$(shell uname -p)

JRE_VER=1.8.0_172
JRE_REL=1
JRE_DIR=/opt/jre$(JRE_VER)
JRE_RPM_FLAGS="--define 'jre_dir $(JRE_DIR)' --define 'jre_ver $(JRE_VER)' --define 'jre_rel $(JRE_REL)'" 
JRE_RPM=jre-$(JRE_VER)-$(JRE_REL).$(ARCH).rpm

PLJAVA_DIR=$(shell cd ../.. && pwd)
include $(PLJAVA_DIR)/release.mk

include gppkg.mk

PLJAVA_GPPKG_VER=ossv1.4.0_pv1.3_gpdb4.3orca

GPPKG_VERSION=$(PLJAVA_GPPKG_VER)
PLJAVA_RPM_FLAGS="--define 'pljava_dir $(PLJAVA_DIR)' --define 'pljava_ver $(PLJAVA_PIVOTAL_VERSION)' --define 'pljava_rel $(PLJAVA_PIVOTAL_RELEASE)' --define 'jre_ver $(JRE_VER)'"
PLJAVA_RPM=pljava-$(PLJAVA_PIVOTAL_VERSION)-$(PLJAVA_PIVOTAL_RELEASE).$(ARCH).rpm
PLJAVA_GPPKG=pljava-$(PLJAVA_GPPKG_VER)-$(OS)-$(ARCH).gppkg

TARGET_GPPKG=$(PLJAVA_GPPKG)
EXTRA_CLEAN+=$(JRE_RPM) $(PLJAVA_RPM) $(PLJAVA_GPPKG)

#
# Generic rules to build gppkgs included here
#

.PHONY: gppkg
gppkg: clean
	$(MAKE) $(JRE_RPM) RPM_FLAGS=$(JRE_RPM_FLAGS)
	PATH=$(GPHOME)/bin:$(PATH) $(MAKE) $(PLJAVA_RPM) RPM_FLAGS=$(PLJAVA_RPM_FLAGS)
	$(MAKE) $(PLJAVA_GPPKG) MAIN_RPM=$(PLJAVA_RPM) DEPENDENT_RPMS=$(JRE_RPM)

.PHONY: cleanall
cleanall: clean
	rm -rf BUILDROOT
	rm -rf SOURCES
	rm -rf SRPMS
	rm -rf $(JRE_RPM)
	rm -rf $(PLJAVA_RPM)
	rm -rf $(PLJAVA_GPPKG)

