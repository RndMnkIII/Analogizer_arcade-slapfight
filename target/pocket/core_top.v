//
// User core top-level
//
// Instantiated by the real top-level: apf_top
//

`default_nettype none

module core_top (

        //
        // physical connections
        //

        ///////////////////////////////////////////////////
        // clock inputs 74.25mhz. not phase aligned, so treat these domains as asynchronous

        input   wire            clk_74a, // mainclk1
        input   wire            clk_74b, // mainclk1

        ///////////////////////////////////////////////////
        // cartridge interface
        // switches between 3.3v and 5v mechanically
        // output enable for multibit translators controlled by pic32

        // GBA AD[15:8]
        inout   wire    [7:0]   cart_tran_bank2,
        output  wire            cart_tran_bank2_dir,

        // GBA AD[7:0]
        inout   wire    [7:0]   cart_tran_bank3,
        output  wire            cart_tran_bank3_dir,

        // GBA A[23:16]
        inout   wire    [7:0]   cart_tran_bank1,
        output  wire            cart_tran_bank1_dir,

        // GBA [7] PHI#
        // GBA [6] WR#
        // GBA [5] RD#
        // GBA [4] CS1#/CS#
        //     [3:0] unwired
        inout   wire    [7:4]   cart_tran_bank0,
        output  wire            cart_tran_bank0_dir,

        // GBA CS2#/RES#
        inout   wire            cart_tran_pin30,
        output  wire            cart_tran_pin30_dir,
        // when GBC cart is inserted, this signal when low or weak will pull GBC /RES low with a special circuit
        // the goal is that when unconfigured, the FPGA weak pullups won't interfere.
        // thus, if GBC cart is inserted, FPGA must drive this high in order to let the level translators
        // and general IO drive this pin.
        output  wire            cart_pin30_pwroff_reset,

        // GBA IRQ/DRQ
        inout   wire            cart_tran_pin31,
        output  wire            cart_tran_pin31_dir,

        // infrared
        input   wire            port_ir_rx,
        output  wire            port_ir_tx,
        output  wire            port_ir_rx_disable,

        // GBA link port
        inout   wire            port_tran_si,
        output  wire            port_tran_si_dir,
        inout   wire            port_tran_so,
        output  wire            port_tran_so_dir,
        inout   wire            port_tran_sck,
        output  wire            port_tran_sck_dir,
        inout   wire            port_tran_sd,
        output  wire            port_tran_sd_dir,

        ///////////////////////////////////////////////////
        // cellular psram 0 and 1, two chips (64mbit x2 dual die per chip)

        output  wire    [21:16] cram0_a,
        inout   wire    [15:0]  cram0_dq,
        input   wire            cram0_wait,
        output  wire            cram0_clk,
        output  wire            cram0_adv_n,
        output  wire            cram0_cre,
        output  wire            cram0_ce0_n,
        output  wire            cram0_ce1_n,
        output  wire            cram0_oe_n,
        output  wire            cram0_we_n,
        output  wire            cram0_ub_n,
        output  wire            cram0_lb_n,

        output  wire    [21:16] cram1_a,
        inout   wire    [15:0]  cram1_dq,
        input   wire            cram1_wait,
        output  wire            cram1_clk,
        output  wire            cram1_adv_n,
        output  wire            cram1_cre,
        output  wire            cram1_ce0_n,
        output  wire            cram1_ce1_n,
        output  wire            cram1_oe_n,
        output  wire            cram1_we_n,
        output  wire            cram1_ub_n,
        output  wire            cram1_lb_n,

        ///////////////////////////////////////////////////
        // sdram, 512mbit 16bit

        output  wire    [12:0]  dram_a,
        output  wire    [1:0]   dram_ba,
        inout   wire    [15:0]  dram_dq,
        output  wire    [1:0]   dram_dqm,
        output  wire            dram_clk,
        output  wire            dram_cke,
        output  wire            dram_ras_n,
        output  wire            dram_cas_n,
        output  wire            dram_we_n,

        ///////////////////////////////////////////////////
        // sram, 1mbit 16bit

        output  wire    [16:0]  sram_a,
        inout   wire    [15:0]  sram_dq,
        output  wire            sram_oe_n,
        output  wire            sram_we_n,
        output  wire            sram_ub_n,
        output  wire            sram_lb_n,

        ///////////////////////////////////////////////////
        // vblank driven by dock for sync in a certain mode

        input   wire            vblank,

        ///////////////////////////////////////////////////
        // i/o to 6515D breakout usb uart

        output  wire            dbg_tx,
        input   wire            dbg_rx,

        ///////////////////////////////////////////////////
        // i/o pads near jtag connector user can solder to

        output  wire            user1,
        input   wire            user2,

        ///////////////////////////////////////////////////
        // RFU internal i2c bus

        inout   wire            aux_sda,
        output  wire            aux_scl,

        ///////////////////////////////////////////////////
        // RFU, do not use
        output  wire            vpll_feed,


        //
        // logical connections
        //

        ///////////////////////////////////////////////////
        // video, audio output to scaler
        output  wire    [23:0]  video_rgb,
        output  wire            video_rgb_clock,
        output  wire            video_rgb_clock_90,
        output  wire            video_de,
        output  wire            video_skip,
        output  wire            video_vs,
        output  wire            video_hs,

        output  wire            audio_mclk,
        input   wire            audio_adc,
        output  wire            audio_dac,
        output  wire            audio_lrck,

        ///////////////////////////////////////////////////
        // bridge bus connection
        // synchronous to clk_74a
        output  wire            bridge_endian_little,
        input   wire    [31:0]  bridge_addr,
        input   wire            bridge_rd,
        output  reg     [31:0]  bridge_rd_data,
        input   wire            bridge_wr,
        input   wire    [31:0]  bridge_wr_data,

        ///////////////////////////////////////////////////
        // controller data
        //
        // key bitmap:
        //   [0]    dpad_up
        //   [1]    dpad_down
        //   [2]    dpad_left
        //   [3]    dpad_right
        //   [4]    face_a
        //   [5]    face_b
        //   [6]    face_x
        //   [7]    face_y
        //   [8]    trig_l1
        //   [9]    trig_r1
        //   [10]   trig_l2
        //   [11]   trig_r2
        //   [12]   trig_l3
        //   [13]   trig_r3
        //   [14]   face_select
        //   [15]   face_start
        //   [28:16] <unused>
        //   [31:29] type
        // joy values - unsigned
        //   [ 7: 0] lstick_x
        //   [15: 8] lstick_y
        //   [23:16] rstick_x
        //   [31:24] rstick_y
        // trigger values - unsigned
        //   [ 7: 0] ltrig
        //   [15: 8] rtrig
        //
        input   wire    [31:0]  cont1_key,
        input   wire    [31:0]  cont2_key,
        input   wire    [31:0]  cont3_key,
        input   wire    [31:0]  cont4_key,
        input   wire    [31:0]  cont1_joy,
        input   wire    [31:0]  cont2_joy,
        input   wire    [31:0]  cont3_joy,
        input   wire    [31:0]  cont4_joy,
        input   wire    [15:0]  cont1_trig,
        input   wire    [15:0]  cont2_trig,
        input   wire    [15:0]  cont3_trig,
        input   wire    [15:0]  cont4_trig

    );

    // not using the IR port, so turn off both the LED, and
    // disable the receive circuit to save power
    assign port_ir_tx = 0;
    assign port_ir_rx_disable = 1;

    // bridge endianness
    assign bridge_endian_little = 0;

    // cart is unused, so set all level translators accordingly
    // directions are 0:IN, 1:OUT
    // assign cart_tran_bank3 = 8'hzz;
    // assign cart_tran_bank3_dir = 1'b0;
    // assign cart_tran_bank2 = 8'hzz;
    // assign cart_tran_bank2_dir = 1'b0;
    // assign cart_tran_bank1 = 8'hzz;
    // assign cart_tran_bank1_dir = 1'b0;
    // assign cart_tran_bank0 = 4'hf;
    // assign cart_tran_bank0_dir = 1'b1;
    // assign cart_tran_pin30 = 1'b0;      // reset or cs2, we let the hw control it by itself
    // assign cart_tran_pin30_dir = 1'bz;
    // assign cart_pin30_pwroff_reset = 1'b0;  // hardware can control this
    // assign cart_tran_pin31 = 1'bz;      // input
    // assign cart_tran_pin31_dir = 1'b0;  // input

    // link port is input only
    // assign port_tran_so = 1'bz;
    // assign port_tran_so_dir = 1'b0;     // SO is output only
    // assign port_tran_si = 1'bz;
    // assign port_tran_si_dir = 1'b0;     // SI is input only
    // assign port_tran_sck = 1'bz;
    // assign port_tran_sck_dir = 1'b0;    // clock direction can change
    // assign port_tran_sd = 1'bz;
    // assign port_tran_sd_dir = 1'b0;     // SD is input and not used

    // tie off the rest of the pins we are not using
    assign cram0_a = 'h0;
    assign cram0_dq = {16{1'bZ}};
    assign cram0_clk = 0;
    assign cram0_adv_n = 1;
    assign cram0_cre = 0;
    assign cram0_ce0_n = 1;
    assign cram0_ce1_n = 1;
    assign cram0_oe_n = 1;
    assign cram0_we_n = 1;
    assign cram0_ub_n = 1;
    assign cram0_lb_n = 1;

    assign cram1_a = 'h0;
    assign cram1_dq = {16{1'bZ}};
    assign cram1_clk = 0;
    assign cram1_adv_n = 1;
    assign cram1_cre = 0;
    assign cram1_ce0_n = 1;
    assign cram1_ce1_n = 1;
    assign cram1_oe_n = 1;
    assign cram1_we_n = 1;
    assign cram1_ub_n = 1;
    assign cram1_lb_n = 1;

    assign dram_a = 'h0;
    assign dram_ba = 'h0;
    assign dram_dq = {16{1'bZ}};
    assign dram_dqm = 'h0;
    assign dram_clk = 'h0;
    assign dram_cke = 'h0;
    assign dram_ras_n = 'h1;
    assign dram_cas_n = 'h1;
    assign dram_we_n = 'h1;

    //assign sram_a = 'h0;
    //assign sram_dq = {16{1'bZ}};
    //assign sram_oe_n  = 1;
    //assign sram_we_n  = 1;
    //assign sram_ub_n  = 1;
    //assign sram_lb_n  = 1;

    assign dbg_tx = 1'bZ;
    assign user1 = 1'bZ;
    assign aux_scl = 1'bZ;
    assign vpll_feed = 1'bZ;

    //
    // host/target command handler
    //
    wire            reset_n /* synthesis keep */;                // driven by host commands, can be used as core-wide reset
    wire    [31:0]  cmd_bridge_rd_data;

    // bridge host commands
    // synchronous to clk_74a
    wire            status_boot_done = pll_core_locked;
    wire            status_setup_done = pll_core_locked; // rising edge triggers a target command
    wire            status_running = reset_n; // we are running as soon as reset_n goes high

    wire            dataslot_requestread;
    wire    [15:0]  dataslot_requestread_id;
    wire            dataslot_requestread_ack = 1;
    wire            dataslot_requestread_ok = 1;

    wire            dataslot_requestwrite;
    wire    [15:0]  dataslot_requestwrite_id;
    wire    [31:0]  dataslot_requestwrite_size;
    wire            dataslot_requestwrite_ack = 1;
    wire            dataslot_requestwrite_ok = 1;

    wire            dataslot_update;
    wire    [15:0]  dataslot_update_id;
    wire    [31:0]  dataslot_update_size;

    wire            dataslot_allcomplete;

    wire     [31:0] rtc_epoch_seconds;
    wire     [31:0] rtc_date_bcd;
    wire     [31:0] rtc_time_bcd;
    wire            rtc_valid;

    wire            savestate_supported;
    wire    [31:0]  savestate_addr;
    wire    [31:0]  savestate_size;
    wire    [31:0]  savestate_maxloadsize;

    wire            savestate_start;
    wire            savestate_start_ack;
    wire            savestate_start_busy;
    wire            savestate_start_ok;
    wire            savestate_start_err;

    wire            savestate_load;
    wire            savestate_load_ack;
    wire            savestate_load_busy;
    wire            savestate_load_ok;
    wire            savestate_load_err;

    wire            osnotify_inmenu;

    // bridge target commands
    // synchronous to clk_74a

    reg             target_dataslot_read;
    reg             target_dataslot_write;

    wire            target_dataslot_ack;
    wire            target_dataslot_done;
    wire    [2:0]   target_dataslot_err;

    reg     [15:0]  target_dataslot_id;
    reg     [31:0]  target_dataslot_slotoffset;
    reg     [31:0]  target_dataslot_bridgeaddr;
    reg     [31:0]  target_dataslot_length;

    // bridge data slot access
    // synchronous to clk_74a

    wire    [9:0]   datatable_addr;
    wire            datatable_wren;
    wire    [31:0]  datatable_data;
    wire    [31:0]  datatable_q;

    core_bridge_cmd icb (

                        .clk                ( clk_74a ),
                        .reset_n            ( reset_n ),

                        .bridge_endian_little   ( bridge_endian_little ),
                        .bridge_addr            ( bridge_addr ),
                        .bridge_rd              ( bridge_rd ),
                        .bridge_rd_data         ( cmd_bridge_rd_data ),
                        .bridge_wr              ( bridge_wr ),
                        .bridge_wr_data         ( bridge_wr_data ),

                        .status_boot_done       ( status_boot_done ),
                        .status_setup_done      ( status_setup_done ),
                        .status_running         ( status_running ),

                        .dataslot_requestread       ( dataslot_requestread ),
                        .dataslot_requestread_id    ( dataslot_requestread_id ),
                        .dataslot_requestread_ack   ( dataslot_requestread_ack ),
                        .dataslot_requestread_ok    ( dataslot_requestread_ok ),

                        .dataslot_requestwrite      ( dataslot_requestwrite ),
                        .dataslot_requestwrite_id   ( dataslot_requestwrite_id ),
                        .dataslot_requestwrite_size ( dataslot_requestwrite_size ),
                        .dataslot_requestwrite_ack  ( dataslot_requestwrite_ack ),
                        .dataslot_requestwrite_ok   ( dataslot_requestwrite_ok ),

                        .dataslot_update            ( dataslot_update ),
                        .dataslot_update_id         ( dataslot_update_id ),
                        .dataslot_update_size       ( dataslot_update_size ),

                        .dataslot_allcomplete   ( dataslot_allcomplete ),

                        .rtc_epoch_seconds      ( rtc_epoch_seconds ),
                        .rtc_date_bcd           ( rtc_date_bcd ),
                        .rtc_time_bcd           ( rtc_time_bcd ),
                        .rtc_valid              ( rtc_valid ),

                        .savestate_supported    ( savestate_supported ),
                        .savestate_addr         ( savestate_addr ),
                        .savestate_size         ( savestate_size ),
                        .savestate_maxloadsize  ( savestate_maxloadsize ),

                        .savestate_start        ( savestate_start ),
                        .savestate_start_ack    ( savestate_start_ack ),
                        .savestate_start_busy   ( savestate_start_busy ),
                        .savestate_start_ok     ( savestate_start_ok ),
                        .savestate_start_err    ( savestate_start_err ),

                        .savestate_load         ( savestate_load ),
                        .savestate_load_ack     ( savestate_load_ack ),
                        .savestate_load_busy    ( savestate_load_busy ),
                        .savestate_load_ok      ( savestate_load_ok ),
                        .savestate_load_err     ( savestate_load_err ),

                        .osnotify_inmenu        ( osnotify_inmenu ),

                        .target_dataslot_read       ( target_dataslot_read ),
                        .target_dataslot_write      ( target_dataslot_write ),

                        .target_dataslot_ack        ( target_dataslot_ack ),
                        .target_dataslot_done       ( target_dataslot_done ),
                        .target_dataslot_err        ( target_dataslot_err ),

                        .target_dataslot_id         ( target_dataslot_id ),
                        .target_dataslot_slotoffset ( target_dataslot_slotoffset ),
                        .target_dataslot_bridgeaddr ( target_dataslot_bridgeaddr ),
                        .target_dataslot_length     ( target_dataslot_length ),

                        .datatable_addr         ( datatable_addr ),
                        .datatable_wren         ( datatable_wren ),
                        .datatable_data         ( datatable_data ),
                        .datatable_q            ( datatable_q )

                    );

    //! ------------------------------------------------------------------------------------
    //! @IP Core
    //! ------------------------------------------------------------------------------------
    //!
    //! ------------------------------------------------------------------------------------
    //! Interactions and Dip Switches
    //! ------------------------------------------------------------------------------------
    //! Pocket Bridge
    always @(*) begin
        casex(bridge_addr)
            32'hF0000000: begin bridge_rd_data <= bridge_read_buffer; end //! Reset
            32'hF1000000: begin bridge_rd_data <= bridge_read_buffer; end //! DIP
            32'hF2000000: begin bridge_rd_data <= bridge_read_buffer; end //! MOD
            32'hF3000000: begin bridge_rd_data <= bridge_read_buffer; end //! Scanlines
            32'hF7000000: begin bridge_rd_data <= bridge_read_buffer; end //! Analogizer
            32'hF8xxxxxx: begin bridge_rd_data <= cmd_bridge_rd_data; end //! Pocket Bridge
            default:      begin bridge_rd_data <= 0; end
        endcase
    end
    //! ------------------------------------------------------------------------------------
    reg  [31:0] bridge_read_buffer;
    reg  [31:0] reset_timer;
    reg         core_reset = 1;
    reg         core_reset_reg = 1;
    wire        core_reset_s /* synthesis keep */;
    reg         temp_reset;

    reg  [31:0] def_dsw = 0;
    reg  [31:0] def_mod = 0;
    reg  [31:0] def_scnl = 0;

    wire [31:0] def_dsw_s, def_mod_s, def_scnl_s;

    always @(posedge clk_74a) begin
        temp_reset <= 0;                                                                                      //! Always default this to zero
        if(bridge_wr && bridge_addr == 32'hF0000000) begin temp_reset <= 1;                               end //! Reset Core Command
        if(bridge_wr && bridge_addr == 32'hF1000000) begin def_dsw  <= bridge_wr_data; temp_reset <= 1;   end //! DIP Switches
        if(bridge_wr && bridge_addr == 32'hF2000000) begin def_mod  <= bridge_wr_data;                    end //! Core Mode Selection
        if(bridge_wr && bridge_addr == 32'hF3000000) begin def_scnl <= bridge_wr_data;                    end //! Scanlines
        if(bridge_wr && bridge_addr == 32'hF7000000) begin analogizer_settings  <=  bridge_wr_data[13:0]; end //! Analogizer settings
        if(bridge_rd) begin
            casex(bridge_addr)
                32'hF0000000: begin bridge_read_buffer <= core_reset_reg;              end
                32'hF1000000: begin bridge_read_buffer <= def_dsw;                     end
                32'hF2000000: begin bridge_read_buffer <= def_mod;                     end
                32'hF3000000: begin bridge_read_buffer <= def_scnl;                    end
                32'hF7000000: begin bridge_read_buffer <= {18'h0,analogizer_settings}; end
            endcase
        end
    end

    always @(posedge clk_74a) begin
        if(temp_reset) begin
            reset_timer <= 32'd8000;
            core_reset <= 0;
        end
        else begin
            if (reset_timer == 32'h0) begin
                core_reset <= 1;
            end
            else begin
                reset_timer <= reset_timer - 1;
                core_reset <= 0;
            end
        end
    end

    synch_3               crst(core_reset, core_reset_s, clk_sys);
    synch_3 #(.WIDTH(32)) sdsw(def_dsw, def_dsw_s, clk_sys);
    synch_3 #(.WIDTH(32)) smod(def_mod, def_mod_s, clk_sys);
    synch_3 #(.WIDTH(32)) sscl(def_scnl, def_scnl_s, clk_sys);
    synch_3 #(.WIDTH(3)) res_s(MODE[2:0], vid_preset_s, clk_vid);
	 
    wire [7:0] DSW0  = def_dsw_s[7:0];
    wire [7:0] DSW1  = def_dsw_s[15:8];
    wire [7:0] DSW2  = def_dsw_s[23:16];
    wire [7:0] MODE  = def_mod_s[7:0];
    wire       RESET = ~(reset_n && core_reset_s) /* synthesis keep */;
	 wire [2:0] vid_preset_s;
	
    /*[ANALOGIZER_HOOK_BEGIN]*/
    //Pocket Menu settings
    reg [13:0] analogizer_settings = 0;
    wire [13:0] analogizer_settings_s;

    synch_3 #(.WIDTH(14)) sync_analogizer(analogizer_settings, analogizer_settings_s, clk_sys);

    always @(*) begin
        snac_game_cont_type   = analogizer_settings_s[4:0];
        snac_cont_assignment  = analogizer_settings_s[9:6];
        analogizer_video_type = analogizer_settings_s[13:10];
    end

     //switch between Analogizer SNAC and Pocket Controls for P1-P4 (P3,P4 when uses PCEngine Multitap)
  wire [15:0] p1_btn, p2_btn, p3_btn, p4_btn;
  reg [15:0] p1_controls, p2_controls, p3_controls, p4_controls;
  wire [31:0] p1_stick, p2_stick;
  reg [31:0] p1_joy, p2_joy;

  always @(posedge clk_sys) begin
    if(snac_game_cont_type == 5'h0) begin //SNAC is disabled
                p1_controls <= cont1_key;
				p1_joy      <= cont1_joy;
                p2_controls <= cont2_key;
                p2_joy      <= cont2_joy;

    end
    else begin
            case(snac_cont_assignment)
      4'h0:    begin 
                  p1_controls <= p1_btn;
                  p2_controls <= cont2_key;
                  p1_joy      <= p1_stick;
                  p2_joy      <= (cont2_key[31:28] == 4'h3) ? cont2_joy : 32'h80808080; //0x80 analog joy neutral position
                end
      4'h1:    begin 
                  p1_controls <= cont1_key;
                  p2_controls <= p1_btn;       
                  p1_joy      <= (cont1_key[31:28] == 4'h3) ? cont1_joy : 32'h80808080; //0x80 analog joy neutral position
                  p2_joy      <= p1_stick;
                end
      4'h2:    begin
                  p1_controls <= p1_btn;
                  p2_controls <= p2_btn;
                  p1_joy      <= p1_stick;
                  p2_joy      <= p2_stick;
                end
      4'h3:    begin
                  p1_controls <= p2_btn;
                  p2_controls <= p1_btn;
                  p1_joy      <= p2_stick;
                  p2_joy      <= p1_stick;
                end
      default: begin
                  p1_controls <= cont1_key;
                  p2_controls <= cont2_key;
                  p1_joy <= (cont1_key[31:28] == 4'h3) ? cont1_joy : 32'h80808080; //0x80 analog joy neutral position
                  p2_joy <= (cont2_key[31:28] == 4'h3) ? cont2_joy : 32'h80808080; //0x80 analog joy neutral position

                end
      endcase
    end
  end

    //*** Analogizer Interface V1.1 ***
    reg analogizer_ena;
    reg [3:0] analogizer_video_type;
    reg [4:0] snac_game_cont_type /* synthesis keep */;
    reg [3:0] snac_cont_assignment /* synthesis keep */;

    //wire SYNC /* synthesis keep */;
    // wire ANALOGIZER_DE = ~(slapfight_hb | slapfight_vb) /* synthesis keep */;

// SET PAL and NTSC TIMING and pass through status bits. ** YC must be enabled in the qsf file **
wire [39:0] CHROMA_PHASE_INC;
wire PALFLAG;

// adjusted for 48_000_000 video clock
localparam [39:0] NTSC_PHASE_INC = 40'd81994819784; // ((NTSC_REF * 2^40) / CLK_VIDEO_NTSC)
localparam [39:0] PAL_PHASE_INC  = 40'd101558653516; // ((PAL_REF * 2^40) / CLK_VIDEO_PAL)

// Send Parameters to Y/C Module
assign CHROMA_PHASE_INC = (analogizer_video_type == 4'h4) || (analogizer_video_type == 4'hC) ? PAL_PHASE_INC : NTSC_PHASE_INC; 
assign PALFLAG = (analogizer_video_type == 4'h4) || (analogizer_video_type == 4'hC); 

//Csync = (slapfight_hs & slapfight_vs) Based on Schematics
// synch_3 #(.WIDTH(30)) sync_video({ slapfight_rgb24,slapfight_hs,slapfight_vs,~(slapfight_hs ^ slapfight_vs),slapfight_hb,slapfight_vb,ANALOGIZER_DE}, {color_s,sync_s,blank_s}, clk_sys);
// wire [23:0] color_s; //RGB24
// wire [2:0] sync_s;  //h_sync, v_sync, CSYNC
// wire [2:0] blank_s; //h_blank, v_blank, BLANKn
// wire clkvid_s /* synthesis keep */;
// synch_3 #(.WIDTH(1)) sync_clkvid({clk_vid}, {clkvid_s}, clk_sys);

reg [2:0] fx /* synthesis preserve */;
always @(posedge clk_sys) begin
    case (analogizer_video_type)
        4'd5, 4'd13:    fx <= 3'd0; //SC  0%
        4'd6, 4'd14:    fx <= 3'd2; //SC  50%
        4'd7, 4'd15:    fx <= 3'd4; //hq2x
        default:        fx <= 3'd0;
    endcase
end


//video fix
wire hs_fix,vs_fix;
sync_fix sync_v(clk_sys, slapfight_hs, hs_fix);
sync_fix sync_h(clk_sys, slapfight_vs, vs_fix);

reg [23:0] RGB_fix;

reg CE,HS,VS,HBL,VBL;
always @(posedge clk_sys) begin
	reg old_ce;
	old_ce <= clk_vid;
	CE <= 0;
	if(~old_ce & clk_vid) begin
		CE <= 1;
		HS <= hs_fix;
		if(~HS & hs_fix) VS <= vs_fix;

		RGB_fix <= slapfight_rgb24;
		HBL <= slapfight_hb;
		if(HBL & ~slapfight_hb) VBL <= slapfight_vb;
	end
end

wire ANALOGIZER_BLANKn = ~(HBL | VBL) /* synthesis keep */;
wire ANALOGIZER_CSYNC = ~(HS ^ VS);

//48_000_000
//debug port:
assign port_tran_so_dir = 1'b1;     // SO is output only, check SNAC USB D- or TX- for TX data
assign port_tran_si_dir = 1'b1;      
assign port_tran_sck_dir = 1'b1;
assign port_tran_sd_dir = 1'b1; 

//Rumble FX based on game
    //MODE = 8'd1 //Tiger Heli
    wire [7:0] snd_fx_cmd;
    wire snd_fx_trig; //use rising edge to register snd_fx_cmd
    // insert coin			0x91
    // start song           0x13?
    // killed				0xFE 0x11
    // fire					0x0B
    // falling bomb			0x03
    // hit/                 0x09
    // sploding bomb        0x09 0x09
openFPGA_Pocket_Analogizer #(.MASTER_CLK_FREQ(48_000_000), .LINE_LENGTH(280)) analogizer (
	.i_clk(clk_sys),
	.i_rst((RESET)), //i_rst is active high
	.i_ena(1'b1),
	//Video interface
    .video_clk(clk_sys),
	.analog_video_type(analogizer_video_type),
    .R(RGB_fix[23:16]),
	.G(RGB_fix[15:8] ),
	.B(RGB_fix[7:0]  ),
    .Hblank(HBL),
    .Vblank(VBL),
    .BLANKn(ANALOGIZER_BLANKn),
    .Hsync(HS),
	.Vsync(VS),
    .Csync(ANALOGIZER_CSYNC), //composite SYNC on HSync.
    // .R(slapfight_rgb24[23:16]),
	// .G(slapfight_rgb24[15:8] ),
	// .B(slapfight_rgb24[7:0]  ),
    // .Hblank(slapfight_hb),
    // .Vblank(slapfight_vb),
    // .BLANKn(ANALOGIZER_DE),
    // .Hsync(slapfight_hs),
	// .Vsync(slapfight_vs),
    // .Csync((~slapfight_hs & ~slapfight_vs)), //composite SYNC on HSync.
    //Video Y/C Encoder interface
    .CHROMA_PHASE_INC(CHROMA_PHASE_INC),
    .PALFLAG(PALFLAG),
    //Video SVGA Scandoubler interface
    .ce_pix(CE),
    .scandoubler(1'b1), //logic for disable/enable the scandoubler
	.fx(fx), //0 disable, 1 scanlines 25%, 2 scanlines 50%, 3 scanlines 75%, 4 hq2x
	//SNAC interface
	.conf_AB((snac_game_cont_type >= 5'd16)),              //0 conf. A(default), 1 conf. B (see graph above)
	.game_cont_type(snac_game_cont_type), //0-15 Conf. A, 16-31 Conf. B
	.p1_btn_state(p1_btn),
    .p1_joy_state(p1_stick),
	.p2_btn_state(p2_btn),  
    .p2_joy_state(p2_stick),
    .p3_btn_state(p3_btn),
	.p4_btn_state(p4_btn),  
    .i_VIB_SW1(p1_btn[5:4]), .i_VIB_DAT1(8'hb0), .i_VIB_SW2(p2_btn[5:4]), .i_VIB_DAT2(8'hb0),

	//Pocket Analogizer IO interface to the Pocket cartridge port
	.cart_tran_bank2(cart_tran_bank2),
	.cart_tran_bank2_dir(cart_tran_bank2_dir),
	.cart_tran_bank3(cart_tran_bank3),
	.cart_tran_bank3_dir(cart_tran_bank3_dir),
	.cart_tran_bank1(cart_tran_bank1),
	.cart_tran_bank1_dir(cart_tran_bank1_dir),
	.cart_tran_bank0(cart_tran_bank0),
	.cart_tran_bank0_dir(cart_tran_bank0_dir),
	.cart_tran_pin30(cart_tran_pin30),
	.cart_tran_pin30_dir(cart_tran_pin30_dir),
	.cart_pin30_pwroff_reset(cart_pin30_pwroff_reset),
	.cart_tran_pin31(cart_tran_pin31),
	.cart_tran_pin31_dir(cart_tran_pin31_dir),
	//debug {PSX_ATT1,PSX_CLK,PSX_CMD,PSX_DAT}
    .DBG_TX({port_tran_so, port_tran_si,port_tran_sck,port_tran_sd}),
	.o_stb()
);
/*[ANALOGIZER_HOOK_END]*/


    //! ------------------------------------------------------------------------------------
    //! Data I/O
    //! ------------------------------------------------------------------------------------
    wire        ioctl_download;
    wire  [7:0] ioctl_index;
    wire        ioctl_wr;
    wire [24:0] ioctl_addr;
    wire  [7:0] ioctl_dout;

    data_loader #(.ADDRESS_SIZE(25))
                data_loader_dut (
                    .clk_74a              ( clk_74a ),
                    .clk_memory           ( clk_sys ),

                    .bridge_wr            ( bridge_wr            ),
                    .bridge_endian_little ( bridge_endian_little ),
                    .bridge_addr          ( bridge_addr          ),
                    .bridge_wr_data       ( bridge_wr_data       ),

                    .write_en             ( ioctl_wr   ),
                    .write_addr           ( ioctl_addr ),
                    .write_data           ( ioctl_dout )
                );

    //! ------------------------------------------------------------------------------------
    //! Gamepad
    //! ------------------------------------------------------------------------------------
    wire osnotify_inmenu_s;
    synch_3 s2(osnotify_inmenu, osnotify_inmenu_s, clk_sys);
    //! Player 1 ---------------------------------------------------------------------------
    wire p1_coin,  p1_start;
    reg p1_up,    p1_down,  p1_left,  p1_right;
    wire p1u, p1d, p1l, p1r;
    wire p1_up_analog, p1_down_analog, p1_left_analog, p1_right_analog;
    wire p1_fire1, p1_fire2;

    //use PSX Dual Shock style left analog stick as directional pad
    wire is_analog_input = (snac_game_cont_type == 5'h13);

    //using left analog joypad
    assign p1_up_analog   =  (p1_joy[15:8] < 8'h40) ? 1'b1 : 1'b0; //analog range UP 0x00 Idle 0x7F DOWN 0xFF, DEADZONE +- 0x15
    assign p1_down_analog =  (p1_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0; 
    assign p1_left_analog =  (p1_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0; //analog range LEFT 0x00 Idle 0x7F RIGHT 0xFF, DEADZONE +- 0x15
    assign p1_right_analog = (p1_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

    always @(posedge clk_sys) begin
        p1_up    <= (is_analog_input) ? p1_up_analog    : p1u;
        p1_down  <= (is_analog_input) ? p1_down_analog  : p1d;
        p1_left  <= (is_analog_input) ? p1_left_analog  : p1l;
        p1_right <= (is_analog_input) ? p1_right_analog : p1r;
    end

    pocket_gamepad
        player1 (
            .iCLK   ( clk_sys   ),
            .iJOY   ( p1_controls ),

            .PAD_U  ( p1u ),
            .PAD_D  ( p1d ),
            .PAD_L  ( p1l ),
            .PAD_R  ( p1r ),

            .BTN_B  ( p1_fire2 ),
            .BTN_A  ( p1_fire1 ),

            .BTN_SE ( p1_coin  ),
            .BTN_ST ( p1_start )
        );
    //! Player 2 ---------------------------------------------------------------------------
    wire p2_coin, p2_start;
    reg p2_up, p2_down, p2_left, p2_right;
    wire p2_fire1, p2_fire2;
    wire p2u, p2d, p2l, p2r;
    wire p2_up_analog, p2_down_analog, p2_left_analog, p2_right_analog;

    
    //using left analog joypad
    assign p2_up_analog   = (p2_joy[15:8] < 8'h40) ? 1'b1 : 1'b0;
    assign p2_down_analog = (p2_joy[15:8] > 8'hC0) ? 1'b1 : 1'b0;
    assign p2_left_analog = (p2_joy[7:0]  < 8'h40) ? 1'b1 : 1'b0;
    assign p2_right_analog = (p2_joy[7:0]  > 8'hC0) ? 1'b1 : 1'b0;

    always @(posedge clk_sys) begin
        p2_up    <= (is_analog_input) ? p2_up_analog    : p2u;
        p2_down  <= (is_analog_input) ? p2_down_analog  : p2d;
        p2_left  <= (is_analog_input) ? p2_left_analog  : p2l;
        p2_right <= (is_analog_input) ? p2_right_analog : p2r;
    end

    pocket_gamepad
        player2 (
            .iCLK   ( clk_sys   ),
            .iJOY   ( p2_controls ),

            .PAD_U  ( p2u ),
            .PAD_D  ( p2d ),
            .PAD_L  ( p2l ),
            .PAD_R  ( p2r ),

            .BTN_B  ( p2_fire2 ),
            .BTN_A  ( p2_fire1 ),

            .BTN_SE ( p2_coin  ),
            .BTN_ST ( p2_start )
        );

    //! ------------------------------------------------------------------------------------
    wire m_start1p = p1_start;
    wire m_start2p = p2_start;
    wire m_coin    = p1_coin | p2_coin;

    wire m_right  = p1_right | p2_right;
    wire m_left   = p1_left  | p2_left;
    wire m_down   = p1_down  | p2_down;
    wire m_up     = p1_up    | p2_up;
    wire m_shoot  = p1_fire1 | p2_fire1;
    wire m_shoot2 = p1_fire2 | p2_fire2;

    //! ------------------------------------------------------------------------------------
    //! A/V Signals
    //! ------------------------------------------------------------------------------------
    wire signed [15:0] slapfight_snd_l; //! Audio L
    wire signed [15:0] slapfight_snd_r; //! Audio R
    //! ------------------------------------------------------------------------------------
    wire        slapfight_hs, slapfight_vs;                    //! Sync H/V
    wire        slapfight_hb, slapfight_vb;                    //! Blank H/V
    wire        slapfight_de = ~(slapfight_hb | slapfight_vb); //! Data Enable
    wire [11:0] slapfight_rgb;                                 //! RGB 444
    wire [23:0] slapfight_rgb24 = { slapfight_rgb[11:8], 4'h0, slapfight_rgb[7:4], 4'h0, slapfight_rgb[3:0], 4'h0 };

    //! ------------------------------------------------------------------------------------
    //! Core RTL
    //! ------------------------------------------------------------------------------------

   wire [8:0] control_panel = ~{m_coin,m_start2p,m_start1p,m_shoot2,m_shoot,m_up,m_down,m_left,m_right};
   wire core_pix_clk /* synthesis keep */;
 
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!INSTANTIATE CORE RTL HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	slapfight_fpga slapcore
	(
		.ram_clk(clk_74a),
		.clk_master(clk_sys),
		.pcb(MODE),
		
        //.core_pix_clk(core_pix_clk),
		.RED(slapfight_rgb[11:8]),
		.GREEN(slapfight_rgb[7:4]),
		.BLUE(slapfight_rgb[3:0]),
		
		.H_SYNC(slapfight_hs), //hs
		.V_SYNC(slapfight_vs), //vs
		.H_BLANK(slapfight_hb),
		.V_BLANK(slapfight_vb),
		.RESET_n(~RESET),
		.pause(osnotify_inmenu_s),
		
		.CONTROLS(control_panel),
		
		.DIP1(DSW0), //pocket dip switch - how do they work?
		.DIP2(DSW1),
		
		.dn_addr(ioctl_addr),
		.dn_data(ioctl_dout),
		.dn_wr(ioctl_wr), //& rom_download

		.SRAM_ADDR(sram_a), //! Address Out
		.SRAM_DQ(sram_dq),   //! Data In/Out
		.SRAM_OE_N(sram_oe_n), //! Output Enable
		.SRAM_WE_N(sram_we_n), //! Write Enable
		.SRAM_UB_N(sram_ub_n), //! Upper Byte Mask
		.SRAM_LB_N(sram_lb_n), //! Lower Byte Mask			
		
		.audio_l(slapfight_snd_l),
		.audio_r(slapfight_snd_r),
		
		.hs_address(),		//hiscore save stuff removed
		.hs_data_out(),
		.hs_data_in(),
		.hs_write(),
        //Analogizer experimental sound fx capture for rumble fx
        .snd_fx_cmd(snd_fx_cmd),
	    .snd_fx_trig(snd_fx_trig)
	);

    //! ------------------------------------------------------------------------------------
    //! Pocket Video
    //! ------------------------------------------------------------------------------------
    wire [23:0] s_video_rgb /* synthesis keep */;
    wire        s_video_hs, s_video_vs, s_video_de /* synthesis keep */;
    wire  [3:0] s_scanlines = def_scnl_s[3:0];

    scanlines scnl
              (
                  .iPCLK      ( clk_vid     ),
                  .iSCANLINES ( s_scanlines ),

                  .iRGB       ( slapfight_rgb24 ),
                  .iVS        ( slapfight_vs    ),
                  .iHS        ( slapfight_hs    ),
                  .iDE        ( slapfight_de    ),

                  .oRGB       ( s_video_rgb ),
                  .oVS        ( s_video_vs  ),
                  .oHS        ( s_video_hs  ),
                  .oDE        ( s_video_de  )
              );


    pocket_video
        pocket_video_dut (
            .iPCLK     ( clk_vid       ),
            .iPCLK_90D ( clk_vid_90deg ),
				
				.iPRESET   ( vid_preset_s ),
		  
            .iRGB      ( s_video_rgb ),
            .iVS       ( s_video_vs  ),
            .iHS       ( s_video_hs  ),
            .iDE       ( s_video_de  ),

            .oRGB      ( video_rgb ),
            .oVS       ( video_vs  ),
            .oHS       ( video_hs  ),
            .oDE       ( video_de  ),

            .oPCLK     ( video_rgb_clock    ),
            .oPCLK_90D ( video_rgb_clock_90 )
        );

    //! ------------------------------------------------------------------------------------
    //! Audio
    //! ------------------------------------------------------------------------------------
    sound_i2s #
        (
            .CHANNEL_WIDTH( 16 ),
            .SIGNED_INPUT (  1 )
        )
        sound_i2s (
            .clk_74a    ( clk_74a ),
            .clk_audio  ( clk_sys ),
            .audio_l    ( slapfight_snd_l[15:0] ),
            .audio_r    ( slapfight_snd_r[15:0] ),

            .audio_mclk ( audio_mclk ),
            .audio_dac  ( audio_dac  ),
            .audio_lrck ( audio_lrck )
        );

    //! ------------------------------------------------------------------------------------
    //! Clocks
    //! ------------------------------------------------------------------------------------
    wire clk_sys /* synthesis keep */;        //! Core: 48.000Mhz
    wire clk_vid /* synthesis keep */;        //! Video: 6.000Mhz
    wire clk_vid_90deg;  //! Video: 6.000Mhz @ 90deg Phase Shift
    wire pll_core_locked;

    mf_pllbase pll (
            .refclk   ( clk_74a ),
            .rst      ( 0 ),

            .outclk_0 ( clk_sys         ),
            .outclk_1 ( clk_vid         ),
            .outclk_2 ( clk_vid_90deg   ),
            //.outclk_3 ( clk_vid         ),
            //.outclk_4 ( clk_vid_90deg   ),
            .locked   ( pll_core_locked )
        );
    //! @end

endmodule


module sync_fix
(
	input clk,
	
	input sync_in,
	output sync_out
);

assign sync_out = sync_in ^ pol;

reg pol;
always @(posedge clk) begin
	reg [31:0] cnt;
	reg s1,s2;

	s1 <= sync_in;
	s2 <= s1;
	cnt <= s2 ? (cnt - 1) : (cnt + 1);

	if(~s2 & s1) begin
		cnt <= 0;
		pol <= cnt[31];
	end
end

endmodule