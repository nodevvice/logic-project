module ScoreCounter (
    input  wire        i_Clk,
    input  wire        i_Rst,
    input  wire        i_ResetScore,  // 게임 시작 시 1클럭
    input  wire        i_Hit,         // Hit 1클럭

    output reg  [13:0] o_Score        // 0 ~ 9999
);

    parameter [13:0] BASE_SCORE = 14'd5,  // 한 번 맞출 때마다 더할 점수
    parameter [13:0] MAX_SCORE  = 14'd9999  // 4자리 최대
    
    wire [14:0] w_NextScoreWide;

    assign w_NextScoreWide = o_Score + BASE_SCORE;

    always @(posedge i_Clk or posedge i_Rst) begin
        if (i_Rst) begin
            o_Score <= 14'd0;
        end else if (i_ResetScore) begin
            o_Score <= 14'd0;
        end else if (i_Hit) begin
            // 9999에서 포화
            if (w_NextScoreWide[13:0] >= MAX_SCORE || w_NextScoreWide[14])
                o_Score <= MAX_SCORE;
            else
                o_Score <= w_NextScoreWide[13:0];
        end
    end

endmodule
