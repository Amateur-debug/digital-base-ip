module icache(

	input	clock	,
	input	reset	,
	
	//-------------------------------------------
	//Interface with ifu	
	input			ifu2icache_valid		,
	input	[1	:0]	ifu2icache_opcode		,
	input	[5	:0]	ifu2icache_index		,
	input	[5	:0]	ifu2icache_offset		,
	output			icache2ifu_ready		,
	
	output			icache2ifu_valid		,
	output	[63 :0]	icache2ifu_rdata		,
	input			ifu2icache_ready		,
	
	input			ifu2icache_ptag_valid	,
	input	[43:0]	ifu2icache_ptag			,
	output			icache2ifu_ptag_ready	,
	
	//-------------------------------------------
	//Interface with axi_arbiter	
	output			icache2axi_arbiter_arvalid	,
	output	[63	:0]	icache2axi_arbiter_araddr 	,
	output	[3	:0]	icache2axi_arbiter_arid   	,
	output	[7	:0]	icache2axi_arbiter_arlen  	,
	output	[2	:0]	icache2axi_arbiter_arsize 	,
	output	[1	:0]	icache2axi_arbiter_arburst	,
	input			axi_arbiter2icache_arready	,

	output			icache2axi_arbiter_rready 	,
	input			axi_arbiter2icache_rvalid 	,
	input	[1	:0]	axi_arbiter2icache_rresp  	,
	input	[127:0]	axi_arbiter2icache_rdata  	,
	input			axi_arbiter2icache_rlast  	,
	input	[3	:0]	axi_arbiter2icache_rid    	
);
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire			ctrl2lookup_valid			;
wire	[5	:0]	ctrl2lookup_index			;
wire	[43	:0]	ctrl2lookup_ptag			;
wire			lookup2ctrl_uncache			;
wire			lookup2ctrl_hit				;
wire			lookup2ctrl_vacancy			;
wire	[2	:0]	lookup2ctrl_way				;
wire	[351:0]	lookup2ctrl_tag_all			;
wire			ctrl2lookup_ready			;	
wire			ctrl2hit_read_valid			;
wire	[5	:0]	ctrl2hit_read_index			;
wire	[2	:0]	ctrl2hit_read_way			;
wire	[5	:0]	ctrl2hit_read_offset		;
wire			ctrl2hit_read_ready			;
wire	[63	:0]	hit_read2ctrl_rdata			;
wire			ctrl2replace_valid			;
wire	[5	:0]	ctrl2replace_index			;
wire	[351:0]	ctrl2replace_tag_all		;
wire			ctrl2replace_ready			;
wire	[2	:0]	replace2ctrl_way			;
wire	[43	:0]	replace2ctrl_tag			;
wire			ctrl2fill_valid				;
wire	[5	:0]	ctrl2fill_index				;
wire	[2	:0]	ctrl2fill_way				;
wire	[43	:0]	ctrl2fill_tag				;
wire			fill2ctrl_ready				;
wire			lookup2valid_array_valid	;  
wire	[5  :0]	lookup2valid_array_index	;
wire			lookup2valid_array_ready	;
wire	[7  :0]	valid_array2lookup_rdata	;
wire			lookup2tag_array_valid		;  
wire	[5  :0]	lookup2tag_array_index		;
wire			lookup2tag_array_ready		;  
wire	[351:0]	tag_array2lookup_rdata		;
wire			hit_read2data_array_valid	; 
wire	[5  :0]	hit_read2data_array_index	;  
wire	[2  :0]	hit_read2data_array_way		;
wire	[1 	:0]	hit_read2data_array_offset	;
wire			hit_read2data_array_ready 	;
wire	[127:0]	data_array2hit_read_rdata	;
wire			hit_read2plru_valid			;  
wire	[5  :0]	hit_read2plru_index			;
wire	[2  :0]	hit_read2plru_way			;
wire			replace2plru_valid			;
wire	[5	:0]	replace2plru_index			;
wire	[2	:0]	plru2replace_way			;	
wire			replace2plru_ready			;
wire			fill2data_array_valid		;
wire	[5  :0]	fill2data_array_index		;  
wire	[2  :0]	fill2data_array_way			; 
wire	[1  :0]	fill2data_array_offset		; 
wire	[127:0]	fill2data_array_wdata		;
wire			fill2tag_array_valid		;
wire	[5  :0]	fill2tag_array_index		;  
wire	[2  :0]	fill2tag_array_way			; 
wire	[43	:0]	fill2tag_array_wdata		;
wire			fill2valid_array_valid		;  
wire	[5  :0]	fill2valid_array_index		;
wire	[2  :0]	fill2valid_array_way		; 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
icache_ctrl u_icache_ctrl(

	.clock		(clock					),
	.reset		(reset					),
	
	.in_valid	(ifu2icache_valid		),
	.opcode		(ifu2icache_opcode		),
	.wstrb		(ifu2icache_wstrb		),
	.index		(ifu2icache_index		),
	.offset		(ifu2icache_offset		),
	.wdata		(ifu2icache_wdata		),
	.out_ready	(icache2ifu_ready		),
	
	.out_valid	(icache2ifu_valid		),
	.rdata		(icache2ifu_rdata		),
	.in_ready	(ifu2icache_ready		),
	
	.ptag_valid	(ifu2icache_ptag_valid	),
	.ptag		(ifu2icache_ptag		),
	.ptag_ready	(icache2ifu_ptag_ready	),
	
	//-------------------------------------------
	//Interface with lookup
	.ctrl2lookup_valid		(ctrl2lookup_valid	),
	.ctrl2lookup_index		(ctrl2lookup_index	),
	.ctrl2lookup_ptag		(ctrl2lookup_ptag	),

	.lookup2ctrl_uncache	(lookup2ctrl_uncache),
	.lookup2ctrl_hit		(lookup2ctrl_hit	),
	.lookup2ctrl_vacancy	(lookup2ctrl_vacancy),
	.lookup2ctrl_way		(lookup2ctrl_way	),
	.lookup2ctrl_tag_all	(lookup2ctrl_tag_all),
	.ctrl2lookup_ready		(ctrl2lookup_ready	),	
	
	//-------------------------------------------
	//Interface with hit_read
	.ctrl2hit_read_valid	(ctrl2hit_read_valid	),
	.ctrl2hit_read_index	(ctrl2hit_read_index	),
	.ctrl2hit_read_way		(ctrl2hit_read_way		),
	.ctrl2hit_read_offset	(ctrl2hit_read_offset	),
	
	.ctrl2hit_read_ready	(ctrl2hit_read_ready	),
	.hit_read2ctrl_rdata	(hit_read2ctrl_rdata	),
	
	//-------------------------------------------
	//Interface with replace
	.ctrl2replace_valid		(ctrl2replace_valid		),
	.ctrl2replace_index		(ctrl2replace_index		),
	.ctrl2replace_tag_all	(ctrl2replace_tag_all	),
	
	.ctrl2replace_ready		(ctrl2replace_ready		),
	.replace2ctrl_way		(replace2ctrl_way		),
	.replace2ctrl_dirty		(replace2ctrl_dirty		),
	.replace2ctrl_tag		(replace2ctrl_tag		),
	
	//-------------------------------------------
	//Interface with fill
	.ctrl2fill_valid	(ctrl2fill_valid	),
	.ctrl2fill_index	(ctrl2fill_index	),
	.ctrl2fill_way		(ctrl2fill_way		),
	.ctrl2fill_tag		(ctrl2fill_tag		),
	.fill2ctrl_ready	(fill2ctrl_ready	)
);

icache_lookup u_icache_lookup(

	.clock	(clock),
	.reset	(reset),
	
	//-------------------------------------------
	//Interface with ctrl	
	.ctrl2lookup_valid		(ctrl2lookup_valid		),
	.ctrl2lookup_index		(ctrl2lookup_index		),
	.ctrl2lookup_ptag		(ctrl2lookup_ptag		),
                             
	.lookup2ctrl_uncache	(lookup2ctrl_uncache	),
	.lookup2ctrl_hit		(lookup2ctrl_hit		),
	.lookup2ctrl_vacancy	(lookup2ctrl_vacancy	),
	.lookup2ctrl_way		(lookup2ctrl_way		),
	.lookup2ctrl_tag_all	(lookup2ctrl_tag_all	),
	.ctrl2lookup_ready		(ctrl2lookup_ready		),
	
	//-------------------------------------------
	//Interface with valid_array
	.lookup2valid_array_valid	(lookup2valid_array_valid),  
	.lookup2valid_array_index	(lookup2valid_array_index),
	.lookup2valid_array_ready	(lookup2valid_array_ready),
	.valid_array2lookup_rdata	(valid_array2lookup_rdata),
	
	//-------------------------------------------
	//Interface with tag_array	
	.lookup2tag_array_valid	(lookup2tag_array_valid	),  
	.lookup2tag_array_index	(lookup2tag_array_index	),
	.lookup2tag_array_ready	(lookup2tag_array_ready	),  
	.tag_array2lookup_rdata	(tag_array2lookup_rdata	)	
);

icache_hit_read u_icache_hit_read(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with ctrl
	.ctrl2hit_read_valid	(ctrl2hit_read_valid	),
	.ctrl2hit_read_index	(ctrl2hit_read_index	),
	.ctrl2hit_read_way		(ctrl2hit_read_way		),
	.ctrl2hit_read_offset	(ctrl2hit_read_offset	),

	.ctrl2hit_read_ready	(ctrl2hit_read_ready	),
	.hit_read2ctrl_rdata	(hit_read2ctrl_rdata	),
	
	//-------------------------------------------
	//Interface with data_array
	.hit_read2data_array_valid	(hit_read2data_array_valid	),  
	.hit_read2data_array_index	(hit_read2data_array_index	),   
	.hit_read2data_array_way	(hit_read2data_array_way	),
	.hit_read2data_array_offset	(hit_read2data_array_offset	), 

	.hit_read2data_array_ready 	(hit_read2data_array_ready 	),
	.data_array2hit_read_rdata	(data_array2hit_read_rdata	),
	
	//-------------------------------------------
	//Interface with plru
	.hit_read2plru_valid	(hit_read2plru_valid	),  
	.hit_read2plru_index	(hit_read2plru_index	),
	.hit_read2plru_way	    (hit_read2plru_way	    )
);

icache_replace u_icache_replace(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with ctrl
	.ctrl2replace_valid		(ctrl2replace_valid		),
	.ctrl2replace_index		(ctrl2replace_index		),
	.ctrl2replace_tag_all	(ctrl2replace_tag_all	),

	.replace2ctrl_way		(replace2ctrl_way		),
	.replace2ctrl_tag		(replace2ctrl_tag		),
	.ctrl2replace_ready		(ctrl2replace_ready		),
			
	//-------------------------------------------
	//Interface with plru
	.replace2plru_valid	(replace2plru_valid	),
	.replace2plru_index	(replace2plru_index	),

	.plru2replace_way	(plru2replace_way	),	
	.replace2plru_ready	(replace2plru_ready	)
);

icache_fill u_icache_fill(

	.clock	(clock	),
	.reset	(reset	),
	
	//-------------------------------------------
	//Interface with ctrl		
	.ctrl2fill_valid	(ctrl2fill_valid),
	.ctrl2fill_index	(ctrl2fill_index),
	.ctrl2fill_way		(ctrl2fill_way	),
	.ctrl2fill_tag		(ctrl2fill_tag	),
	.fill2ctrl_ready	(fill2ctrl_ready),
	
	//-------------------------------------------
	//Interface with data_array	
	.fill2data_array_valid	(fill2data_array_valid	),
	.fill2data_array_index	(fill2data_array_index	),  
	.fill2data_array_way	(fill2data_array_way	), 
	.fill2data_array_offset	(fill2data_array_offset	), 
	.fill2data_array_wdata	(fill2data_array_wdata	),
	
	//-------------------------------------------
	//Interface with tag_array	
	.fill2tag_array_valid	(fill2tag_array_valid	),
	.fill2tag_array_index	(fill2tag_array_index	),  
	.fill2tag_array_way		(fill2tag_array_way		), 
	.fill2tag_array_wdata	(fill2tag_array_wdata	),
	
	//-------------------------------------------
	//Interface with valid_array	
	.fill2valid_array_valid	(fill2valid_array_valid	),  
	.fill2valid_array_index	(fill2valid_array_index	),
	.fill2valid_array_way	(fill2valid_array_way	), 	
	
	//-------------------------------------------
	//Interface with axi	
	.arvalid	(icache2axi_arbiter_arvalid	),
	.araddr 	(icache2axi_arbiter_araddr 	),
	.arid   	(icache2axi_arbiter_arid   	),
	.arlen  	(icache2axi_arbiter_arlen  	),
	.arsize 	(icache2axi_arbiter_arsize 	),
	.arburst	(icache2axi_arbiter_arburst	),
	.arready	(axi_arbiter2icache_arready	),

	.rready 	(icache2axi_arbiter_rready 	),
	.rvalid 	(axi_arbiter2icache_rvalid 	),
	.rresp  	(axi_arbiter2icache_rresp  	),
	.rdata  	(axi_arbiter2icache_rdata  	),
	.rlast  	(axi_arbiter2icache_rlast  	),
	.rid    	(axi_arbiter2icache_rid    	)	
);

icache_data_array u_icache_data_array(

	.clock	(clock),
	.reset	(reset),
	
	//-------------------------------------------
	//Interface with hit_read	
	.hit_read2data_array_valid	(hit_read2data_array_valid	),  
	.hit_read2data_array_index	(hit_read2data_array_index	),   
	.hit_read2data_array_way	(hit_read2data_array_way	),
	.hit_read2data_array_offset	(hit_read2data_array_offset	), 
	.hit_read2data_array_ready 	(hit_read2data_array_ready 	),
	.data_array2hit_read_rdata	(data_array2hit_read_rdata	),
	
	//-------------------------------------------
	//Interface with fill	
	.fill2data_array_valid	(fill2data_array_valid	),
	.fill2data_array_index	(fill2data_array_index	),  
	.fill2data_array_way	(fill2data_array_way	), 
	.fill2data_array_offset	(fill2data_array_offset	), 
	.fill2data_array_wdata	(fill2data_array_wdata	)	
);

icache_tag_array u_icache_tag_array(

	.clock	(clock	),
	.reset	(reset	),
	
	//-------------------------------------------
	//Interface with lookup
	.lookup2tag_array_valid(lookup2tag_array_valid),  
	.lookup2tag_array_index(lookup2tag_array_index),
	.lookup2tag_array_ready(lookup2tag_array_ready),  
	.tag_array2lookup_rdata(tag_array2lookup_rdata),
	
	//-------------------------------------------
	//Interface with fill
	.fill2tag_array_valid	(fill2tag_array_valid	),
	.fill2tag_array_index	(fill2tag_array_index	),  
	.fill2tag_array_way		(fill2tag_array_way		), 
	.fill2tag_array_wdata	(fill2tag_array_wdata	)
);

icache_valid_array u_icache_valid_array(

	.clock	(clock	),
	.reset	(reset	),
	
	//-------------------------------------------
	//Interface with lookup
	.lookup2valid_array_valid(lookup2valid_array_valid),
	.lookup2valid_array_index(lookup2valid_array_index),
	.lookup2valid_array_ready(lookup2valid_array_ready),
	.valid_array2lookup_rdata(valid_array2lookup_rdata),
	
	//-------------------------------------------
	//Interface with fill
	.fill2valid_array_valid	(fill2valid_array_valid	),  
	.fill2valid_array_index	(fill2valid_array_index	),
	.fill2valid_array_way	(fill2valid_array_way	)	
);

icache_plru u_icache_plru(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with hit_read
	.hit_read2plru_valid	(hit_read2plru_valid	),  
	.hit_read2plru_index	(hit_read2plru_index	),
	.hit_read2plru_way		(hit_read2plru_way		), 			
	
	//-------------------------------------------
	//Interface with replace
	.replace2plru_valid	(replace2plru_valid	),  
	.replace2plru_index	(replace2plru_index	),  
	.replace2plru_ready	(replace2plru_ready	),  	
	.plru2replace_way	(plru2replace_way	)
);

endmodule
