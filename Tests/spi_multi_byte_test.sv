`ifndef SPI_MULTI_BYTE_TEST_SV
`define SPI_MULTI_BYTE_TEST_SV

class spi_multi_byte_test extends spi_base_test;

    `uvm_component_utils(spi_multi_byte_test)

    function new(string name="spi_multi_byte_test",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual task run_phase(uvm_phase phase);

        spi_multi_byte_seq    spi_seq;
        spi_pin_response_seq  pin_seq;

        phase.raise_objection(this);

        // Create sequences
        spi_seq = spi_multi_byte_seq::type_id::create("spi_seq");
        pin_seq = spi_pin_response_seq::type_id::create("pin_seq");

        // Run master and slave together
        fork
            begin
                spi_seq.start(env.agent.sequencer);
            end

            begin
                pin_seq.start(env.pin_agent.sequencer);
            end
        join

        phase.drop_objection(this);

    endtask

endclass

`endif