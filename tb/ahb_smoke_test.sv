// First test: one single write+read, then one INCR4 write+read.
// Goal for Module 1 is only to see correct AHB and APB activity in the waveform.
class ahb_smoke_test extends uvm_test;

  `uvm_component_utils(ahb_smoke_test)

  ahb_agent agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = ahb_agent::type_id::create("agent", this);
  endfunction

  task run_phase(uvm_phase phase);
    ahb_single_wr_rd_seq s1;
    ahb_incr4_wr_rd_seq  s2;

    phase.raise_objection(this);
    s1 = ahb_single_wr_rd_seq::type_id::create("s1");
    s2 = ahb_incr4_wr_rd_seq::type_id::create("s2");
    s1.start(agent.sqr);
    s2.start(agent.sqr);
    #200ns;                       // let the bridge finish the last transfer
    phase.drop_objection(this);
  endtask

endclass
