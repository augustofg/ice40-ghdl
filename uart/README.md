# UART example

Reads and writes to the FTDI's serial interface, 9600bps. Characters a-z and A-Z will be transmited back with cases reversed ('a' will become 'A', 'B' will become 'b').  The binary representation of the last character received is displayed though the LEDs.

## Instructions

To run the simulation test bench for the uart module just invoke `make simu`:
```
$ make simu
$ gtkwave uart_tb.vcd
```

To synthesize and build the bitstream invoke `make`. You can load the bitstream into the FPGA's SRAM by connecting the ice40-hx8k board USB and running `make load`:
```
$ make
$ make load
```
