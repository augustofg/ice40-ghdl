TOP_LEVEL_ENT_SYNTH  = blinkled
TOP_LEVEL_ENT_SIMU   = blinkled_tb
SIMU_VCD_FILE        = blinkled_tb.vcd
SRC_DIR              = ./src/
TOP_LEVEL_FILE_SYNTH = $(SRC_DIR)/blinkled.vhd
TOP_LEVEL_FILE_SIMU  = $(SRC_DIR)/blinkled_tb.vhd
PINMAP_FILE          = $(SRC_DIR)/pinmap.pcf
GHDL_FLAGS           = --std=08
NEXTPNR_FLAGS        = --hx8k --package ct256 --pre-pack $(SRC_DIR)/constraints.py

.PHONY: all flash load simu

all: $(TOP_LEVEL_ENT_SYNTH).bin

flash: $(TOP_LEVEL_ENT_SYNTH).bin
	iceprog $<

load: $(TOP_LEVEL_ENT_SYNTH).bin
	iceprog -S $<

$(TOP_LEVEL_ENT_SYNTH).bin: $(TOP_LEVEL_ENT_SYNTH).asc
	icepack $< $@

$(TOP_LEVEL_ENT_SYNTH).asc: src/pinmap.pcf $(TOP_LEVEL_ENT_SYNTH).json
	nextpnr-ice40 $(NEXTPNR_FLAGS) --pcf $(PINMAP_FILE) --asc $@ --json $(TOP_LEVEL_ENT_SYNTH).json

$(TOP_LEVEL_ENT_SYNTH).json: $(TOP_LEVEL_ENT_SYNTH).o
	yosys -m ghdl -p 'ghdl $(GHDL_FLAGS) $(TOP_LEVEL_ENT_SYNTH); synth_ice40 -json $(@)'

$(TOP_LEVEL_ENT_SYNTH).o: $(TOP_LEVEL_FILE_SYNTH)
	ghdl -a $(GHDL_FLAGS) $<

$(TOP_LEVEL_ENT_SIMU).o: $(TOP_LEVEL_FILE_SIMU) $(TOP_LEVEL_ENT_SYNTH).o
	ghdl -a $(GHDL_FLAGS) $(TOP_LEVEL_FILE_SIMU)

$(TOP_LEVEL_ENT_SIMU): $(TOP_LEVEL_ENT_SIMU).o
	ghdl -e $(GHDL_FLAGS) $@

$(SIMU_VCD_FILE): $(TOP_LEVEL_ENT_SIMU)
	./$(TOP_LEVEL_ENT_SIMU) --vcd=$@

simu: $(SIMU_VCD_FILE)

clean:
	rm -f *.o $(TOP_LEVEL_ENT_SYNTH).json $(TOP_LEVEL_ENT_SYNTH).asc $(TOP_LEVEL_ENT_SYNTH).bin $(SIMU_VCD_FILE) $(TOP_LEVEL_ENT_SIMU) *.cf
