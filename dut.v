module dut #(
    parameter N = 9
)(
    input           clk,
    input           rst,
    input           in_valid,
    input [7 :  0]  in,
    output reg      in_ready,
    output          out_ready,
    output[7 :  0]  out
);
//function
function    [15 :0] swapper ;
    input   [7:0] a ;
    input   [7:0] b ;
    begin
        if (a>b)
            swapper={a,b};
        else
            swapper={b,a};
    end
endfunction

localparam IDLE=4'd0;
localparam INPUT_DATA=4'd1;
localparam CALC=4'd2;
genvar g;

reg     [2  :0] state;
reg     [2  :0] state_nxt;

reg     [7  :0] data[0:8];
reg     [7  :0] data_nxt_sel_0[0:8];
reg     [7  :0] data_nxt_swp_0[0:8];
reg     [7  :0] data_nxt_sel_1[0:8];
reg     [7  :0] data_nxt_swp_1[0:8];
reg     [7  :0] data_nxt_sel_2[0:8];
reg     [7  :0] data_nxt_swp_2[0:8];
reg     [7  :0] data_nxt[0:8];

reg     [3  :0] cnt_input;
reg     [3  :0] cnt_calc;

wire    [7  :0] probe_0;
wire    [7  :0] probe_1;
wire    [7  :0] probe_2;
wire    [7  :0] probe_3;
wire    [7  :0] probe_4;
wire    [7  :0] probe_5;
wire    [7  :0] probe_6;
wire    [7  :0] probe_7;
wire    [7  :0] probe_8;

assign probe_0 = data[0];
assign probe_1 = data[1];
assign probe_2 = data[2];
assign probe_3 = data[3];
assign probe_4 = data[4];
assign probe_5 = data[5];
assign probe_6 = data[6];
assign probe_7 = data[7];
assign probe_8 = data[8];

always@(*)begin
    state_nxt=state;
    if(state==IDLE)begin
        if(in_ready)
            state_nxt=INPUT_DATA;
    end
    else if(state==INPUT_DATA)begin
        if(cnt_input==9)
            state_nxt=CALC;
    end
    else if(state==CALC)begin
        if (out_ready)begin
            state_nxt=IDLE;
        end
    end 
end
always@(posedge clk or negedge rst)begin
    if(!rst)
        state<=IDLE;
    else
        state<=state_nxt;
end

always @(posedge clk or negedge rst) begin
    if(!rst)
        in_ready<=0;
    else begin
        if (state==IDLE)
            in_ready<=1;
        else if(in_valid)
            in_ready<=0;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)
        cnt_input<=0;
    else begin
        if (in_valid)
            cnt_input<=cnt_input+1;
        else if(cnt_input==9)
            cnt_input<=0;
    end
end

always @(posedge clk or negedge rst) begin
    if(!rst)
        cnt_calc<=0;
    else begin
        if (state==CALC)
            cnt_calc<=cnt_calc+1;
        else if(cnt_calc>=3)
            cnt_calc<=0;
    end
end

generate
for(g=0;g<9;g=g+1)begin: data_sel_0
    always@(*)begin
        data_nxt_sel_0[g]=  (state!=CALC)   ?0:
                            (cnt_calc==0)   ?data[g]:
                            data[8-g];
    end
end
endgenerate

generate
for(g=0;g<4;g=g+1)begin: data_swp_0
    always@(*)begin
        {data_nxt_swp_0[2*g+1],data_nxt_swp_0[2*g]}=    swapper(data_nxt_sel_0[2*g+1],data_nxt_sel_0[2*g]);
    end
end
always@(*)begin
    data_nxt_swp_0[8]= data_nxt_sel_0[8];
end
endgenerate

generate
always@(*)begin
    data_nxt_sel_1[8]=  data_nxt_swp_0[8];
end
for(g=0;g<4;g=g+1)begin: data_sel_1
    always@(*)begin
        data_nxt_sel_1[2*g+0]=  (cnt_calc[0])? data_nxt_swp_0[2*g+1] : data_nxt_swp_0[2*g+0];
        data_nxt_sel_1[2*g+1]=  (cnt_calc[0])? data_nxt_swp_0[2*g+0] : data_nxt_swp_0[2*g+1];
    end
end
endgenerate

generate
for(g=0;g<4;g=g+1)begin: data_swp_1
    always@(*)begin
        {data_nxt_swp_1[2*g+2],data_nxt_swp_1[2*g+1]}=    swapper(data_nxt_sel_1[2*g+2],data_nxt_sel_1[2*g+1]);
    end
end
always@(*)begin
    data_nxt_swp_1[0]= data_nxt_sel_1[0];
end
endgenerate

generate
always@(*)begin
    data_nxt_sel_2[0]=  data_nxt_swp_1[0];
end
for(g=0;g<4;g=g+1)begin: data_sel_2
    always@(*)begin
        data_nxt_sel_2[2*g+1]=  (cnt_calc[0])? data_nxt_swp_1[2*g+2] : data_nxt_swp_1[2*g+1];
        data_nxt_sel_2[2*g+2]=  (cnt_calc[0])? data_nxt_swp_1[2*g+1] : data_nxt_swp_1[2*g+2];
    end
end
endgenerate

generate
for(g=0;g<4;g=g+1)begin: data_swp_2
    always@(*)begin
        {data_nxt_swp_2[2*g+1],data_nxt_swp_2[2*g]}=    swapper(data_nxt_sel_2[2*g+1],data_nxt_sel_2[2*g]);
    end
end
always@(*)begin
    data_nxt_swp_2[8]= data_nxt_sel_2[8];
end
endgenerate

generate
always@(*)begin
    data_nxt[8]=  data_nxt_swp_2[8];
end
for(g=0;g<4;g=g+1)begin: data_sel_3
    always@(*)begin
        data_nxt[2*g+0]=  (cnt_calc[0])? data_nxt_swp_2[2*g+1] : data_nxt_swp_2[2*g+0];
        data_nxt[2*g+1]=  (cnt_calc[0])? data_nxt_swp_2[2*g+0] : data_nxt_swp_2[2*g+1];
    end
end
endgenerate

generate
for(g=0;g<8;g=g+1)begin: data_reg
    always@(posedge clk or negedge rst)begin
        if(!rst)
            data[g]<=0;
        else begin
            if (in_valid)
                data[g]<=data[g+1];
            else if(state==CALC)
                data[g]<=data_nxt[g];
        end
    end
end
always@(posedge clk or negedge rst)begin
    if(!rst)
        data[8]<=0;
    else begin
        if (in_valid)
            data[8]<=in;
        else if(state==CALC)
            data[8]<=data_nxt[8];
    end
end
endgenerate

assign out_ready=(cnt_calc==3);
assign out=data[4];


endmodule