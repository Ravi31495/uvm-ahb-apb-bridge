// Plain-Verilog sanity check (no UVM, runs on free tools such as Icarus Verilog).
// It reproduces the exact pin timing the UVM driver in tb/ahb_driver.sv produces,
// so we can confirm the DUT responds correctly BEFORE debugging UVM itself.
`timescale 1ns/1ps
module smoke_tb;
  reg hclk = 0, hresetn = 0;
  reg hwrite = 0, hreadyin = 1;
  reg [1:0] htrans = 0;
  reg [31:0] haddr = 0, hwdata = 0;
  wire [31:0] hrdata, paddr, pwdata;
  wire penable, pwrite, hr_readyout;
  wire [2:0] psel;
  wire [1:0] hresp;
  wire [31:0] prdata = (!pwrite && penable && (|psel)) ? (paddr ^ 32'hA5A55A5A) : 32'h0;

  always #10 hclk = ~hclk;

  bridge_top dut(.hclk(hclk), .hresetn(hresetn), .hwrite(hwrite), .hreadyin(hreadyin),
                 .htrans(htrans), .hwdata(hwdata), .haddr(haddr), .prdata(prdata),
                 .penable(penable), .pwrite(pwrite), .hr_readyout(hr_readyout),
                 .psel(psel), .hresp(hresp), .paddr(paddr), .pwdata(pwdata), .hrdata(hrdata));

  integer apb_writes = 0, apb_reads = 0;
  // Observe APB transfers: ENABLE phase = psel != 0 && penable
  always @(posedge hclk) if (|psel && penable) begin
    if (pwrite) begin apb_writes = apb_writes + 1;
      $display("[%0t] APB WRITE psel=%b paddr=%h pwdata=%h", $time, psel, paddr, pwdata); end
    else begin apb_reads = apb_reads + 1;
      $display("[%0t] APB READ  psel=%b paddr=%h prdata=%h", $time, psel, paddr, prdata); end
  end

  // Same cycle structure as ahb_driver.drive_item()
  task drive(input incr4, input w, input [31:0] a, input [31:0] d0, d1, d2, d3, input integer idle);
    integer i, beats; reg [31:0] dat [0:3];
    begin
      dat[0]=d0; dat[1]=d1; dat[2]=d2; dat[3]=d3;
      beats = incr4 ? 4 : 1;
      for (i = 0; i < beats; i = i + 1) begin
        @(posedge hclk); #1;
        hreadyin = 1; hwrite = w; htrans = (i == 0) ? 2'b10 : 2'b11; haddr = a + i*4;
        if (w && i > 0) hwdata = dat[i-1];
      end
      @(posedge hclk); #1;
      htrans = 2'b00;
      if (w) hwdata = dat[beats-1];
      repeat (idle) @(posedge hclk);
    end
  endtask

  initial begin
    repeat (3) @(posedge hclk); #1 hresetn = 1;
    $display("--- single write 0x84000010 = 0xCAFE0001");
    drive(0, 1, 32'h8400_0010, 32'hCAFE0001, 0, 0, 0, 4);
    $display("--- single read 0x84000010");
    drive(0, 0, 32'h8400_0010, 0, 0, 0, 0, 4);
    $display("--- INCR4 write 0x88000100");
    drive(1, 1, 32'h8800_0100, 32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444, 4);
    $display("--- INCR4 read 0x88000100");
    drive(1, 0, 32'h8800_0100, 0, 0, 0, 0, 4);
    #100;
    $display("SUMMARY apb_writes=%0d apb_reads=%0d hresp=%b (expect 2 data-phase groups: 1+4 writes, 1+4 reads)", apb_writes, apb_reads, hresp);
    $finish;
  end
endmodule
