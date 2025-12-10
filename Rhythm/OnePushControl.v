module Push_Control (
    input  wire       i_Clk,
    input  wire       i_Rst,
    input  wire [3:0] i_Push,    // 4비트 입력
    output wire [3:0] o_fPush    // 4비트 출력
);

    // [버튼 0]
    One_PushControl u_Btn0 (
        .i_Clk(i_Clk), .i_Rst(i_Rst),
        .i_Push(i_Push[0]), .o_fPush(o_fPush[0])
    );

    // [버튼 1]
    One_PushControl u_Btn1 (
        .i_Clk(i_Clk), .i_Rst(i_Rst),
        .i_Push(i_Push[1]), .o_fPush(o_fPush[1])
    );

    One_PushControl u_Btn2 (
        .i_Clk(i_Clk), .i_Rst(i_Rst),
        .i_Push(i_Push[2]), .o_fPush(o_fPush[2])
    );

    One_PushControl u_Btn3 (
        .i_Clk(i_Clk), .i_Rst(i_Rst),
        .i_Push(i_Push[3]), .o_fPush(o_fPush[3])
    );

endmodule