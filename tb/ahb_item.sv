// One AHB transfer (a single beat or a 4-beat incrementing burst).
class ahb_item extends uvm_sequence_item;

  rand ahb_burst_e  burst;
  rand bit [31:0]   haddr;
  rand bit          hwrite;
  rand bit [31:0]   hwdata [4];      // only hwdata[0] is used for SINGLE
  rand int unsigned idle_cycles;     // gap after the transfer (see driver note)

  // Bridge decodes 0x8000_0000 - 0x8BFF_FFFF onto three APB peripherals.
  constraint c_addr_range { haddr inside {[32'h8000_0000 : 32'h8BFF_FFFF]}; }
  // Word-aligned addresses (HSIZE = word).
  constraint c_align      { haddr[1:0] == 2'b00; }
  // AHB rule: a burst must not cross a 1 KB boundary.
  // INCR4 of words = 16 bytes, so the start offset within 1 KB must be <= 0x3F0.
  constraint c_1kb        { (burst == INCR4) -> (haddr[9:0] <= 10'h3F0); }
  constraint c_idle       { idle_cycles inside {[3:6]}; }

  `uvm_object_utils(ahb_item)

  function new(string name = "ahb_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("%s %s haddr=0x%08h data0=0x%08h idle=%0d",
                     burst.name(), hwrite ? "WRITE" : "READ ",
                     haddr, hwdata[0], idle_cycles);
  endfunction

endclass
