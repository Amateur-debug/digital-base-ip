module	fifo_ahead
#(
	parameter   DATA_WIDTH = 8,					//FIFO位宽
    parameter   DEPTH = 16 						//FIFO深度
)
(
	input				  		clock ,			//系统时钟
	input				  		reset ,       	//高电平有效的复位信号
	input   [DATA_WIDTH - 1:0]  wrData,       	//写入的数据
	input				  		rd_en ,       	//读使能信号，高电平有效
	input				  		wr_en ,       	//写使能信号，高电平有效
	
	output  [DATA_WIDTH - 1:0] 	rdData,	    	//输出的数据
	output				  		empty ,	    	//空标志，高电平表示当前FIFO已被读空
	output				  		full			//满标志，高电平表示当前FIFO已被写满
);                                                              

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [DATA_WIDTH - 1:0] buffer [DEPTH - 1 : 0];	
reg [ADDR_WIDTH :0] wrPtr;						//写地址指针，位宽多一位	
reg [ADDR_WIDTH :0] rdPtr;						//读地址指针，位宽多一位

wire [ADDR_WIDTH - 1:0]	wrPtr_true;				//真实写地址指针
wire [ADDR_WIDTH - 1:0]	rdPtr_true;				//真实读地址指针
wire			wrPtr_msb;						//写地址指针地址最高位
wire			rdPtr_msb;						//读地址指针地址最高位
 
assign {wrPtr_msb, wrPtr_true} = wrPtr;			//将最高位与其他位拼接
assign {rdPtr_msb, rdPtr_true} = rdPtr;			//将最高位与其他位拼接


//读操作
always@(posedge clock or posedge reset) begin
	if(reset) begin
		rdPtr <= 'b0;
	end
	else if(rd_en && !empty) begin
		rdPtr <= rdPtr + 1'b1;
	end
end

assign rdData = rd_en ? buffer[rdPtr_true] : rdData;
//写操作
always@(posedge clock or posedge reset) begin
	if (reset) begin
		wrPtr <= 'b0;
	end
	else if (wr_en && !full) begin
		wrPtr <= wrPtr + 1'b1;
		buffer[wrPtr_true] <= wrData;
	end	
end

//更新指示信号
//当所有位相等时，读指针追到到了写指针，FIFO被读空
assign empty = wrPtr == rdPtr;
//当最高位不同但是其他位相等时，写指针超过读指针一圈，FIFO被写满
assign full = wrPtr_msb != rdPtr_msb && wrPtr_true == rdPtr_true;
 
endmodule
