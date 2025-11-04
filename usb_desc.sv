module usb_desc (
	input [15:0]  descrom_raddr_o       ,
	output [7:0]  descrom_rdata_i       ,
	output [15:0] desc_dev_addr_i       ,
	output [15:0] desc_dev_len_i        ,
	output [15:0] desc_qual_addr_i      ,
	output [15:0] desc_qual_len_i       ,
	output [15:0] desc_fscfg_addr_i     ,
	output [15:0] desc_fscfg_len_i      ,
	output [15:0] desc_hscfg_addr_i     ,
	output [15:0] desc_hscfg_len_i      ,
	output [15:0] desc_oscfg_addr_i     ,
	output [15:0] desc_hidrpt_addr_i    ,
	output [15:0] desc_hidrpt_len_i     ,
	output [15:0] desc_bos_addr_i       ,
	output [15:0] desc_bos_len_i        ,
	output [15:0] desc_strlang_addr_i   ,
	output [15:0] desc_strvendor_addr_i ,
	output [15:0] desc_strvendor_len_i  ,
	output [15:0] desc_strproduct_addr_i,
	output [15:0] desc_strproduct_len_i ,
	output [15:0] desc_strserial_addr_i ,
	output [15:0] desc_strserial_len_i  ,
	output desc_have_strings_i
);

    localparam [7:0]descrom[0:289] = {
	8'h12,8'h01,8'h10,8'h01,8'h02,8'h00,8'h00,8'h08,8'h88,8'h88,8'h77,8'h77,8'h00,8'h02,8'h01,8'h02,8'h03,8'h01,//Device Descriptor
	8'h0a,8'h06,8'h00,8'h02,8'h02,8'h00,8'h00,8'h40,8'h01,8'h00,//Device Qualifier
	8'h09,8'h02,8'h43,8'h00,8'h02,8'h01,8'h00,8'hc0,8'hfa,//Full Speed Configuration
	8'h09,8'h04,8'h00,8'h00,8'h01,8'h02,8'h02,8'h01,8'h00,//INFDES
	8'h05,8'h24,8'h00,8'h10,8'h01,
	8'h05,8'h24,8'h01,8'h00,8'h01,
	8'h04,8'h24,8'h02,8'h02,
	8'h05,8'h24,8'h06,8'h00,8'h01,
	8'h07,8'h05,8'h83,8'h03,8'h10,8'h00,8'h01,
	8'h09,8'h04,8'h01,8'h00,8'h02,8'h0a,8'h00,8'h00,8'h00,
	8'h07,8'h05,8'h02,8'h02,8'h20,8'h00,8'h00,
	8'h07,8'h05,8'h82,8'h02,8'h40,8'h00,8'h00,
	8'h09,8'h02,8'h43,8'h00,8'h02,8'h01,8'h00,8'hc0,8'hfa,//High Speed Configuration
	8'h09,8'h04,8'h00,8'h00,8'h01,8'h02,8'h02,8'h01,8'h00,//INFDES
	8'h05,8'h24,8'h00,8'h10,8'h01,
	8'h05,8'h24,8'h01,8'h00,8'h01,
	8'h04,8'h24,8'h02,8'h02,
	8'h05,8'h24,8'h06,8'h00,8'h01,
	8'h07,8'h05,8'h83,8'h03,8'h10,8'h00,8'h01,
	8'h09,8'h04,8'h01,8'h00,8'h02,8'h0a,8'h00,8'h00,8'h00,
	8'h07,8'h05,8'h02,8'h02,8'h20,8'h00,8'h00,
	8'h07,8'h05,8'h82,8'h02,8'h40,8'h00,8'h00,
	8'h07,//Other Speed Configuration Descriptor replace HS/FS
	8'h09,8'h21,8'h11,8'h01,8'h00,8'h01,8'h22,8'h34,8'h00,//HID
	8'h05,8'h0F,8'h16,8'h00,8'h02,
	8'h07,8'h10,8'h02,8'h02,8'h00,8'h00,8'h00,
	8'h18,8'h10,8'h05,8'h00,8'h88,8'hB6,8'h42,8'h84,8'h0C,8'hBF,8'h4D,8'hC0,8'h9C,8'h2D,8'h65,8'h2F,8'h2A,8'hF2,8'h9C,8'h8C,8'h00,8'h00,8'h01,8'h00,//BOS
	8'h04,8'h03,8'h09,8'h04,//strlang
	8'h26,8'h03,8'h55,8'h00,8'h53,8'h00,8'h42,8'h00,8'h54,8'h00,8'h6F,8'h00,8'h55,8'h00,8'h41,8'h00,8'h52,8'h00,8'h54,8'h00,8'h49,8'h00,8'h32,8'h00,8'h43,8'h00,8'h53,8'h00,8'h50,8'h00,8'h49,8'h00,8'h50,8'h00,8'h57,8'h00,8'h4D,8'h00,//strvendor
	8'h0c,8'h03,8'h34,8'h00,8'h33,8'h00,8'h35,8'h00,8'h30,8'h00,8'h31,8'h00,//strproduct
	8'h1c,8'h03,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h30,8'h00,8'h31,8'h00//strserial
	}; 
    assign  desc_dev_addr_i        = 0 ;
    assign  desc_dev_len_i         = 18;
    assign  desc_qual_addr_i       = 18;
    assign  desc_qual_len_i        = 10;
    assign  desc_fscfg_addr_i      = 28;
    assign  desc_fscfg_len_i       = 67;
    assign  desc_hscfg_addr_i      = 95;
    assign  desc_hscfg_len_i       = 67;
    assign  desc_oscfg_addr_i      = 162;
    assign  desc_hidrpt_addr_i     = 163;
    assign  desc_hidrpt_len_i      = 21;
    assign  desc_bos_addr_i        = 184;
    assign  desc_bos_len_i         = 24;
    assign  desc_strlang_addr_i    = 208;
    assign  desc_strvendor_addr_i  = 212;
    assign  desc_strvendor_len_i   = 38;
    assign  desc_strproduct_addr_  = 250;
    assign  desc_strproduct_len_i  = 12;
    assign  desc_strserial_addr_i  = 262;
    assign  desc_strserial_len_i   = 28;
    assign  desc_have_strings_i    = 1;
    assign  descrom_rdata_i        = descrom[descrom_raddr_o];
endmodule
