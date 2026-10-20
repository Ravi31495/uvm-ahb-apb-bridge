// Write a location, then read the same location back.
class ahb_single_wr_rd_seq extends uvm_sequence #(ahb_item);
  `uvm_object_utils(ahb_single_wr_rd_seq)

  function new(string name = "ahb_single_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    ahb_item wr, rd;

    wr = ahb_item::type_id::create("wr");
    start_item(wr);
    if (!wr.randomize() with { burst == SINGLE; hwrite == 1; })
      `uvm_fatal("RAND", "randomize failed for write item")
    finish_item(wr);

    rd = ahb_item::type_id::create("rd");
    start_item(rd);
    if (!rd.randomize() with { burst == SINGLE; hwrite == 0; haddr == wr.haddr; })
      `uvm_fatal("RAND", "randomize failed for read item")
    finish_item(rd);
  endtask
endclass

// Same idea with a 4-beat incrementing burst.
class ahb_incr4_wr_rd_seq extends uvm_sequence #(ahb_item);
  `uvm_object_utils(ahb_incr4_wr_rd_seq)

  function new(string name = "ahb_incr4_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    ahb_item wr, rd;

    wr = ahb_item::type_id::create("wr");
    start_item(wr);
    if (!wr.randomize() with { burst == INCR4; hwrite == 1; })
      `uvm_fatal("RAND", "randomize failed for write burst")
    finish_item(wr);

    rd = ahb_item::type_id::create("rd");
    start_item(rd);
    if (!rd.randomize() with { burst == INCR4; hwrite == 0; haddr == wr.haddr; })
      `uvm_fatal("RAND", "randomize failed for read burst")
    finish_item(rd);
  endtask
endclass
