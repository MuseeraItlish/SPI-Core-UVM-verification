`ifndef SPI_PIN_SEQUENCER_SV
`define SPI_PIN_SEQUENCER_SV

class spi_pin_sequencer extends uvm_sequencer #(spi_pin_transaction);

    `uvm_component_utils(spi_pin_sequencer)

    function new(string name = "spi_pin_sequencer",
                 uvm_component parent);

        super.new(name, parent);

    endfunction

endclass

`endif
