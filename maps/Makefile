# Compiler and flags
QBSP=qbsp -nolog -nocolor -leaktest -filldetail -litwater -nopercent
VIS=vis -noambient -nolog -nocolor -nopercent
LIGHT=light -bounce 1 -dirt -extra4 -lit -lightgrid -lightgrid_dist 32 32 32 -nolog -nocolor -nopercent

# Directories
SRC_DIR = maps/src
BUILD_DIR = maps

# Find all .map files
SOURCES := $(wildcard src/*.map)
MAP_NAMES := $(basename $(notdir $(SOURCES)))
BSPS := $(patsubst src/%.map, %.bsp, $(SOURCES))

.PHONY: all clean

all: $(BSPS)

prefabs.bsp:
	: do nothing fo $@

%.bsp: src/%.map
	echo $@
	echo $<
	$(QBSP) $< $@
	$(VIS) $@
	$(LIGHT) $@
