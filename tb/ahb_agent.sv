// Active AHB agent: sequencer + driver. The monitor is added in Module 2.
class ahb_agent extends uvm_agent;

  `uvm_component_utils(ahb_agent)

  ahb_driver                 drv;
  uvm_sequencer #(ahb_item)  sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = ahb_driver::type_id::create("drv", this);
    sqr = uvm_sequencer #(ahb_item)::type_id::create("sqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass
