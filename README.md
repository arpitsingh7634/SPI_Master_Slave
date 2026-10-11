# SPI Master–Slave Interface in Verilog (Basys 3 FPGA)

An 8-bit SPI (Serial Peripheral Interface) master and slave written in Verilog HDL, connected in a loopback configuration and implemented on the **Digilent Basys 3** (Xilinx Artix-7 XC7A35T) board. The master serializes an 8-bit value from the on-board switches, and the slave reassembles it and shows it on the LEDs.

## Features

- 8-bit SPI master with FSM control (IDLE → LOAD → SHIFT → DONE)
- SPI **Mode 0** (CPOL = 0, CPHA = 0)
- **MSB-first** transmission
- Parameterized data width (`DATA_WIDTH`) and clock divider (`CLK_DIV`)
- Slave clocked directly by `spi_clk`, with `cs` acting as an asynchronous reset for its bit counter
- Top-level wrapper with ready-to-use Basys 3 constraints (`.xdc`)
- Self-checking testbench that verifies MSB-first ordering

## How it works

```
                 +----------------------------------------------+
                 |                   spi_top                    |
 parallel_data ->|  +-------------+   spi_cs     +-----------+  |-> received_data
 data_valid  --->|  |  spi_master | -----------> | spi_slave |  |-> received_valid
 clk, rst_n  --->|  |             |   spi_clk    |           |  |
                 |  |             | -----------> |           |  |
                 |  |             |   spi_mosi   |           |  |
                 |  |             | -----------> |           |  |
                 |  +-------------+              +-----------+  |
                 +----------------------------------------------+
```

### Master FSM

| State | Action |
|-------|--------|
| `IDLE`  | CS high, SPI clock disabled. Waits for `data_valid`. |
| `LOAD`  | Pulls CS low, latches `parallel_data`, places the MSB on MOSI, enables the SPI clock. |
| `SHIFT` | On each falling edge of `spi_clk`, outputs the next lower bit. |
| `DONE`  | Releases CS, stops the SPI clock, returns to `IDLE`. |

### Timing (SPI Mode 0)

- `spi_clk` idles low.
- MOSI changes on the **falling** edge.
- The slave samples MOSI on the **rising** edge.
- With `CLK_DIV = 4` and a 100 MHz system clock, `spi_clk` toggles every 4 system clocks. The SPI clock period is 8 system clocks, which gives **12.5 MHz** (80 ns period).

## Repository structure

```
.
├── src/
│   ├── spi_top.v          # Top-level: connects master and slave
│   ├── spi_master.v       # SPI master (FSM + clock divider + shift logic)
│   └── spi_slave.v        # SPI slave (shift register + valid flag)
├── sim/
│   └── tb_msb.v           # Self-checking testbench (MSB-first check)
├── constraints/
│   └── basys3.xdc         # Pin assignments for Basys 3
└── README.md
```

> Adjust the paths above to match your actual repository layout.

## Port description

### `spi_top`

| Port | Dir | Width | Description |
|------|-----|-------|-------------|
| `clk` | in | 1 | 100 MHz system clock |
| `rst_n` | in | 1 | Active-low reset |
| `parallel_data` | in | 8 | Byte to transmit |
| `data_valid` | in | 1 | Start a transfer |
| `received_data` | out | 8 | Byte received by the slave |
| `received_valid` | out | 1 | One-pulse flag when a byte is complete |

### Parameters (`spi_master`)

| Parameter | Default | Meaning |
|-----------|---------|---------|
| `DATA_WIDTH` | 8 | Number of bits per transfer |
| `CLK_DIV` | 4 | System clocks per half SPI clock period |

SPI clock frequency = `f_clk / (2 × CLK_DIV)`.

## Basys 3 pin mapping

| Design port | Board resource | Pin(s) |
|-------------|----------------|--------|
| `clk` | 100 MHz oscillator | W5 |
| `rst_n` | SW15 (keep **UP** to run) | R2 |
| `parallel_data[7:0]` | SW0–SW7 | V17, V16, W16, W17, W15, V15, W14, W13 |
| `data_valid` | BTNU | T18 |
| `received_data[7:0]` | LD0–LD7 | U16, E19, U19, V19, W18, U15, U14, V14 |
| `received_valid` | LD15 | L1 |

The full constraints are in `constraints/basys3.xdc`.

## Getting started

### Requirements

- Xilinx Vivado (any recent version that supports Artix-7)
- Digilent Basys 3 board and micro-USB cable

### Build and program

1. Create a new Vivado project targeting **XC7A35TCPG236-1**.
2. Add the files in `src/` as design sources, `constraints/basys3.xdc` as constraints, and `sim/tb_msb.v` as a simulation source.
3. Set `spi_top` as the top module.
4. Run **Synthesis → Implementation → Generate Bitstream**.
5. Connect the board (JP1 set to USB/JTAG), then open **Hardware Manager → Open Target → Auto Connect → Program Device**.

## Testing

### Simulation

Run the behavioral simulation with `tb_msb` as the top module. It sends `0x80`, `0x01`, `0xC1` and `0x3A`, samples MOSI on each rising SPI clock edge, and compares it with the expected MSB-first bit. The console prints `PASS: MSB-first confirmed` on success.

Asymmetric patterns are used deliberately. A palindromic value like `0xA5` looks the same in either bit order and would not reveal a reversed design.

### On the board

1. Put **SW15 UP** to release reset.
2. Set a byte on **SW7–SW0**.
3. Press **BTNU**.
4. **LD7–LD0** should show the same byte.

> The LED test alone cannot prove bit order, because the slave reassembles bits in the order they arrive. To confirm MSB-first, probe `spi_mosi` with a logic analyzer or Vivado ILA, or rely on the simulation check.

Expected MOSI sequence at rising edges 1→8:

| Switch value | MOSI bits |
|--------------|-----------|
| `0x80` | 1 0 0 0 0 0 0 0 |
| `0x01` | 0 0 0 0 0 0 0 1 |
| `0xC1` | 1 1 0 0 0 0 0 1 |

## Known limitations

- **`received_valid` is very short.** It is high for one SPI clock period (about 80 ns), so LD15 will appear off. A pulse stretcher is needed to see it.
- **No button debounce.** `data_valid` is driven straight from BTNU. Holding the button causes repeated transfers of the same data.
- **Clock domain crossing.** Slave outputs are generated in the `spi_clk` domain and are not synchronized to `clk`. This is fine for LED display but not for downstream logic.
- **Slave clocked by fabric logic.** Vivado may report clock-routing warnings. They do not prevent the design from working.
- Single-slave, transmit-only (no MISO) implementation.

## Future improvements

- Add MISO for full-duplex operation
- Button debouncer and one-shot generator for `data_valid`
- Clock-domain synchronizers for slave outputs
- Configurable CPOL/CPHA
- Multi-slave support with multiple chip selects
- Expose `spi_cs`, `spi_clk` and `spi_mosi` on a Pmod header for external probing

## Tools

- Verilog HDL
- Xilinx Vivado
- Digilent Basys 3 (Artix-7 XC7A35T)

## License

Add your preferred license here (for example, MIT).

## Author

Your Name — [GitHub profile](https://github.com/your-username)
