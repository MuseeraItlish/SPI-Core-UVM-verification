`ifndef SPI_PIN_AGENT_SV
`define SPI_PIN_AGENT_SV

//==========================================================
// spi_pin_agent
//
// Self-contained UVC for the serial side of the DUT (sck_o,
// ss_o, mosi_o, miso_i), independent of spi_agent (which only
// ever talks Wishbone). Always active: the driver must run
// even in tests that never issue an explicit MISO request,
// since it's also responsible for the default miso_i<-mosi_o
// loopback that tb_top used to provide directly.
//==========================================================

class spi_pin_agent extends uvm_agent;

    `uvm_component_utils(spi_pin_agent)

    spi_pin_driver    driver;
    spi_pin_monitor   monitor;
    spi_pin_sequencer sequencer;

    function new(string name = "spi_pin_agent",
                 uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        driver    = spi_pin_driver   ::type_id::create("driver", this);
        monitor   = spi_pin_monitor  ::type_id::create("monitor", this);
        sequencer = spi_pin_sequencer::type_id::create("sequencer", this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        driver.seq_item_port.connect(sequencer.seq_item_export);

    endfunction

endclass

`endif
