// APB-side interface of the bridge (the bridge is an APB master).
// Passive for now: a small behavioural APB slave lives in tb_top.sv.
interface apb_if (input logic hclk);

  logic        penable;
  logic        pwrite;
  logic [2:0]  psel;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;

endinterface
