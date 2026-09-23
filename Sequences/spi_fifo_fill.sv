`ifndef SPI_FIFO_FILL_SEQUENCE_SV
`define SPI_FIFO_FILL_SEQUENCE_SV

class spi_fifo_fill_sequence extends spi_base_sequence;

    `uvm_object_utils(spi_fifo_fill_sequence)

    function new(string name = "spi_fifo_fill_sequence");
        super.new(name);
    endfunction

    virtual task body();

        super.body();

        `uvm_info(get_type_name(),
                  "Starting FIFO Fill Sequence",
                  UVM_LOW)

        // Fill FIFO with 4 values

        foreach({8'h11,8'h22,8'h33,8'h44}) begin
        end

        //-------------------------------------------------
        // Write 0x11
        //-------------------------------------------------
        req = spi_transaction::type_id::create("wr1");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b010;
        req.write_data = 8'h11;

        finish_item(req);

        //-------------------------------------------------
        // Write 0x22
        //-------------------------------------------------
        req = spi_transaction::type_id::create("wr2");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b010;
        req.write_data = 8'h22;

        finish_item(req);

        //-------------------------------------------------
        // Write 0x33
        //-------------------------------------------------
        req = spi_transaction::type_id::create("wr3");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b010;
        req.write_data = 8'h33;

        finish_item(req);

        //-------------------------------------------------
        // Write 0x44
        //-------------------------------------------------
        req = spi_transaction::type_id::create("wr4");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b010;
        req.write_data = 8'h44;

        finish_item(req);

        //-------------------------------------------------
        // Read SPSR
        //-------------------------------------------------

        req = spi_transaction::type_id::create("status");

        start_item(req);

        req.write      = 0;
        req.address    = 3'b001;
        req.write_data = 8'h00;

        finish_item(req);

    endtask

endclass

`endif