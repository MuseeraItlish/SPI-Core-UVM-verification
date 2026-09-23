// `timescale 1ns/1ps
// interface spi_if();

    
//     //---- Wishbone Signals-----------
   

//     logic         clk_i;
//     logic         rst_i;

//     logic         cyc_i;
//     logic         stb_i;
//     logic         we_i;
//     logic [2:0]   adr_i;
//     logic [7:0]   dat_i;

//     logic [7:0]   dat_o;
//     logic         ack_o;
//     logic         inta_o;

 
//     // =----------SPI Signals-----------
    

//     logic         sck_o;
//     logic         ss_o;
//     logic         mosi_o;
//     logic         miso_i;

// endinterface


`timescale 1ns/1ps
`ifndef SPI_IF_SV
`define SPI_IF_SV

interface spi_if();

    // Wishbone
    logic         clk_i;
    logic         rst_i;

    logic         cyc_i;
    logic         stb_i;
    logic         we_i;
    logic [2:0]   adr_i;
    logic [7:0]   dat_i;

    logic [7:0]   dat_o;
    logic         ack_o;
    logic         inta_o;


    // SPI
    logic         sck_o;
    logic         ss_o;
    logic         mosi_o;
    logic         miso_i;


endinterface

`endif