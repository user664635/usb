module uart(
	input clk,
	input txact,txpop,
	input [3:0]endpt,
	output reg txval,txcork,
	output reg [7:0]txdat,
	output reg [11:0]txdat_len,
	input rxact,rxval,
	output reg rxrdy,
	input reg [7:0]rxdat
);
	always@ (negedge clk)begin
		rxrdy <= 1;
	//	if(rxact)begin
			txcork <= 0;
			txdat <= 8'h96;
			txdat_len <= 1;
	//	end
	//	else txdat_len <= 0;
		//if(rxact)begin
		//	rxrdy <= 1;
		//	txdat <= rxdat;
		//	txcork <= 0;
		//	txdat_len <= 1;
		//end
		//else rxrdy <= 0;
	end
endmodule
