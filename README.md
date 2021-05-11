# VHDL examples targeting the ICE40-HX8K development board using Yosys + GHDL + nextpnr

## Requirements
- GNU Make
- gtkwave (to see simulation results)
- [yosys](https://github.com/YosysHQ/yosys)
- [ghdl](https://github.com/ghdl/ghdl) (gcc or llvm backends, mcode won't work)
- [ghdl-yosys-plugin](https://github.com/ghdl/ghdl-yosys-plugin)
- [nextpnr](https://github.com/YosysHQ/nextpnr)
- [icestorm](https://github.com/YosysHQ/icestorm)

Is recommended to install `yosys`, `ghdl`, `ghdl-yosys-plugin`, `nextpnr` `icestorm` from source since most distributions don't include those in their main repositories or include outdated versions that might not work with the provided Makefiles.
