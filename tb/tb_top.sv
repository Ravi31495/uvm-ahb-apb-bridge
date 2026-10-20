`timescale 1ns/1ps
`include "uvm_macros.svh"

module tb_top;
  import uvm_pkg::*;
  import ahb_pkg::*;

  logic hclk    = 1'b0;
  logic hresetn = 1'b0;

  // 50 MHz clock (same as the original testbench), reset released after 3 cycles
  always #10 hclk = ~hclk;
  initial begin
    repeat (3) @(posedge hclk);
    #1 hresetn = 1'b1;
  end

  ahb_if ahb (.hclk(hclk), .hresetn(hresetn));
  apb_if apb (.hclk(hclk));

  bridge_top dut (
    .hclk        (hclk),
    .hresetn     (hresetn),
    .hwrite      (ahb.hwrite),
    .hreadyin    (ahb.hreadyin),
    .htrans      (ahb.htrans),
    .hwdata      (ahb.hwdata),
    .haddr       (ahb.haddr),
    .prdata      (apb.prdata),
    .penable     (apb.penable),
    .pwrite      (apb.pwrite),
    .hr_readyout (ahb.hr_readyout),
    .psel        (apb.psel),
    .hresp       (ahb.hresp),
    .paddr       (apb.paddr),
    .pwdata      (apb.pwdata),
    .hrdata      (ahb.hrdata)
  );

  // Minimal APB slave model: deterministic read data (the old model used $random,
  // which makes read data impossible to check later in a scoreboard).
  assign apb.prdata = (!apb.pwrite && apb.penable && (|apb.psel))
                      ? (apb.paddr ^ 32'hA5A5_5A5A) : 32'h0;

  initial begin
    uvm_config_db #(virtual ahb_if)::set(null, "*", "vif", ahb);
    run_test("ahb_smoke_test");
  end

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_top);
  end
endmodule
