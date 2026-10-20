// All AHB agent classes live in one package.
package ahb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // AHB HTRANS encodings
  localparam bit [1:0] HTRANS_IDLE   = 2'b00;
  localparam bit [1:0] HTRANS_BUSY   = 2'b01;
  localparam bit [1:0] HTRANS_NONSEQ = 2'b10;
  localparam bit [1:0] HTRANS_SEQ    = 2'b11;

  typedef enum bit { SINGLE, INCR4 } ahb_burst_e;

  `include "ahb_item.sv"
  `include "ahb_driver.sv"
  `include "ahb_sequences.sv"
  `include "ahb_agent.sv"
  `include "ahb_smoke_test.sv"
endpackage
