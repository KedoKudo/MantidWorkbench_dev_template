# Top level control for managing the dev work


# ----- Targets -----
.PHONY: all list clean

all:
	@echo Run everything


# initialize the workproject
init:
	@echo "Clone Mantid source into the project directory"
	git clone git@github.com:mantidproject/mantid.git


# list all possible target in this makefile
list:
	@echo "LIST OF TARGETS:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
	| sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs


# clean all tmp files
clean:
	@echo "Clean up workbench"
	rm  -fv   *.tmp
	rm  -fv   tmp_*