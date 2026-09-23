`ifndef SPI_ENABLE_DISABLE_TEST_SV
`define SPI_ENABLE_DISABLE_TEST_SV


class spi_enable_disable_test extends spi_base_test;


    `uvm_component_utils(spi_enable_disable_test)



    function new(string name="spi_enable_disable_test",
                 uvm_component parent=null);

        super.new(name,parent);

    endfunction



    virtual task run_phase(uvm_phase phase);


        spi_enable_disable_seq seq;



        phase.raise_objection(this);



        seq = spi_enable_disable_seq::type_id::create("seq");



        seq.start(env.agent.sequencer);



        #500;



        phase.drop_objection(this);



    endtask



endclass


`endif