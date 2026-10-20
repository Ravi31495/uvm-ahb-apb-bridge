// Converts ahb_item objects into pin-level AHB activity.
//
// AHB is pipelined: the ADDRESS phase of beat N overlaps the DATA phase of beat N-1.
//   cycle k   : drive haddr/hwrite/htrans for beat 0
//   cycle k+1 : drive haddr for beat 1 AND hwdata for beat 0 ...
//
// Known simplification (Module 1): the driver does not wait for hr_readyout and
// holds hreadyin = 1, the same as the original directed testbench. It leaves
// idle_cycles between items so the bridge FSM can finish. Proper HREADY wait-state
// handling is a Module 2 task.
class ahb_driver extends uvm_driver #(ahb_item);

  `uvm_component_utils(ahb_driver)

  virtual ahb_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual ahb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface ahb_if was not set for the driver")
  endfunction

  task run_phase(uvm_phase phase);
    init_signals();
    wait (vif.hresetn === 1'b1);
    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("DRV", req.convert2string(), UVM_MEDIUM)
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task init_signals();
    @(vif.drv_cb);
    vif.drv_cb.hwrite   <= 1'b0;
    vif.drv_cb.hreadyin <= 1'b1;
    vif.drv_cb.htrans   <= HTRANS_IDLE;
    vif.drv_cb.haddr    <= '0;
    vif.drv_cb.hwdata   <= '0;
  endtask

  task drive_item(ahb_item it);
    int beats = (it.burst == INCR4) ? 4 : 1;

    // Address phases (and, for writes, the data phase of the previous beat)
    for (int i = 0; i < beats; i++) begin
      @(vif.drv_cb);
      vif.drv_cb.hreadyin <= 1'b1;
      vif.drv_cb.hwrite   <= it.hwrite;
      vif.drv_cb.htrans   <= (i == 0) ? HTRANS_NONSEQ : HTRANS_SEQ;
      vif.drv_cb.haddr    <= it.haddr + (i * 4);
      if (it.hwrite && i > 0)
        vif.drv_cb.hwdata <= it.hwdata[i-1];
    end

    // Final data phase: bus goes IDLE, last write data is presented
    @(vif.drv_cb);
    vif.drv_cb.htrans <= HTRANS_IDLE;
    if (it.hwrite)
      vif.drv_cb.hwdata <= it.hwdata[beats-1];

    // Gap before the next item
    repeat (it.idle_cycles) @(vif.drv_cb);
  endtask

endclass
