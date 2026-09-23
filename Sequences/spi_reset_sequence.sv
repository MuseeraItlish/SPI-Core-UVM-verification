`ifndef SPI_RESET_SEQUENCE_SV
`define SPI_RESET_SEQUENCE_SV

class spi_reset_sequence extends spi_base_sequence;

    `uvm_object_utils(spi_reset_sequence)

    //-----------------------------------------
    // Constructor
    //-----------------------------------------
    function new(string name = "spi_reset_sequence");
        super.new(name);
    endfunction

    //-----------------------------------------
    // Body
    //-----------------------------------------
    virtual task body();

        super.body();

        `uvm_info(get_type_name(),
                  "Running Reset Sequence",
                  UVM_LOW)

        // Read SPCR after reset
        req = spi_transaction::type_id::create("req");

        start_item(req);

        req.write      = 0;          // Read transaction
        req.address    = 3'b000;     // SPCR
        req.write_data = 8'h00;

        finish_item(req);

        // Read SPER after reset
        req = spi_transaction::type_id::create("req2");

        start_item(req);

        req.write      = 0;
        req.address    = 3'b011;     // SPER
        req.write_data = 8'h00;

        finish_item(req);

    endtask

endclass

`endif