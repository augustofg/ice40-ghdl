TOP_LEVEL_ENT_SYNTH  = uart_top
TOP_LEVEL_ENT_SIMU   = uart_tb
SIMU_GHW_FILE        = uart_tb.ghw
SRC_DIR              = ./src/
TOP_LEVEL_FILE_SYNTH = $(SRC_DIR)/uart_demo.vhd
TOP_LEVEL_FILE_SIMU  = $(SRC_DIR)/uart_tb.vhd
PINMAP_FILE          = $(SRC_DIR)/pinmap.pcf
GHDL_FLAGS           = --std=08
NEXTPNR_FLAGS        = --hx8k --package ct256

.PHONY: all flash load simu

all: $(TOP_LEVEL_ENT_SYNTH).bin

flash: $(TOP_LEVEL_ENT_SYNTH).bin
	iceprog $<

load: $(TOP_LEVEL_ENT_SYNTH).bin
	iceprog -S $<

$(TOP_LEVEL_ENT_SYNTH).bin: $(TOP_LEVEL_ENT_SYNTH).asc
	icepack $< $@

$(TOP_LEVEL_ENT_SYNTH).asc: $(SRC_DIR)/pinmap.pcf $(TOP_LEVEL_ENT_SYNTH).json $(SRC_DIR)/constraints.py
	nextpnr-ice40 $(NEXTPNR_FLAGS) --pcf $< --asc $@ --json $(word 2,$^)  --pre-pack $(word 3,$^)

$(TOP_LEVEL_ENT_SYNTH).json: $(TOP_LEVEL_ENT_SYNTH).o uart.o
	yosys -m ghdl -p 'ghdl $(GHDL_FLAGS) $(TOP_LEVEL_ENT_SYNTH); synth_ice40 -json $(@)'

$(SIMU_GHW_FILE): $(TOP_LEVEL_ENT_SIMU)
	./$(TOP_LEVEL_ENT_SIMU) --wave=$@

simu: $(SIMU_GHW_FILE)

$(TOP_LEVEL_ENT_SIMU): $(TOP_LEVEL_ENT_SIMU).o
	ghdl -e $(GHDL_FLAGS) $@

$(TOP_LEVEL_ENT_SIMU).o: $(SRC_DIR)/$(TOP_LEVEL_ENT_SIMU).vhd uart.o
	ghdl -a $(GHDL_FLAGS) $<

$(TOP_LEVEL_ENT_SYNTH).o: $(SRC_DIR)/$(TOP_LEVEL_ENT_SYNTH).vhd uart.o
	ghdl -a $(GHDL_FLAGS) $<

uart.o: $(SRC_DIR)/uart.vhd
	ghdl -a $(GHDL_FLAGS) $<

clean:
	rm -f *.o $(TOP_LEVEL_ENT_SYNTH).json $(TOP_LEVEL_ENT_SYNTH).asc $(TOP_LEVEL_ENT_SYNTH).bin $(SIMU_GHW_FILE) $(TOP_LEVEL_ENT_SIMU) *.cf
