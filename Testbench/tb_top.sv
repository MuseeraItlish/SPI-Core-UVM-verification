`timescale 1ns/1ps

module tb_top;

    //--------------------------------------------------
    // Import Packages
    //--------------------------------------------------

    import uvm_pkg::*;
    import spi_pkg::*;

    `include "uvm_macros.svh"

    //--------------------------------------------------
    // Clock / Reset
    //--------------------------------------------------

    bit clk;
    bit rst;

   //--------------------------------------------------
    // Interface
    //--------------------------------------------------

    spi_if spi_if_inst();
    
    //--------------------------------------------------
    // Clock Generation
    //--------------------------------------------------

    always #5 clk = ~clk;
assign spi_if_inst.clk_i=clk;
assign spi_if_inst.rst_i=rst;
 

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    simple_spi dut (

        .clk_i   (clk),
        .rst_i   (rst),

        .cyc_i   (spi_if_inst.cyc_i),
        .stb_i   (spi_if_inst.stb_i),
        .adr_i   (spi_if_inst.adr_i),
        .we_i    (spi_if_inst.we_i),
        .dat_i   (spi_if_inst.dat_i),

        .dat_o   (spi_if_inst.dat_o),
        .ack_o   (spi_if_inst.ack_o),
        .inta_o  (spi_if_inst.inta_o),

        .sck_o   (spi_if_inst.sck_o),
        .ss_o    (spi_if_inst.ss_o),
        .mosi_o  (spi_if_inst.mosi_o),
        .miso_i  (spi_if_inst.miso_i)

    );
   spi_slave_model slave(

    .sck(spi_if_inst.sck_o),
    .ss(spi_if_inst.ss_o),
    .mosi(spi_if_inst.mosi_o),
    .miso(spi_if_inst.miso_i)

);
    // assign spi_if_inst.miso_i = spi_if_inst.mosi_o;


    //--------------------------------------------------
    // Reset
    //--------------------------------------------------

    initial begin

        clk = 0;
        rst = 1;

        #20;

        rst = 0;

    end

    //--------------------------------------------------
    // Virtual Interface
    //--------------------------------------------------

    initial begin

        uvm_config_db#(virtual spi_if)::set(

            null,

            "*",

            "vif",

            spi_if_inst

        );

    end

    //--------------------------------------------------
    // Start UVM
    //--------------------------------------------------

    initial begin

        run_test();

    end

endmodule