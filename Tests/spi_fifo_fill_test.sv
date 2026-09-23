`ifndef SPI_FIFO_FILL_TEST_SV
`define SPI_FIFO_FILL_TEST_SV

class spi_fifo_fill_test extends spi_base_test;

    `uvm_component_utils(spi_fifo_fill_test)

    spi_fifo_fill_sequence seq;

    //-----------------------------------------
    // Constructor
    //-----------------------------------------

    function new(string name="spi_fifo_fill_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction

    //-----------------------------------------
    // Run Phase
    //-----------------------------------------

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = spi_fifo_fill_sequence::type_id::create("seq");

        seq.start(env.agent.sequencer);

        phase.drop_objection(this);

    endtask

endclass

`endif