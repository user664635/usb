module main(
	input clkin,
	inout usb_dxp_io, usb_dxn_io,
	inout usb_term_dp_io, usb_term_dn_io,
	input usb_rxdp_i, usb_rxdn_i,	
	output usb_pullup_en_o
	);

	wire clk24,clk60,clk480,clk_usb_lock,reset;
	wire [7:0]  phy_datain    ;
	wire [7:0]  phy_dataout   ;
	wire [1:0]  phy_xcvrselect ;
	wire [1:0]  phy_opmode ;
	wire [1:0]  phy_linestate ;
	wire phy_termselect,phy_txvalid,phy_txready,phy_rxvalid,phy_rxactive,phy_rxerror,phy_clkout;
	wire usbrst_o,highspeed_o,suspend_o,online_o,sof_o;
	wire txact_o,txpop_o,rxact_o,rxval_o;
	wire [3:0]endpt_o;
	wire [7:0]rxdat_o;
	wire [7:0]txdat_i;
	wire txval_i,txcork_i,rxrdy_i;
	wire [11:0]txdat_len_i;
	wire txpktfin_o,rxpktval_o,setup_o;
	wire inf_alter_i,inf_alter_o,inf_sel_o,inf_set_o;
	wire [15:0] descrom_raddr_o = 0;
	wire [7:0]  desc_index_o;
	wire [7:0]  desc_type_o;
	wire [7:0]  descrom_rdata_i;
	wire [15:0] desc_dev_addr_i;
	wire [15:0] desc_dev_len_i;
	wire [15:0] desc_qual_addr_i;
	wire [15:0] desc_qual_len_i;
	wire [15:0] desc_fscfg_addr_i;
	wire [15:0] desc_fscfg_len_i;
	wire [15:0] desc_hscfg_addr_i;
	wire [15:0] desc_hscfg_len_i;
	wire [15:0] desc_oscfg_addr_i;
	wire [15:0] desc_strlang_addr_i;
	wire [15:0] desc_strvendor_addr_i;
	wire [15:0] desc_strvendor_len_i;
	wire [15:0] desc_strproduct_addr_i;
	wire [15:0] desc_strproduct_len_i;
	wire [15:0] desc_strserial_addr_i;
	wire [15:0] desc_strserial_len_i;
	wire desc_have_strings_i;
	Gowin_PLL Gowin_PLL(
	    .clkout0(clk24), //output clkout0
	    .clkin(clkin) //input clkin
	);
	usb_PLL usb_PLL(
	    .clkout0(clk480), //output clkout0
	    .clkout1(clk60), //output clkout1
	    .lock(clk_usb_lock), //output lock
	    .clkin(clk24) //input clkin
	);
	assign reset = ~clk_usb_lock;

wire [7:0]  inf_alter_i;
wire [7:0]  inf_alter_o;
reg [7:0] inf1_alter,inf0_alter = 'b0;
assign inf_alter_i = (inf_sel_o == 0) ? inf0_alter :
                     (inf_sel_o == 1) ? inf1_alter : 8'd0;
always@(posedge clk60, posedge reset) begin
    if (reset) begin
        inf0_alter <= 'd0;
        inf1_alter <= 'd0;
    end
    else begin
        if (inf_set_o) begin
            if (inf_sel_o == 0) begin
                inf0_alter <= inf_alter_o;
            end
            else if (inf_sel_o == 1) begin
                inf1_alter <= inf_alter_o;
            end
        end
    end
end

	USB_Device_Controller_Top USB_Device_Controller_Top(
		.clk_i(clk60), //input clk_i
		.reset_i(reset), //input reset_i
		.usbrst_o(usbrst), //output usbrst_o
		.highspeed_o(highspeed_o), //output highspeed_o
		.suspend_o(suspend_o), //output suspend_o
		.online_o(online_o), //output online_o
		.txdat_i(txdat_i), //input [7:0] txdat_i
		.txval_i(txval_i), //input txval_i
		.txdat_len_i(txdat_len_i), //input [11:0] txdat_len_i
		.txiso_pid_i(4'b0011), //input [3:0] txiso_pid_i
		.txcork_i(txcork_i), //input txcork_i
		.txpop_o(txpop_o), //output txpop_o
		.txact_o(txact_o), //output txact_o
		.txpktfin_o(txpktfin_o), //output txpktfin_o
		.rxdat_o(rxdat_o), //output [7:0] rxdat_o
		.rxval_o(rxval_o), //output rxval_o
		.rxrdy_i(rxrdy_i), //input rxrdy_i
		.rxact_o(rxact_o), //output rxact_o
		.rxpktval_o(rxpktval_o), //output rxpktval_o
		.setup_o(setup_o), //output setup_o
		.endpt_o(endpt_o), //output [3:0] endpt_o
		.sof_o(sof_o), //output sof_o
		.inf_alter_i(inf_alter_i), //input [7:0] inf_alter_i
		.inf_alter_o(inf_alter_o), //output [7:0] inf_alter_o
		.inf_sel_o(inf_sel_o), //output [7:0] inf_sel_o
		.inf_set_o(inf_set_o), //output inf_set_o
		.descrom_raddr_o(descrom_raddr_o), //output [15:0] descrom_raddr_o
		.desc_index_o(desc_index_o), //output [7:0] desc_index_o
		.desc_type_o(desc_type_o), //output [7:0] desc_type_o
		.descrom_rdata_i(descrom_rdata_i), //input [7:0] descrom_rdata_i
		.desc_dev_addr_i(desc_dev_addr_i), //input [15:0] desc_dev_addr_i
		.desc_dev_len_i(desc_dev_len_i), //input [15:0] desc_dev_len_i
		.desc_qual_addr_i(desc_qual_addr_i), //input [15:0] desc_qual_addr_i
		.desc_qual_len_i(desc_qual_len_i), //input [15:0] desc_qual_len_i
		.desc_fscfg_addr_i(desc_fscfg_addr_i), //input [15:0] desc_fscfg_addr_i
		.desc_fscfg_len_i(desc_fscfg_len_i), //input [15:0] desc_fscfg_len_i
		.desc_hscfg_addr_i(desc_hscfg_addr_i), //input [15:0] desc_hscfg_addr_i
		.desc_hscfg_len_i(desc_hscfg_len_i), //input [15:0] desc_hscfg_len_i
		.desc_oscfg_addr_i(desc_oscfg_addr_i), //input [15:0] desc_oscfg_addr_i
		.desc_hidrpt_addr_i(16'd0), //input [15:0] desc_hidrpt_addr_i
		.desc_hidrpt_len_i(16'd0), //input [15:0] desc_hidrpt_len_i
		.desc_bos_addr_i(16'd0), //input [15:0] desc_bos_addr_i
		.desc_bos_len_i(16'd0), //input [15:0] desc_bos_len_i
//		.desc_hidrpt_addr_i(desc_hidrpt_addr_i), //input [15:0] desc_hidrpt_addr_i
//		.desc_hidrpt_len_i(desc_hidrpt_len_i), //input [15:0] desc_hidrpt_len_i
//		.desc_bos_addr_i(desc_bos_addr_i), //input [15:0] desc_bos_addr_i
//		.desc_bos_len_i(desc_bos_len_i), //input [15:0] desc_bos_len_i
		.desc_strlang_addr_i(desc_strlang_addr_i), //input [15:0] desc_strlang_addr_i
		.desc_strvendor_addr_i(desc_strvendor_addr_i), //input [15:0] desc_strvendor_addr_i
		.desc_strvendor_len_i(desc_strvendor_len_i), //input [15:0] desc_strvendor_len_i
		.desc_strproduct_addr_i(desc_strproduct_addr_i), //input [15:0] desc_strproduct_addr_i
		.desc_strproduct_len_i(desc_strproduct_len_i), //input [15:0] desc_strproduct_len_i
		.desc_strserial_addr_i(desc_strserial_addr_i), //input [15:0] desc_strserial_addr_i
		.desc_strserial_len_i(desc_strserial_len_i), //input [15:0] desc_strserial_len_i
		.desc_have_strings_i(desc_have_strings_i), //input desc_have_strings_i
		.utmi_dataout_o(phy_dataout), //output [7:0] utmi_dataout_o
		.utmi_txvalid_o(phy_txvalid), //output utmi_txvalid_o
		.utmi_txready_i(phy_txready), //input utmi_txready_i
		.utmi_datain_i(phy_datain), //input [7:0] utmi_datain_i
		.utmi_rxactive_i(phy_exactive), //input utmi_rxactive_i
		.utmi_rxvalid_i(phy_rxvalid), //input utmi_rxvalid_i
		.utmi_rxerror_i(phy_rxerror), //input utmi_rxerror_i
		.utmi_linestate_i(phy_linestate), //input [1:0] utmi_linestate_i
		.utmi_opmode_o(phy_opmode), //output [1:0] utmi_opmode_o
		.utmi_xcvrselect_o(phy_xcvrselect), //output [1:0] utmi_xcvrselect_o
		.utmi_termselect_o(phy_termselect), //output utmi_termselect_o
		.utmi_reset_o(phy_reset) //output utmi_reset_o
	);
usb_desc
#(

     .VENDORID    (16'h33AA)
    ,.PRODUCTID   (16'h0000)
    ,.VERSIONBCD  (16'h0100)
    ,.HSSUPPORT   (1       )
    ,.SELFPOWERED (1       )
)
u_usb_desc (
    .CLK                    (clk60),
    .RESET                  (reset),
    .i_pid                  (16'd0),
    .i_vid                  (16'd0),
    .i_descrom_raddr        (descrom_raddr_o),
    .o_descrom_rdat         (descrom_rdata_i),
    .o_desc_dev_addr        (desc_dev_addr_i),
    .o_desc_dev_len         (desc_dev_len_i),
    .o_desc_qual_addr       (desc_qual_addr_i),
    .o_desc_qual_len        (desc_qual_len_i),
    .o_desc_fscfg_addr      (desc_fscfg_addr_i),
    .o_desc_fscfg_len       (desc_fscfg_len_i),
    .o_desc_hscfg_addr      (desc_hscfg_addr_i),
    .o_desc_hscfg_len       (desc_hscfg_len_i),
    .o_desc_oscfg_addr      (desc_oscfg_addr_i),
    .o_desc_strlang_addr    (desc_strlang_addr_i),
    .o_desc_strvendor_addr  (desc_strvendor_addr_i),
    .o_desc_strvendor_len   (desc_strvendor_len_i),
    .o_desc_strproduct_addr (desc_strproduct_addr_i),
    .o_desc_strproduct_len  (desc_strproduct_len_i),
    .o_desc_strserial_addr  (desc_strserial_addr_i),
    .o_desc_strserial_len   (desc_strserial_len_i),
    .o_descrom_have_strings (desc_have_strings_i)
);
	USB2_0_SoftPHY_Top USB2_0_SoftPHY_Top(
		.clk_i(clk60), //input clk_i
		.rst_i(reset), //input rst_i
		.fclk_i(clk480), //input fclk_i
		.pll_locked_i(clk_usb_lock), //input pll_locked_i
		.utmi_data_out_i(phy_dataout), //input [7:0] utmi_data_out_i
		.utmi_txvalid_i(phy_txvalid), //input utmi_txvalid_i
		.utmi_op_mode_i(phy_opmode), //input [1:0] utmi_op_mode_i
		.utmi_xcvrselect_i(phy_xcvrselect), //input [1:0] utmi_xcvrselect_i
		.utmi_termselect_i(phy_termselect), //input utmi_termselect_i
		.utmi_data_in_o(phy_data_in), //output [7:0] utmi_data_in_o
		.utmi_txready_o(phy_txready), //output utmi_txready_o
		.utmi_rxvalid_o(phy_rxvalid), //output utmi_rxvalid_o
		.utmi_rxactive_o(phy_rxactive), //output utmi_rxactive_o
		.utmi_rxerror_o(phy_rxerror), //output utmi_rxerror_o
		.utmi_linestate_o(phy_linestate), //output [1:0] utmi_linestate_o
		.usb_dxp_io(usb_dxp_io), //inout usb_dxp_io
		.usb_dxn_io(usb_dxn_io), //inout usb_dxn_io
		.usb_rxdp_i(usb_rxdp_i), //input usb_rxdp_i
		.usb_rxdn_i(usb_rxdn_i), //input usb_rxdn_i
		.usb_pullup_en_o(usb_pullup_en_o), //output usb_pullup_en_o
		.usb_term_dp_io(usb_term_dp_io), //inout usb_term_dp_io
		.usb_term_dn_io(usb_term_dn_io) //inout usb_term_dn_io
	);
//	usb_desc usb_desc (
//		.descrom_raddr_o       (descrom_raddr_o),
//		.descrom_rdata_i       (descrom_rdata_i),
//		.desc_dev_addr_i       (desc_dev_addr_i),
//		.desc_dev_len_i        (desc_dev_len_i),
//		.desc_qual_addr_i      (desc_qual_addr_i),
//		.desc_qual_len_i       (desc_qual_len_i),
//		.desc_fscfg_addr_i     (desc_fscfg_addr_i),
//		.desc_fscfg_len_i      (desc_fscfg_len_i),
//		.desc_hscfg_addr_i     (desc_hscfg_addr_i),
//		.desc_hscfg_len_i      (desc_hscfg_len_i),
//		.desc_oscfg_addr_i     (desc_oscfg_addr_i),
//		.desc_hidrpt_addr_i    (desc_hidrpt_addr_i),
//		.desc_hidrpt_len_i     (desc_hidrpt_len_i),
//		.desc_bos_addr_i       (desc_bos_addr_i),
//		.desc_bos_len_i        (desc_bos_len_i),
//		.desc_strlang_addr_i   (desc_strlang_addr_i),
//		.desc_strvendor_addr_i (desc_strvendor_addr_i),
//		.desc_strvendor_len_i  (desc_strvendor_len_i),
//		.desc_strproduct_addr_i(desc_strproduct_addr_i),
//		.desc_strproduct_len_i (desc_strproduct_len_i),
//		.desc_strserial_addr_i (desc_strserial_addr_i),
//		.desc_strserial_len_i  (desc_strserial_len_i),
//		.desc_have_strings_i   (desc_have_strings_i)
//	);
//	usbrxtx usbrxtx(
//		.clk        (clk60),
//		.txact_o    (txact_o),
//		.txpop_o    (txpop_o),
//		.rxact_o    (rxact_o),
//		.rxval_o    (rxval_o),
//		.endpt_o    (endpt_o),
//		.rxdat_o    (rxdat_o),
//		.txdat_i    (txdat_i),
//		.txval_i    (txval_i),
//		.txcork_i   (txcork_i),
//		.rxrdy_i    (rxrdy_i),
//		.txdat_len_i(txdat_len_i),
//		.txpktfin_o (txpktfin_o),
//		.rxpktval_o (rxpktval_o),
//		.setup_o    (setup_o)
//	);

//	reg [7:0] inf1_alter,inf0_alter = 'b0;
//	always @(posedge clk60)begin
//		if(inf_set_o)begin
//			case(inf_sel_o)
//				1'b0: inf0_alter <= inf_alter_o;
//				1'b1: inf1_alter <= inf_alter_o;
//			endcase
//		end
//	end
//	assign inf_alter_i = inf_sel_o?inf1_alter:inf0_alter;
endmodule
