module UI (
    input  wire        i_Clk,
    input  wire        i_Rst_n,
    input  wire [15:0] i_Score,      // 0 ~ 9999 점수
    input  wire [7:0]  i_Combo,      // 0 ~ 99 콤보
    input  wire [1:0]  i_Sound_Cmd,  // (나중에 사운드용)
    
    // Top Module의 핀으로 나가는 신호들
    output wire [6:0]  o_HEX0, o_HEX1, o_HEX2, o_HEX3, // 점수
    output wire [6:0]  o_HEX4, o_HEX5,                 // 콤보
    output wire        o_Piezo                         // 부저
);

    // ---------------------------------------------
    // 1. 점수 분리 (Binary to BCD)
    // 간단하게 % 10 연산으로 자릿수 분리 (합성 시 자원 좀 먹지만 가장 쉬움)
    // ---------------------------------------------
    wire [3:0] score_1    = i_Score % 10;
    wire [3:0] score_10   = (i_Score / 10) % 10;
    wire [3:0] score_100  = (i_Score / 100) % 10;
    wire [3:0] score_1000 = (i_Score / 1000) % 10;

    wire [3:0] combo_1    = i_Combo % 10;
    wire [3:0] combo_10   = (i_Combo / 10) % 10;

    // ---------------------------------------------
    // 2. FND 모듈 6개 장착 (재사용!)
    // ---------------------------------------------
    
    // 점수 표시 (HEX 3-2-1-0)
    FND u_Score_0 (.sel(score_1),    .o_FND(o_HEX0));
    FND u_Score_1 (.sel(score_10),   .o_FND(o_HEX1));
    FND u_Score_2 (.sel(score_100),  .o_FND(o_HEX2));
    FND u_Score_3 (.sel(score_1000), .o_FND(o_HEX3));

    // 콤보 표시 (HEX 5-4)
    FND u_Combo_0 (.sel(combo_1),    .o_FND(o_HEX4));
    FND u_Combo_1 (.sel(combo_10),   .o_FND(o_HEX5));

    // ---------------------------------------------
    // 3. 사운드 (간단한 멜로디 톤)
    // ---------------------------------------------
    Sound u_Sound (
        .i_Clk      (i_Clk),
        .i_Rst_n    (i_Rst_n),
        .i_Sound_Cmd(i_Sound_Cmd),
        .o_Piezo    (o_Piezo)
    );

endmodule
