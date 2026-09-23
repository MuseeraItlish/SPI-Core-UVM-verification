`ifndef SPI_PIN_MONITOR_SV
`define SPI_PIN_MONITOR_SV

class spi_pin_monitor extends uvm_monitor;


    `uvm_component_utils(spi_pin_monitor)


    virtual spi_if vif;


    uvm_analysis_port #(spi_pin_transaction) mon_ap;


    int unsigned bytes_captured;



    function new(string name="spi_pin_monitor",
                 uvm_component parent);

        super.new(name,parent);

        mon_ap = new("mon_ap",this);

    endfunction



    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db #(virtual spi_if)::get(this,"","vif",vif))

            `uvm_fatal("NOVIF",
            "Virtual interface not found")

    endfunction



    task run_phase(uvm_phase phase);


        bit [7:0] mosi_shift;
        bit [7:0] miso_shift;

        int bit_cnt;


        spi_pin_transaction tr;


        bit_cnt = 0;
        mosi_shift = 0;
        miso_shift = 0;



        `uvm_info("PIN_MONITOR",
        "MOSI/MISO monitor started",
        UVM_LOW)



        forever begin


            // CPHA=0 : sample on rising edge
            @(posedge vif.sck_o);


            if(vif.rst_i) begin

                bit_cnt = 0;
                mosi_shift = 0;
                miso_shift = 0;

                continue;

            end


            #1ps;


            // Shift incoming bits
            mosi_shift = {mosi_shift[6:0],
                          vif.mosi_o};


            miso_shift = {miso_shift[6:0],
                          vif.miso_i};



            bit_cnt++;



            if(bit_cnt == 8) begin


                tr = spi_pin_transaction::type_id::create("tr");


                // captured from pins
                tr.mosi_data = mosi_shift;
                tr.miso_data = miso_shift;

                tr.is_miso_drive = 0;


                mon_ap.write(tr);


                bytes_captured++;



                `uvm_info("PIN_MONITOR",
                $sformatf(
                "Captured MOSI=0x%0h MISO=0x%0h",
                mosi_shift,
                miso_shift),
                UVM_MEDIUM)



                bit_cnt = 0;
                mosi_shift = 0;
                miso_shift = 0;


            end


        end


    endtask



    function void report_phase(uvm_phase phase);


        `uvm_info(get_type_name(),
        $sformatf(
        "Pin monitor captured %0d SPI byte(s)",
        bytes_captured),
        UVM_NONE)

    endfunction


endclass


`endif