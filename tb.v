`timescale 1ns / 1ps  
//`include "DUT.v"    

//gtkwave build/wave.vcd 
module tb();   
    localparam IDLE=4'd0;
    localparam INPUT_DATA=4'd1;
    localparam WAIT_OUTPUT=4'd2;    
    integer i;
    
    reg             rst;
    reg             clk;
    reg             in_valid;
    reg     [7  :0] in;
    wire            in_ready;
    wire            out_ready;
    wire    [7  :0] out;

    reg     [4  :0] cnt;
    reg     [7  :0] data[0:8];
    reg     [3  :0] state;
    reg     [3  :0] state_nxt;
    reg             done;
    initial begin
        forever begin
            #4 clk=~clk;
        end
    end

    initial begin
        rst=1;
        #1 rst=0;
        #1 rst=1;
    end
    
    initial begin
        clk=0;
        cnt=0;
        in_valid=0;
        in=0;
        cnt=0;
        state=0;
        done=0;
    end
    
    always@(*)begin
        state_nxt=state;
        if(state==IDLE)begin
            if(in_ready)
                state_nxt=INPUT_DATA;
        end
        else if(state==INPUT_DATA)begin
            if(cnt==8)
                state_nxt=WAIT_OUTPUT;
        end
    end
    always@(posedge clk)begin
        state<=state_nxt;
    end

    always@(posedge clk)begin
        if(state==INPUT_DATA)
            cnt<=cnt+1;
    end

    always@(posedge clk)begin
        if(state==IDLE && in_ready)begin
            in_valid<=1;
        end
        else if(state==INPUT_DATA && cnt==8)begin
            in_valid<=0;
        end
    end

    always@(*)begin
        if (cnt<9 && in_valid)
            in=data[cnt];
        else
            in=0; 
    end

    initial begin
        $readmemb("./data.txt",data);
    end
    dut #( 
        .N(9)
    ) my_dut (
    .clk        (clk      ),        
    .rst        (rst      ),        
    .in_valid   (in_valid ),               
    .in         (in       ),    
    .in_ready   (in_ready ),            
    .out_ready  (out_ready),            
    .out        (out      )             
    );

    
    always @(posedge clk) begin
        if (state==WAIT_OUTPUT && out_ready)begin
            $display("ans: %d",out);
            #8;
            done<=1;
        end
    end

    always @(posedge clk) begin
        if (done)begin
            $display("done");
            $finish;
        end
    end

    initial begin
        #200;
        $display("time out");
        $finish;
    end
    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars;
    end
endmodule