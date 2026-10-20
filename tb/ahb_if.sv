// AHB-side interface of the bridge (the bridge is an AHB slave).
// The clocking blocks make the testbench drive and sample signals with defined
// timing, which avoids race conditions between the testbench and the DUT.
interface ahb_if (input logic hclk, input logic hresetn);

  logic        hwrite;
  logic        hreadyin;
  logic [1:0]  htrans;
  logic [31:0] haddr;
  logic [31:0] hwdata;
  logic [31:0] hrdata;
  logic        hr_readyout;
  logic [1:0]  hresp;

  // Driver view: drive 1 ns after the clock edge, sample just before the edge.
  clocking drv_cb @(posedge hclk);
    default input #1step output #1;
    output hwrite, hreadyin, htrans, haddr, hwdata;
    input  hrdata, hr_readyout, hresp;
  endclocking

  // Monitor view: sample everything, drive nothing (used from Module 2).
  clocking mon_cb @(posedge hclk);
    default input #1step;
    input hwrite, hreadyin, htrans, haddr, hwdata, hrdata, hr_readyout, hresp;
  endclocking

  modport DRV (clocking drv_cb, input hclk, input hresetn);
  modport MON (clocking mon_cb, input hclk, input hresetn);

endinterface
