`ifndef SPI_MOSI_LOOPBACK_SEQ_SV
`define SPI_MOSI_LOOPBACK_SEQ_SV

class spi_mosi_loopback_seq extends spi_base_sequence;


`uvm_object_utils(spi_mosi_loopback_seq)


function new(string name="spi_mosi_loopback_seq");
    super.new(name);
endfunction


virtual task body();

    spi_transaction tx;

    byte tx_data;
    byte rx_data;


tx_data = 8'hA5;


    //-----------------------------------
    // Select slave (SS register)
    //-----------------------------------
    tx = spi_transaction::type_id::create("ss_write");

    start_item(tx);

    tx.address    = 3'h4;       // SS register
    tx.write      = 1;
    tx.write_data = 8'h01;

    finish_item(tx);



    //-----------------------------------
    // Enable SPI
    //-----------------------------------
    tx = spi_transaction::type_id::create("spi_enable");

    start_item(tx);

    tx.address    = 3'h0;       // SPCR
    tx.write      = 1;
    tx.write_data = 8'h50;      // SPE=1 + MSTR=1

    finish_item(tx);



    //-----------------------------------
    // Write TX FIFO / SPDR
    //-----------------------------------
    tx = spi_transaction::type_id::create("tx_data");

    start_item(tx);

    tx.address    = 3'h2;       // SPDR write
    tx.write      = 1;
    tx.write_data = tx_data;

    finish_item(tx);



    //-----------------------------------
    // Wait for SPI transfer
    //-----------------------------------
    #5000;



    //-----------------------------------
    // Read RX FIFO / SPDR
    //-----------------------------------
    tx = spi_transaction::type_id::create("rx_data");

    start_item(tx);

    tx.address = 3'h2;          // SPDR read
    tx.write   = 0;

    finish_item(tx);


    rx_data = tx.read_data;



    //-----------------------------------
    // Check loopback result
    //-----------------------------------
    if(rx_data == tx_data)

        `uvm_info("MOSI_LOOPBACK",
        $sformatf("PASS TX=%02h RX=%02h",
                  tx_data,
                  rx_data),
        UVM_LOW)

    else

        `uvm_error("MOSI_LOOPBACK",
        $sformatf("FAIL TX=%02h RX=%02h",
                  tx_data,
                  rx_data))


endtask


endclass

`endif