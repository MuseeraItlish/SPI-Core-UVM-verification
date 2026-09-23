
//--------------FULLL DUPLEX--------------//

// module spi_slave_model(

//     input  logic sck,
//     input  logic ss,
//     input  logic mosi,

//     output logic miso

// );


// logic [7:0] rx_data;
// logic [7:0] tx_data;

// integer bit_count;


// // Data slave will return
// initial begin

//     tx_data = 8'hA5;

// end



// always @(negedge ss)
// begin

//     bit_count = 0;
//     rx_data = 0;

// end



// // Receive MOSI
// always @(posedge sck)
// begin

//     if(!ss)
//     begin

//         rx_data = {rx_data[6:0],mosi};

//         bit_count++;

//     end

// end



// // Send MISO
// always @(negedge sck)
// begin

//     if(!ss)
//     begin

//         miso = tx_data[7-bit_count];

//     end

// end


// endmodule

//-------------MULTI BYTES--------//
module spi_slave_model(

    input  logic sck,
    input  logic ss,
    input  logic mosi,

    output logic miso

);


logic [7:0] rx_data;
logic [7:0] tx_data [4];

integer bit_count;
integer byte_count;


// Slave response data
initial begin

    tx_data[0] = 8'hA1;
    tx_data[1] = 8'hB2;
    tx_data[2] = 8'hC3;
    tx_data[3] = 8'hD4;

    miso = 0;

end



// New SPI transaction
always @(negedge ss)
begin

    bit_count = 0;
    byte_count = 0;

    rx_data = 8'b0;

end



// Receive MOSI data
always @(posedge sck)
begin

    if(!ss)
    begin

        rx_data = {rx_data[6:0],mosi};


        bit_count++;


        // One byte received
        if(bit_count == 8)
        begin

            $display(
            "SLAVE RECEIVED MOSI BYTE = %h",
            rx_data);


            bit_count = 0;

            byte_count++;


            if(byte_count == 4)
                byte_count = 0;


        end

    end

end



// Send MISO data
always @(negedge sck)
begin

    if(!ss)
    begin


        // Send current byte MSB first
        miso = tx_data[byte_count][7-bit_count];


    end

end



endmodule