# Blinking LED example

## Instructions

To run the simulation test bench just invoke `make simu`:
```
$ make simu
$ gtkwave blinkled_tb.ghw
```

To synthesize and build the bitstream invoke `make`. You can load the bitstream into the FPGA's SRAM by connecting the ice40-hx8k board USB and running `make load`:
```
$ make
$ make load
```
