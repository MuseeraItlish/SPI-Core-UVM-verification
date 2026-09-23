`ifndef SPI_MONITOR_SV
`define SPI_MONITOR_SV

class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    //------------------------------------------------------
    // Virtual Interface
    //------------------------------------------------------

    virtual spi_if vif;

    //------------------------------------------------------
    // Analysis Port
    //------------------------------------------------------

    uvm_analysis_port #(spi_transaction) mon_ap;

    //------------------------------------------------------
    // Constructor
    //------------------------------------------------------

    function new(string name = "spi_monitor",
                 uvm_component parent);

        super.new(name,parent);

        mon_ap = new("mon_ap",this);

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

        spi_transaction tr;

        forever begin

            @(posedge vif.clk_i);

            if(vif.cyc_i && vif.stb_i && vif.ack_o) begin

                tr = spi_transaction::type_id::create("tr");

                tr.address    = vif.adr_i;
                tr.write      = vif.we_i;
                tr.write_data = vif.dat_i;
                tr.read_data  = vif.dat_o;
                tr.interrupt = vif.inta_o;

                mon_ap.write(tr);

                `uvm_info("MONITOR",
                          tr.convert2string(),
                          UVM_MEDIUM)

            end

        end

    endtask

endclass

`endif