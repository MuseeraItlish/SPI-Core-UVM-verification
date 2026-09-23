`ifndef SPI_MOSI_LOOPBACK_TEST_SV
`define SPI_MOSI_LOOPBACK_TEST_SV


class spi_mosi_loopback_test extends spi_base_test;


    `uvm_component_utils(spi_mosi_loopback_test)

 spi_mosi_loopback_seq seq;
    function new(string name="spi_mosi_loopback_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction



    task run_phase(uvm_phase phase);


        phase.raise_objection(this);


        // Enable pin-level checking
        env.pin_scoreboard.enable_checks();


        seq = spi_mosi_loopback_seq::type_id::create("seq");


        // Drive Wishbone side
        seq.start(env.agent.sequencer);



        phase.drop_objection(this);


    endtask


endclass


`endif