class spi_full_duplex_seq extends spi_base_sequence;

`uvm_object_utils(spi_full_duplex_seq)


function new(string name="spi_full_duplex_seq");
    super.new(name);
endfunction



virtual task body();

spi_transaction req;

bit [7:0] tx_data[5] =
{
    8'h55,
    8'hAA,
    8'hFF,
    8'h00,
    8'h3C
};


bit [7:0] rx_data;



// Select slave
req = spi_transaction::type_id::create("ss_write");

start_item(req);

req.address   = 3'h4;     // SS register
req.write     = 1;
req.write_data = 8'h01;

finish_item(req);



// Enable SPI once
req = spi_transaction::type_id::create("ctrl_write");

start_item(req);

req.address = 3'h0;       // SPCR/CTRL depending on your map
req.write = 1;
req.write_data = 8'h50;

finish_item(req);



foreach(tx_data[i])
begin


    // Write TX FIFO
    req = spi_transaction::type_id::create("tx_write");

    start_item(req);

    req.address = 3'h2;      // SPDR/TX FIFO
    req.write = 1;
    req.write_data = tx_data[i];

    finish_item(req);



    `uvm_info("FULL_DUPLEX",
       $sformatf("TX BYTE = %h",tx_data[i]),
       UVM_LOW)



    // Wait SPI transfer
    #1000;



    // Read RX FIFO
    req = spi_transaction::type_id::create("rx_read");

    start_item(req);

    req.address = 3'h2;
    req.write = 0;

    finish_item(req);


    rx_data = req.read_data;



    `uvm_info("FULL_DUPLEX",
       $sformatf("TX=%h RX=%h",
       tx_data[i],rx_data),
       UVM_LOW)



end


endtask

endclass