# Top level control for managing the dev work

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_top  := $(dir $(mkfile_path))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

# ----- MACROS -----
MANTIDDIR := $(mkfile_top)/mantid
BUILDDIR  := $(mkfile_top)/build
INTALLDIR := $(mkfile_top)/opt/mantid
HOSTNAME  := $(shell hostname)
BASEOPTS  := -GNinja -DENABLE_MANTIDPLOT=OFF -DCMAKE_INSTALL_PREFIX=$(INTALLDIR)

# ----- BUILD OPTIONS -----
ifneq (,$(findstring analysis,$(HOSTNAME)))
	# on analysis cluster, need to turn off jemalloc for RHEL_7
	CMKOPTS := $(BASEOPTS) -DUSE_JEMALLOC=OFF
	CMKCMDS := cmake3 $(MANTIDDIR) $(CMKOPTS)
else
	CMKOPTS := $(BASEOPTS)
	CMKCMDS := cmake $(MANTIDDIR) $(CMKOPTS)
endif

# ----- Targets -----
.PHONY: all list clean

all:
	@echo Run everything

# initialize the workproject
init:
	@echo "deploying on host: ${HOSTNAME}"
	@echo "clone Mantid if not done already"
	@if [ ! -d "$(MANTIDDIR)" ]; then \
		git clone git@github.com:mantidproject/mantid.git; \
	fi
	@echo "make data directory, put testing data here"
	mkdir -p data
	@echo "config Mantid from scratch"
	mkdir -p ${BUILDDIR}
	mkdir -p ${INTALLDIR}
	@echo "running cmake"
	@cd ${BUILDDIR}; ${CMKCMDS}


# list all possible target in this makefile
list:
	@echo "LIST OF TARGETS:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	| sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs


# clean all tmp files
clean:
	@echo "Clean up workbench"
	rm  -fvr   *.tmp
	rm  -fvr   tmp_*
	rm  -fvr   build
	rm  -fvr   opt


# clean everything and archive the project
archive: clean
	rm  -fvr  mantid
