`ifndef SPI_TRANSACTION_SV
`define SPI_TRANSACTION_SV

class spi_transaction extends uvm_sequence_item;

    `uvm_object_utils(spi_transaction)

    //----------------------------------------------------
    // Wishbone Transaction Fields
    //----------------------------------------------------

    // Register address
    rand bit [2:0] address;

    // Data to be written
    rand bit [7:0] write_data;

    // Read data returned by DUT
    bit [7:0] read_data;

    // Read = 0, Write = 1
    rand bit write;

// Interrupt status
bit interrupt;
    //----------------------------------------------------
    // Constructor
    //----------------------------------------------------

    function new(string name = "spi_transaction");
        super.new(name);
    endfunction

    //----------------------------------------------------
    // Print Transaction
    //----------------------------------------------------

    function string convert2string();

        return $sformatf(
            "WRITE=%0d ADDR=0x%0h WRITE_DATA=0x%0h READ_DATA=0x%0h",
            write,
            address,
            write_data,
            read_data
        );

    endfunction

endclass

`endif