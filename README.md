# UVM Verification of an AHB-to-APB Bridge

A SystemVerilog/UVM verification environment for an AMBA AHB-to-APB bridge.
The DUT is the bridge I implemented in Verilog during my Maven Silicon VLSI internship
(RTL in `dut/`, original project: *Design-and-Implementation-of-AHB-to-APB-Bridge-using-Verilog*).

> **Status: in progress.** Module 1 (AHB agent: interface, transaction, driver, sequences) is written.
> Monitors, scoreboard, assertions and coverage are the next modules. No coverage or pass/fail
> results are claimed yet.

## Why this project
The original bridge was checked with directed Verilog tasks and no automatic checking. This project
replaces that with a reusable UVM environment: constrained-random stimulus, a self-checking
scoreboard, SVA protocol assertions, functional coverage, and bug-injection to prove the testbench
catches real errors.

## Architecture (target)
```
 sequences -> sequencer -> AHB driver --(ahb_if)--> [ bridge DUT ] --(apb_if)--> APB slave model
                                |                                        |
                          AHB monitor                              APB monitor
                                \_____________  scoreboard  ____________/
                                              coverage + SVA
```

## Roadmap
| Module | Content | Status |
|---|---|---|
| 1 | `ahb_if`, `ahb_item`, `ahb_driver`, sequences, agent, smoke test | written, first compile/run in progress |
| 2 | AHB + APB monitors, scoreboard (AHB write -> APB write, APB read data -> AHB read data) | planned |
| 3 | SVA assertions (APB SETUP->ENABLE timing, PSEL one-hot, AHB 1 KB burst rule, HRESP driven) | planned |
| 4 | Functional coverage (address window x read/write x burst type, back-to-back, reset) | planned |
| 5 | Bug injection (10+ RTL mutations) and a table of which ones the testbench catches | planned |

## Tools
- **SystemVerilog + UVM 1.2** for the environment
- **EDA Playground** (free, browser) with Questa or Riviera-PRO and "UVM 1.2" selected, or
  **Questa Intel FPGA Edition** if your install includes UVM support
- **Icarus Verilog** for the plain-Verilog sanity check in `smoke/` (no UVM needed)
- **GTKWave** or the simulator's waveform viewer for `waves.vcd`
- **Git/GitHub** for version control

## How to run
Plain-Verilog sanity check (any machine with Icarus Verilog):
```
iverilog -g2005 -o smoke.vvp dut/*.v smoke/smoke_tb.v && vvp smoke.vvp
```
UVM run (commercial simulator, e.g. Questa):
```
vlog -sv -f filelist.f
vsim -c tb_top -do "run -all; quit"
```
On EDA Playground: choose UVM 1.2, paste the files into tabs, make `tb_top.sv` the testbench file
and keep the same file names so the `include` lines resolve.

## Observations so far (from the plain-Verilog sanity check, to be investigated in Module 2)
- `bridge_top` declares `hresp` as an output but never drives it, so it reads `z`. An AHB slave
  should drive HRESP (OKAY = 2'b00). This becomes an SVA assertion in Module 3.
- With one-cycle-per-beat INCR4 stimulus, not every beat reaches the APB side (a 4-beat write
  showed 3 APB writes, a 4-beat read showed 2 APB reads). The original directed read stimulus used
  two cycles per beat. Whether this comes from stimulus timing or from the bridge's wait-state
  handling is not yet known; the Module 2 monitors and scoreboard are meant to answer it.

## Known simplifications (Module 1)
- The driver holds `hreadyin = 1` and does not wait on `hr_readyout`; it leaves `idle_cycles`
  between items. Proper HREADY handling comes after the monitors exist.
- The APB slave model is a combinational function of `paddr` (deterministic read data) so the
  scoreboard can predict read values.

## Layout
```
dut/    bridge RTL (from my earlier project)
tb/     interfaces, UVM package, driver, sequences, agent, test, tb_top
smoke/  plain-Verilog sanity check
docs/   notes and waveforms (to be added)
```
