
module DotMatrix(i_Clk, i_Rst, i_Data, o_DM_Col, o_DM_Row, o_fDone);
 input i_Clk;
 input i_Rst;
 input [63:0] i_Data;
 output wire [7:0] o_DM_Col, o_DM_Row;
 output wire o_fDone;
 reg [7:0] c_Row, n_Row;
 reg [16:0] c_Cnt, n_Cnt;
 wire f2ms;

 assign o_fDone = c_Row[7] && f2ms;
 assign o_DM_Row = c_Row;
 assign o_DM_Col =
    (c_Row[7] ? i_Data[8*7+:8] : 0) |
    (c_Row[6] ? i_Data[8*6+:8] : 0) |
    (c_Row[5] ? i_Data[8*5+:8] : 0) |
    (c_Row[4] ? i_Data[8*4+:8] : 0) |
    (c_Row[3] ? i_Data[8*3+:8] : 0) |
    (c_Row[2] ? i_Data[8*2+:8] : 0) |
    (c_Row[1] ? i_Data[8*1+:8] : 0) |
    (c_Row[0] ? i_Data[8*0+:8] : 0);

 assign f2ms = c_Cnt== 100000 -1;
 
 always@(posedge i_Clk, negedge i_Rst)
 if(!i_Rst) begin
    c_Row= 1;
    c_Cnt = 0;
    end
    else begin
        c_Row= n_Row;
        c_Cnt = n_Cnt;
    end

 always@*
    begin
        n_Cnt = f2ms ? 0 : c_Cnt+ 1;
        n_Row = f2ms ? {c_Row[6:0], c_Row[7]} : c_Row;
    end
 endmodule