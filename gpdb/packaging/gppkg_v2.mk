# need VARS: OS ARCH PLJAVA_DIR PLJAVA_GPPKG
# GP_MAJORVERSION is defined in lib/postgresql/pgxs/src/Makefile.global
GP_VERSION_NUM := $(GP_MAJORVERSION)

PWD=$(shell pwd)
TARGET_GPPKG=$(PLJAVA_GPPKG)
ifeq ($(GPPKG),)
GPPKG=gppkg
endif

.PHONY: distro
distro: $(TARGET_GPPKG)

gppkg_spec_v2.yml: gppkg_spec_v2.yml.in
	cat $< | sed "s/#arch/$(ARCH)/g" | sed "s/#os/$(OS)/g" | sed 's/#gpver/$(GP_VERSION_NUM)/g' | sed "s/#gppkgver/$(PLJAVA_PIVOTAL_VERSION)/g" > $@

%.gppkg: gppkg_spec_v2.yml
	rm -rf gppkg_build 2>/dev/null
	mkdir -p gppkg_build/files
	$(MAKE) -C $(PLJAVA_DIR) install \
		DESTDIR=$(PWD)/gppkg_build/files \
		libdir=/lib/postgresql \
		pkglibdir=/lib/postgresql \
		datadir=/share/postgresql \
		gpetcdir=/etc
	$(GPPKG) build \
		--input $(PWD)/gppkg_build/files \
		--config gppkg_spec_v2.yml \
		--output $(TARGET_GPPKG)

clean:
	rm -rf gppkg_build
	rm -f gppkg_spec_v2.yml
	rm -f $(TARGET_GPPKG)

install: $(TARGET_GPPKG)
	$(GPPKG) install -a $(TARGET_GPPKG)

.PHONY: install clean
