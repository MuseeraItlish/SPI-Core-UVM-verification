`ifndef SPI_BASE_SEQUENCE_SV
`define SPI_BASE_SEQUENCE_SV

class spi_base_sequence extends uvm_sequence #(spi_transaction);

    `uvm_object_utils(spi_base_sequence)

    // Connect this sequence to the SPI sequencer
    `uvm_declare_p_sequencer(spi_sequencer)

    spi_transaction req;

    function new(string name = "spi_base_sequence");
        super.new(name);
    endfunction

    virtual task body();

        `uvm_info(get_type_name(),
                  "Starting Base Sequence",
                  UVM_LOW)

    endtask

endclass

`endif