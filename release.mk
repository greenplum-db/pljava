PLJAVA_OSS_VERSION = 1.5.0

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(dir $(mkfile_path))
PLJAVA_PIVOTAL_VERSION = $(shell cat $(current_dir)VERSION)

PLJAVA_PIVOTAL_RELEASE = 0
