module dcache(

	input	clock	,
	input	reset	,
	
	//-------------------------------------------
	//Interface with lsu	
	input			lsu2dcache_valid		,
	input	[1	:0]	lsu2dcache_opcode		,
	input	[7	:0]	lsu2dcache_wstrb		,
	input	[5	:0]	lsu2dcache_index		,
	input	[5	:0]	lsu2dcache_offset		,
	input	[63 :0]	lsu2dcache_wdata		,
	output			dcache2lsu_ready		,
	
	output			dcache2lsu_valid		,
	output	[63 :0]	dcache2lsu_rdata		,
	input			lsu2dcache_ready		,
	
	input			lsu2dcache_ptag_valid	,
	input	[43:0]	lsu2dcache_ptag			,
	output			dcache2lsu_ptag_ready	,
	
	//-------------------------------------------
	//Interface with axi_arbiter	
	output			dcache2axi_arbiter_arvalid	,
	output	[63	:0]	dcache2axi_arbiter_araddr 	,
	output	[3	:0]	dcache2axi_arbiter_arid   	,
	output	[7	:0]	dcache2axi_arbiter_arlen  	,
	output	[2	:0]	dcache2axi_arbiter_arsize 	,
	output	[1	:0]	dcache2axi_arbiter_arburst	,
	input			axi_arbiter2dcache_arready	,

	output			dcache2axi_arbiter_rready 	,
	input			axi_arbiter2dcache_rvalid 	,
	input	[1	:0]	axi_arbiter2dcache_rresp  	,
	input	[127:0]	axi_arbiter2dcache_rdata  	,
	input			axi_arbiter2dcache_rlast  	,
	input	[3	:0]	axi_arbiter2dcache_rid    	,

	output			dcache2axi_arbiter_awvalid	,
	output	[63	:0]	dcache2axi_arbiter_awaddr	,
	output	[3	:0]	dcache2axi_arbiter_awid		,
	output	[7	:0]	dcache2axi_arbiter_awlen	,
	output	[2	:0]	dcache2axi_arbiter_awsize	,
	output	[1	:0]	dcache2axi_arbiter_awburst	,
	input			axi_arbiter2dcache_awready	,       

	output		   	dcache2axi_arbiter_wvalid	,
	output	[127:0]	dcache2axi_arbiter_wdata	,
	output	[15	:0] dcache2axi_arbiter_wstrb	,
	output			dcache2axi_arbiter_wlast	,
	input 		   	axi_arbiter2dcache_wready	,

	output			dcache2axi_arbiter_bready	,
	input			axi_arbiter2dcache_bvalid	,
	input	[1	:0]	axi_arbiter2dcache_bresp 	,
	input 	[3	:0]	axi_arbiter2dcache_bid   	
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
wire			ctrl2hit_write_valid		;
wire	[7	:0]	ctrl2hit_write_wstrb		;
wire	[5	:0]	ctrl2hit_write_index		;
wire	[2	:0]	ctrl2hit_write_way			;
wire	[5	:0]	ctrl2hit_write_offset		;
wire	[5	:0]	ctrl2hit_write_wdata		;
wire			ctrl2replace_valid			;
wire	[5	:0]	ctrl2replace_index			;
wire	[351:0]	ctrl2replace_tag_all		;
wire			ctrl2replace_ready			;
wire	[2	:0]	replace2ctrl_way			;
wire			replace2ctrl_dirty			;
wire	[43	:0]	replace2ctrl_tag			;
wire			ctrl2wback_valid			;
wire	[5	:0]	ctrl2wback_index			;
wire	[2	:0]	ctrl2wback_way				;
wire	[43	:0]	ctrl2wback_tag				;
wire			wback2ctrl_ready			;
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
wire			hit_write2data_array_valid	; 
wire	[15 :0]	hit_write2data_array_bwen	;
wire	[5  :0]	hit_write2data_array_index	; 
wire	[2  :0]	hit_write2data_array_way	;
wire	[1  :0]	hit_write2data_array_offset	;
wire	[127:0]	hit_write2data_array_wdata	;
wire			hit_write2dirty_array_valid	;  
wire  	[5  :0]	hit_write2dirty_array_index	; 
wire  	[2  :0]	hit_write2dirty_array_way	; 	
wire			hit_write2plru_valid		;
wire	[5  :0]	hit_write2plru_index		;
wire	[2  :0]	hit_write2plru_way	    	;
wire			replace2plru_valid			;
wire	[5	:0]	replace2plru_index			;
wire	[2	:0]	plru2replace_way			;	
wire			replace2plru_ready			;
wire			replace2dirty_array_valid	;  
wire	[5  :0]	replace2dirty_array_index	;
wire	[7  :0]	dirty_array2replace_rdata	;
wire			replace2dirty_array_ready	;	
wire			wback2data_array_valid		;
wire	[5	:0]	wback2data_array_index		;
wire	[2	:0]	wback2data_array_way		;
wire	[1	:0]	wback2data_array_offset		;
wire			wback2data_array_ready		;
wire	[127:0]	data_array2wback_rdata		;
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
wire			fill2dirty_array_valid		;  
wire	[5  :0]	fill2dirty_array_index		;
wire	[2  :0]	fill2dirty_array_way		;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
dcache_ctrl u_dcache_ctrl(

	.clock		(clock					),
	.reset		(reset					),
	
	.in_valid	(lsu2dcache_valid		),
	.opcode		(lsu2dcache_opcode		),
	.wstrb		(lsu2dcache_wstrb		),
	.index		(lsu2dcache_index		),
	.offset		(lsu2dcache_offset		),
	.wdata		(lsu2dcache_wdata		),
	.out_ready	(dcache2lsu_ready		),
	
	.out_valid	(dcache2lsu_valid		),
	.rdata		(dcache2lsu_rdata		),
	.in_ready	(lsu2dcache_ready		),
	
	.ptag_valid	(lsu2dcache_ptag_valid	),
	.ptag		(lsu2dcache_ptag		),
	.ptag_ready	(dcache2lsu_ptag_ready	),
	
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
	//Interface with hit_write
	.ctrl2hit_write_valid	(ctrl2hit_write_valid	),
	.ctrl2hit_write_wstrb	(ctrl2hit_write_wstrb	),
	.ctrl2hit_write_index	(ctrl2hit_write_index	),
	.ctrl2hit_write_way		(ctrl2hit_write_way		),
	.ctrl2hit_write_offset	(ctrl2hit_write_offset	),
	.ctrl2hit_write_wdata	(ctrl2hit_write_wdata	),
	
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
	//Interface with wback
	.ctrl2wback_valid	(ctrl2wback_valid	),
	.ctrl2wback_index	(ctrl2wback_index	),
	.ctrl2wback_way		(ctrl2wback_way		),
	.ctrl2wback_tag		(ctrl2wback_tag		),
	.wback2ctrl_ready	(wback2ctrl_ready	),
	
	//-------------------------------------------
	//Interface with fill
	.ctrl2fill_valid	(ctrl2fill_valid	),
	.ctrl2fill_index	(ctrl2fill_index	),
	.ctrl2fill_way		(ctrl2fill_way		),
	.ctrl2fill_tag		(ctrl2fill_tag		),
	.fill2ctrl_ready	(fill2ctrl_ready	)
);

dcache_lookup u_dcache_lookup(

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

dcache_hit_read u_dcache_hit_read(

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

dcache_hit_write u_dcache_hit_write(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with ctrl
	.ctrl2hit_write_valid	(ctrl2hit_write_valid	),
	.ctrl2hit_write_wstrb	(ctrl2hit_write_wstrb	),
	.ctrl2hit_write_index	(ctrl2hit_write_index	),
	.ctrl2hit_write_way		(ctrl2hit_write_way		),
	.ctrl2hit_write_offset	(ctrl2hit_write_offset	),
	.ctrl2hit_write_wdata	(ctrl2hit_write_wdata	),
	
	//-------------------------------------------
	//Interface with data_array
	.hit_write2data_array_valid	(hit_write2data_array_valid	),  
	.hit_write2data_array_bwen	(hit_write2data_array_bwen	), 
	.hit_write2data_array_index	(hit_write2data_array_index	),  
	.hit_write2data_array_way	(hit_write2data_array_way	),
	.hit_write2data_array_offset(hit_write2data_array_offset), 
	.hit_write2data_array_wdata	(hit_write2data_array_wdata	),
	
	//-------------------------------------------
	//Interface with data_array
	.hit_write2dirty_array_valid(hit_write2dirty_array_valid),  
	.hit_write2dirty_array_index(hit_write2dirty_array_index), 
	.hit_write2dirty_array_way	(hit_write2dirty_array_way	), 	
	
	//-------------------------------------------
	//Interface with plru
	.hit_write2plru_valid	(hit_write2plru_valid),  
	.hit_write2plru_index	(hit_write2plru_index),
	.hit_write2plru_way	    (hit_write2plru_way	)
);

dcache_replace u_dcache_replace(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with ctrl
	.ctrl2replace_valid		(ctrl2replace_valid		),
	.ctrl2replace_index		(ctrl2replace_index		),
	.ctrl2replace_tag_all	(ctrl2replace_tag_all	),

	.replace2ctrl_way		(replace2ctrl_way		),
	.replace2ctrl_dirty		(replace2ctrl_dirty		),
	.replace2ctrl_tag		(replace2ctrl_tag		),
	.ctrl2replace_ready		(ctrl2replace_ready		),
			
	//-------------------------------------------
	//Interface with plru
	.replace2plru_valid	(replace2plru_valid	),
	.replace2plru_index	(replace2plru_index	),

	.plru2replace_way	(plru2replace_way	),	
	.replace2plru_ready	(replace2plru_ready	),
	
	//-------------------------------------------
	//Interface with dirty_array
	.replace2dirty_array_valid(replace2dirty_array_valid),  
	.replace2dirty_array_index(replace2dirty_array_index),
                               
	.dirty_array2replace_rdata(dirty_array2replace_rdata),
	.replace2dirty_array_ready(replace2dirty_array_ready)	
);

dcache_wback u_dcache_wback(

	.clock	(clock),
	.reset	(reset),
	
	//-------------------------------------------
	//Interface with ctrl			
	.ctrl2wback_valid	(ctrl2wback_valid	),
	.ctrl2wback_index	(ctrl2wback_index	),
	.ctrl2wback_way		(ctrl2wback_way		),
	.ctrl2wback_tag		(ctrl2wback_tag		),
	.wback2ctrl_ready	(wback2ctrl_ready	),
	
	//-------------------------------------------
	//Interface with data_array		
	.wback2data_array_valid	(wback2data_array_valid	),
	.wback2data_array_index	(wback2data_array_index	),
	.wback2data_array_way	(wback2data_array_way	),
	.wback2data_array_offset(wback2data_array_offset),

	.wback2data_array_ready	(wback2data_array_ready	),
	.data_array2wback_rdata	(data_array2wback_rdata	),
	
	//-------------------------------------------
	//Interface with axi	
	.awvalid(dcache2axi_arbiter_awvalid	),
	.awaddr	(dcache2axi_arbiter_awaddr	),
	.awid	(dcache2axi_arbiter_awid	),
	.awlen	(dcache2axi_arbiter_awlen	),
	.awsize	(dcache2axi_arbiter_awsize	),
	.awburst(dcache2axi_arbiter_awburst	),
	.awready(axi_arbiter2dcache_awready	),       

	.wvalid	(dcache2axi_arbiter_wvalid	),
	.wdata	(dcache2axi_arbiter_wdata	),
	.wstrb	(dcache2axi_arbiter_wstrb	),
	.wlast	(dcache2axi_arbiter_wlast	),
	.wready	(axi_arbiter2dcache_wready	),

	.bready	(dcache2axi_arbiter_bready	),
	.bvalid	(axi_arbiter2dcache_bvalid	),
	.bresp 	(axi_arbiter2dcache_bresp 	),
	.bid   	(axi_arbiter2dcache_bid   	)
);

dcache_fill u_dcache_fill(

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
	//Interface with dirty_array	
	.fill2dirty_array_valid	(fill2dirty_array_valid	),  
	.fill2dirty_array_index	(fill2dirty_array_index	),
	.fill2dirty_array_way	(fill2dirty_array_way	), 
	
	//-------------------------------------------
	//Interface with axi	
	.arvalid	(dcache2axi_arbiter_arvalid	),
	.araddr 	(dcache2axi_arbiter_araddr 	),
	.arid   	(dcache2axi_arbiter_arid   	),
	.arlen  	(dcache2axi_arbiter_arlen  	),
	.arsize 	(dcache2axi_arbiter_arsize 	),
	.arburst	(dcache2axi_arbiter_arburst	),
	.arready	(axi_arbiter2dcache_arready	),

	.rready 	(dcache2axi_arbiter_rready 	),
	.rvalid 	(axi_arbiter2dcache_rvalid 	),
	.rresp  	(axi_arbiter2dcache_rresp  	),
	.rdata  	(axi_arbiter2dcache_rdata  	),
	.rlast  	(axi_arbiter2dcache_rlast  	),
	.rid    	(axi_arbiter2dcache_rid    	)	
);

dcache_data_array u_dcache_data_array(

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
	//Interface with hit_write	
	.hit_write2data_array_valid		(hit_write2data_array_valid		),  
	.hit_write2data_array_bwen		(hit_write2data_array_bwen		), 
	.hit_write2data_array_index		(hit_write2data_array_index		),  
	.hit_write2data_array_way		(hit_write2data_array_way		),
	.hit_write2data_array_offset	(hit_write2data_array_offset	), 
	.hit_write2data_array_wdata		(hit_write2data_array_wdata		),
	
	//-------------------------------------------
	//Interface with fill	
	.fill2data_array_valid	(fill2data_array_valid	),
	.fill2data_array_index	(fill2data_array_index	),  
	.fill2data_array_way	(fill2data_array_way	), 
	.fill2data_array_offset	(fill2data_array_offset	), 
	.fill2data_array_wdata	(fill2data_array_wdata	),
	
	//-------------------------------------------
	//Interface with wback	
	.wback2data_array_valid	(wback2data_array_valid	),  
	.wback2data_array_index	(wback2data_array_index	),   
	.wback2data_array_way	(wback2data_array_way	),
	.wback2data_array_offset(wback2data_array_offset),
	.wback2data_array_ready	(wback2data_array_ready	),
	.data_array2wback_rdata	(data_array2wback_rdata	)		
);

dcache_tag_array u_dcache_tag_array(

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

dcache_valid_array u_dcache_valid_array(

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

dcache_dirty_array u_dcache_dirty_array(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with replace
	.replace2dirty_array_valid	(replace2dirty_array_valid),  
	.replace2dirty_array_index	(replace2dirty_array_index),  
	.replace2dirty_array_ready	(replace2dirty_array_ready),	
	.dirty_array2replace_rdata	(dirty_array2replace_rdata),
	
	//-------------------------------------------
	//Interface with hit_write
	.hit_write2dirty_array_valid	(hit_write2dirty_array_valid	),  
	.hit_write2dirty_array_index	(hit_write2dirty_array_index	), 
	.hit_write2dirty_array_way		(hit_write2dirty_array_way		), 	  
	
	//-------------------------------------------
	//Interface with fill
	.fill2dirty_array_valid	(fill2dirty_array_valid	),  
	.fill2dirty_array_index	(fill2dirty_array_index	),
	.fill2dirty_array_way	(fill2dirty_array_way	)	
);

dcache_plru u_dcache_plru(

	.clock(clock),
	.reset(reset),
	
	//-------------------------------------------
	//Interface with hit_read
	.hit_read2plru_valid	(hit_read2plru_valid	),  
	.hit_read2plru_index	(hit_read2plru_index	),
	.hit_read2plru_way		(hit_read2plru_way		), 			
	
	//-------------------------------------------
	//Interface with hit_write
	.hit_write2plru_valid	(hit_write2plru_valid	),  
	.hit_write2plru_index	(hit_write2plru_index	), 
	.hit_write2plru_way		(hit_write2plru_way		), 	 
	
	//-------------------------------------------
	//Interface with replace
	.replace2plru_valid	(replace2plru_valid	),  
	.replace2plru_index	(replace2plru_index	),  
	.replace2plru_ready	(replace2plru_ready	),  	
	.plru2replace_way	(plru2replace_way	)
);

endmodule
