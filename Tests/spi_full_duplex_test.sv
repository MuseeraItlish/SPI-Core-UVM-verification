class spi_full_duplex_test extends spi_base_test;


`uvm_component_utils(spi_full_duplex_test)



function new(
string name="spi_full_duplex_test",
uvm_component parent=null);

super.new(name,parent);

endfunction




virtual task run_phase(uvm_phase phase);


spi_full_duplex_seq seq;



phase.raise_objection(this);



seq =
spi_full_duplex_seq::type_id::create("seq");



seq.start(
env.agent.sequencer
);



phase.drop_objection(this);



endtask


endclass