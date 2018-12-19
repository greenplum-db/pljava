# need VARS: OS ARCH PLJAVA_DIR PLJAVA_GPPKG
# ???: where is GP_MAJORVERSION
PGXS := $(shell pg_config --pgxs)
include $(PGXS)
include $(PLJAVA_DIR)/release.mk
GP_VERSION_NUM := $(GP_MAJORVERSION)

PLJAVA_RPM_FLAGS=--define 'pljava_dir $(PLJAVA_DIR)' --define 'pljava_ver $(PLJAVA_PIVOTAL_VERSION)' --define 'pljava_rel $(PLJAVA_PIVOTAL_RELEASE)'
PLJAVA_RPM=pljava-$(PLJAVA_PIVOTAL_VERSION)-$(PLJAVA_PIVOTAL_RELEASE).$(ARCH).rpm
SPEC_NAME=pljava.spec
TARGET_GPPKG=$(PLJAVA_GPPKG)
PWD=$(shell pwd)

.PHONY: distro
distro: $(TARGET_GPPKG)

%.rpm: 
	rm -rf RPMS BUILD SPECS
	mkdir RPMS BUILD SPECS
	cp $(SPEC_NAME) SPECS/
	rpmbuild -bb SPECS/$(SPEC_NAME) --buildroot $(PWD)/BUILD --define '_topdir $(PWD)' --define '__os_install_post \%{nil}' --define 'buildarch $(ARCH)' $(PLJAVA_RPM_FLAGS)
	mv RPMS/$(ARCH)/$*.rpm .
	rm -rf RPMS BUILD SPECS

gppkg_spec.yml: gppkg_spec.yml.in
	cat $< | sed "s/#arch/$(ARCH)/g" | sed "s/#os/$(OS)/g" | sed 's/#gpver/$(GP_VERSION_NUM)/g' | sed "s/#gppkgver/$(PLJAVA_PIVOTAL_VERSION)/g"> $@ > $@

%.gppkg: $(PLJAVA_RPM) gppkg_spec.yml $(PLJAVA_RPM) $(DEPENDENT_RPMS)
	rm -rf gppkg
	mkdir -p gppkg/deps 
	cp gppkg_spec.yml gppkg/
	cp $(PLJAVA_RPM) gppkg/ 
ifdef DEPENDENT_RPMS
	for dep_rpm in $(DEPENDENT_RPMS); do \
		cp $${dep_rpm} gppkg/deps; \
	done
endif
	gppkg --build gppkg 

clean:
	rm -rf RPMS BUILD SPECS
	rm -rf gppkg
	rm -f gppkg_spec.yml
	rm -rf BUILDROOT
	rm -rf SOURCES
	rm -rf SRPMS
	rm -rf $(PLJAVA_RPM)
	rm -rf $(TARGET_GPPKG)
ifdef EXTRA_CLEAN
	rm -rf $(EXTRA_CLEAN)
endif

install: $(TARGET_GPPKG)
	gppkg -i $(TARGET_GPPKG)

.PHONY: install clean
