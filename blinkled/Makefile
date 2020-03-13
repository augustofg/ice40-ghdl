all: blinkled.bin

blinkled.bin: blinkled.asc
	icepack $< $@

blinkled.asc: src/pinmap.pcf blinkled.json
	nextpnr-ice40 --hx8k --package ct256 --pcf src/pinmap.pcf --asc $@ --json blinkled.json

blinkled.json: blinkled.o
	yosys -m ghdl -p 'ghdl blinkled; synth_ice40 -json blinkled.json'

blinkled.o: src/blinkled.vhd
	ghdl -a $<
