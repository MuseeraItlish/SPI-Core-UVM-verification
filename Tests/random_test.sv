`ifndef SPI_RANDOM_TEST_SV
`define SPI_RANDOM_TEST_SV

class spi_random_test extends spi_base_test;

    `uvm_component_utils(spi_random_test)

    spi_random_sequence seq;

    function new(string name="spi_random_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = spi_random_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass

`endif