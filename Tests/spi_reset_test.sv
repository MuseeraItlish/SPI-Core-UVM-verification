`ifndef SPI_RESET_TEST_SV
`define SPI_RESET_TEST_SV

class spi_reset_test extends spi_base_test;

    `uvm_component_utils(spi_reset_test)

    spi_reset_sequence seq;

    function new(string name="spi_reset_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = spi_reset_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass

`endif