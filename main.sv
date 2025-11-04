module main(
    input      CLK_IN,
    inout      usb_dxp_io     ,
    inout      usb_dxn_io     ,
    input      usb_rxdp_i     ,
    input      usb_rxdn_i     ,
    output     usb_pullup_en_o,
    inout      usb_term_dp_io ,
    inout      usb_term_dn_io

);

wire [1:0]  PHY_XCVRSELECT      ;
wire        PHY_TERMSELECT      ;
wire [1:0]  PHY_OPMODE          ;
wire [1:0]  PHY_LINESTATE       ;
wire        PHY_TXVALID         ;
wire        PHY_TXREADY         ;
wire        PHY_RXVALID         ;
wire        PHY_RXACTIVE        ;
wire        PHY_RXERROR         ;
wire [7:0]  PHY_DATAIN          ;
wire [7:0]  PHY_DATAOUT         ;
wire        PHY_CLKOUT          ;
wire [15:0] DESCROM_RADDR       ;
wire [ 7:0] DESC_INDEX          ;
wire [ 7:0] DESC_TYPE           ;
wire [ 7:0] DESCROM_RDAT        ;
wire [15:0] DESC_DEV_ADDR       ;
wire [15:0] DESC_DEV_LEN        ;
wire [15:0] DESC_QUAL_ADDR      ;
wire [15:0] DESC_QUAL_LEN       ;
wire [15:0] DESC_FSCFG_ADDR     ;
wire [15:0] DESC_FSCFG_LEN      ;
wire [15:0] DESC_HSCFG_ADDR     ;
wire [15:0] DESC_HSCFG_LEN      ;
wire [15:0] DESC_OSCFG_ADDR     ;
wire [15:0] DESC_HIDRPT_ADDR    ;
wire [15:0] DESC_HIDRPT_LEN     ;
wire [15:0] DESC_BOS_ADDR       ;
wire [15:0] DESC_BOS_LEN        ;
wire [15:0] DESC_STRLANG_ADDR   ;
wire [15:0] DESC_STRVENDOR_ADDR ;
wire [15:0] DESC_STRVENDOR_LEN  ;
wire [15:0] DESC_STRPRODUCT_ADDR;
wire [15:0] DESC_STRPRODUCT_LEN ;
wire [15:0] DESC_STRSERIAL_ADDR ;
wire [15:0] DESC_STRSERIAL_LEN  ;
wire        DESCROM_HAVE_STRINGS;
wire        RESET;
reg  [7:0]  rst_cnt;
wire [7:0]  usb_txdat;
wire [11:0] usb_txdat_len;
wire        usb_txcork;
wire        usb_txpop;
wire        usb_txact;
wire	    usb_txval;
wire [7:0]  usb_rxdat;
wire        usb_rxval;
wire        usb_rxpktval;
wire        usb_rxact;
wire        usb_rxrdy;
wire [3:0]  endpt_sel;
wire        rx_fifo_wren;
wire        rx_fifo_empty;
reg         rx_fifo_rden;
wire [7:0]  rx_fifo_data;
wire        rx_fifo_dval;
reg         rx_fifo_dval_d0;
wire        rx_fifo_dval_rise;
wire [9:0]  tx_fifo_wnum;
wire        tx_fifo_empty;
wire [7:0]  tx_fifo_rdat;
wire        tx_fifo_rd;
wire        setup_active;
wire        setup_val;
wire [7:0]  setup_data;
wire        endpt0_send;
wire [7:0]  endpt0_dat;
wire        pll_locked;
wire        uart_en;
wire [31:0] uart_dte_rate;
wire [7:0]  uart_char_format;
wire [7:0]  uart_parity_type;
wire [7:0]  uart_data_bits;
wire [11:0] uart_config_txdat_len;
wire [15:0] uart_tx_data    ;
wire        uart_tx_data_val;
wire        uart_tx_busy    ;
wire [15:0] uart_rx_data    ;
wire        uart_rx_data_val;
reg  [31:0] led_cnt;
wire        uart_rts;
wire        uart_cts;
wire        uart_txd;
wire        uart_rxd;
wire        ep_usb_rxrdy;
wire        ep_usb_txcork;
wire [11:0] ep_usb_txlen;
wire [7:0]  ep_usb_txdat;
wire        ep2_rx_dval;
wire [7:0]  ep2_rx_data;
wire [7:0]  inf_alter_i;
wire [7:0]  inf_alter_o;
wire [7:0]  inf_sel_o;
wire        inf_set_o;
reg  [7:0]  interface0_alter;
reg  [7:0]  interface1_alter;

wire CLK24M;
	Gowin_PLL Gowin_PLL(
        .clkout0(CLK24M), //output clkout0
        .clkin(CLK_IN) //input clkin
    );

	usb_PLL usb_PLL(
        .lock(pll_locked), //output lock
        .clkout0(fclk_480M), //output clkout0
        .clkout1(PHY_CLKOUT), //output clkout1
        .clkin(CLK24M) //input clkin
    );
assign RESET = ~pll_locked;
assign inf_alter_i = inf_sel_o ? interface1_alter : interface0_alter;
always@(posedge PHY_CLKOUT) begin
        if (inf_set_o) begin
		case(inf_sel_o)
			0:interface0_alter <= inf_alter_o;
			1:interface1_alter <= inf_alter_o;
		endcase
        end
end							  
uart u_uart(                                              
	.clk       (PHY_CLKOUT)                         
	,.txact    (usb_txact    )                    
	,.txpop    (usb_txpop    )                    
	,.endpt    (usb_endpt    )                    
	,.txval    (usb_txval    )                    
	,.txcork   (usb_txcork   )                    
	,.txdat    (usb_txdat    )                    
	,.txdat_len(usb_txdat_len)                    
	,.rxact    (usb_rxact    )                    
	,.rxval    (usb_rxval    )                    
	,.rxrdy    (usb_rxrdy    )                    
	,.rxdat    (usb_rxdat    )
);
USB_Device_Controller_Top u_usb_device_controller_top (
     .clk_i                 (PHY_CLKOUT          )
    ,.reset_i               (RESET               )
    ,.usbrst_o              (usb_busreset        )
    ,.highspeed_o           (usb_highspeed       )
    ,.suspend_o             (usb_suspend         )
    ,.online_o              (usb_online          )
    ,.txdat_i               (usb_txdat           )
    ,.txval_i               (usb_txval		 )
    ,.txdat_len_i           (usb_txdat_len       )
    ,.txcork_i              (usb_txcork          )
    ,.txiso_pid_i           (4'b0011             )
    ,.txpop_o               (usb_txpop           )
    ,.txact_o               (usb_txact           )
    ,.txpktfin_o            (usb_txpktfin        )
    ,.rxdat_o               (usb_rxdat           )
    ,.rxval_o               (usb_rxval           )
    ,.rxact_o               (usb_rxact           )
    ,.rxrdy_i               (usb_rxrdy           )
    ,.rxpktval_o            (usb_rxpktval        )
    ,.setup_o               (setup_active        )
    ,.endpt_o               (endpt_sel           )
    ,.sof_o                 (usb_sof             )
    ,.inf_alter_i           (inf_alter_i         )
    ,.inf_alter_o           (inf_alter_o         )
    ,.inf_sel_o             (inf_sel_o           )
    ,.inf_set_o             (inf_set_o           )
    ,.descrom_rdata_i       (DESCROM_RDAT        )
    ,.descrom_raddr_o       (DESCROM_RADDR       )
    ,.desc_index_o          (DESC_INDEX          )
    ,.desc_type_o           (DESC_TYPE           )
    ,.desc_dev_addr_i       (DESC_DEV_ADDR       )
    ,.desc_dev_len_i        (DESC_DEV_LEN        )
    ,.desc_qual_addr_i      (DESC_QUAL_ADDR      )
    ,.desc_qual_len_i       (DESC_QUAL_LEN       )
    ,.desc_fscfg_addr_i     (DESC_FSCFG_ADDR     )
    ,.desc_fscfg_len_i      (DESC_FSCFG_LEN      )
    ,.desc_hscfg_addr_i     (DESC_HSCFG_ADDR     )
    ,.desc_hscfg_len_i      (DESC_HSCFG_LEN      )
    ,.desc_oscfg_addr_i     (DESC_OSCFG_ADDR     )
    ,.desc_hidrpt_addr_i    (DESC_HIDRPT_ADDR    )
    ,.desc_hidrpt_len_i     (DESC_HIDRPT_LEN     )
    ,.desc_bos_addr_i       (DESC_BOS_ADDR       )
    ,.desc_bos_len_i        (DESC_BOS_LEN        )
    ,.desc_strlang_addr_i   (DESC_STRLANG_ADDR   )
    ,.desc_strvendor_addr_i (DESC_STRVENDOR_ADDR )
    ,.desc_strvendor_len_i  (DESC_STRVENDOR_LEN  )
    ,.desc_strproduct_addr_i(DESC_STRPRODUCT_ADDR)
    ,.desc_strproduct_len_i (DESC_STRPRODUCT_LEN )
    ,.desc_strserial_addr_i (DESC_STRSERIAL_ADDR )
    ,.desc_strserial_len_i  (DESC_STRSERIAL_LEN  )
    ,.desc_have_strings_i   (DESCROM_HAVE_STRINGS)
    
    ,.utmi_dataout_o        (PHY_DATAOUT       )
    ,.utmi_txvalid_o        (PHY_TXVALID       )
    ,.utmi_txready_i        (PHY_TXREADY       )
    ,.utmi_datain_i         (PHY_DATAIN        )
    ,.utmi_rxactive_i       (PHY_RXACTIVE      )
    ,.utmi_rxvalid_i        (PHY_RXVALID       )
    ,.utmi_rxerror_i        (PHY_RXERROR       )
    ,.utmi_linestate_i      (PHY_LINESTATE     )
    ,.utmi_opmode_o         (PHY_OPMODE        )
    ,.utmi_xcvrselect_o     (PHY_XCVRSELECT    )
    ,.utmi_termselect_o     (PHY_TERMSELECT    )
    ,.utmi_reset_o          (PHY_RESET         )
);

usb_desc usb_desc (
	.descrom_raddr_o       (DESCROM_RADDR       )
	,.descrom_rdata_i       (DESCROM_RDAT        )
	,.desc_dev_addr_i       (DESC_DEV_ADDR       )
	,.desc_dev_len_i        (DESC_DEV_LEN        )
	,.desc_qual_addr_i      (DESC_QUAL_ADDR      )
	,.desc_qual_len_i       (DESC_QUAL_LEN       )
	,.desc_fscfg_addr_i     (DESC_FSCFG_ADDR     )
	,.desc_fscfg_len_i      (DESC_FSCFG_LEN      )
	,.desc_hscfg_addr_i     (DESC_HSCFG_ADDR     )
	,.desc_hscfg_len_i      (DESC_HSCFG_LEN      )
	,.desc_oscfg_addr_i     (DESC_OSCFG_ADDR     )
	,.desc_hidrpt_addr_i    (DESC_HIDRPT_ADDR    )
	,.desc_hidrpt_len_i     (DESC_HIDRPT_LEN     )
	,.desc_bos_addr_i       (DESC_BOS_ADDR       )
	,.desc_bos_len_i        (DESC_BOS_LEN        )
	,.desc_strlang_addr_i   (DESC_STRLANG_ADDR   )
	,.desc_strvendor_addr_i (DESC_STRVENDOR_ADDR )
	,.desc_strvendor_len_i  (DESC_STRVENDOR_LEN  )
	,.desc_strproduct_addr_i(DESC_STRPRODUCT_ADDR)
	,.desc_strproduct_len_i (DESC_STRPRODUCT_LEN )
	,.desc_strserial_addr_i (DESC_STRSERIAL_ADDR )
	,.desc_strserial_len_i  (DESC_STRSERIAL_LEN  )
	,.desc_have_strings_i   (DESCROM_HAVE_STRINGS)
);

USB2_0_SoftPHY_Top u_USB_SoftPHY_Top
(
     .clk_i            (PHY_CLKOUT     )
    ,.rst_i            (PHY_RESET      )
    ,.fclk_i           (fclk_480M      )
    ,.pll_locked_i     (pll_locked     )
    ,.utmi_data_out_i  (PHY_DATAOUT    )
    ,.utmi_txvalid_i   (PHY_TXVALID    )
    ,.utmi_op_mode_i   (PHY_OPMODE     )
    ,.utmi_xcvrselect_i(PHY_XCVRSELECT )
    ,.utmi_termselect_i(PHY_TERMSELECT )
    ,.utmi_data_in_o   (PHY_DATAIN     )
    ,.utmi_txready_o   (PHY_TXREADY    )
    ,.utmi_rxvalid_o   (PHY_RXVALID    )
    ,.utmi_rxactive_o  (PHY_RXACTIVE   )
    ,.utmi_rxerror_o   (PHY_RXERROR    )
    ,.utmi_linestate_o (PHY_LINESTATE  )
    ,.usb_dxp_io       (usb_dxp_io     )
    ,.usb_dxn_io       (usb_dxn_io     )
    ,.usb_rxdp_i       (usb_rxdp_i     )
    ,.usb_rxdn_i       (usb_rxdn_i     )
    ,.usb_pullup_en_o  (usb_pullup_en_o)
    ,.usb_term_dp_io   (usb_term_dp_io )
    ,.usb_term_dn_io   (usb_term_dn_io )
);

endmodule
