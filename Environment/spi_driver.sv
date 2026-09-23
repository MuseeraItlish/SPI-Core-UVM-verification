`ifndef SPI_DRIVER_SV
`define SPI_DRIVER_SV

class spi_driver extends uvm_driver #(spi_transaction);

    `uvm_component_utils(spi_driver)

    //------------------------------------------------------
    // Virtual Interface
    //------------------------------------------------------

    virtual spi_if vif;

    //------------------------------------------------------
    // Constructor
    //------------------------------------------------------

    function new(string name = "spi_driver",
                 uvm_component parent);
        super.new(name, parent);
    endfunction

    //------------------------------------------------------
    // Build Phase
    //------------------------------------------------------

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual spi_if)::get(this,"","vif",vif))
            `uvm_fatal("NOVIF","Virtual Interface not found")
    endfunction

    //------------------------------------------------------
    // Run Phase
    //------------------------------------------------------

    task run_phase(uvm_phase phase);

        forever begin

            seq_item_port.get_next_item(req);

            if(req.write)
                wb_write(req);
            else
                wb_read(req);

            seq_item_port.item_done();

        end

    endtask

    //------------------------------------------------------
    // Wishbone Write Task
    //------------------------------------------------------

    task wb_write(spi_transaction tr);

        @(posedge vif.clk_i);

        vif.cyc_i <= 1;
        vif.stb_i <= 1;
        vif.we_i  <= 1;

        vif.adr_i <= tr.address;
        vif.dat_i <= tr.write_data;

        wait(vif.ack_o);

        @(posedge vif.clk_i);

        vif.cyc_i <= 0;
        vif.stb_i <= 0;
        vif.we_i  <= 0;

    endtask

    //------------------------------------------------------
    // Wishbone Read Task
    //------------------------------------------------------

    task wb_read(spi_transaction tr);

        @(posedge vif.clk_i);

        vif.cyc_i <= 1;
        vif.stb_i <= 1;
        vif.we_i  <= 0;

        vif.adr_i <= tr.address;

        wait(vif.ack_o);

        tr.read_data = vif.dat_o;

        @(posedge vif.clk_i);

        vif.cyc_i <= 0;
        vif.stb_i <= 0;

    endtask

endclass

`endif

