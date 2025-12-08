module LFSR(i_Clk, i_Rst, o_Rand);

    input  wire       i_Clk;   
    input  wire       i_Rst_n;    
    
    // [7:4]: 노트 패턴 (어떤 레인에 나올지)
    // [3:0]: 생성 확률 (노트를 만들지 말지)
    output wire [7:0] o_Rand  

    reg  [15:0] r_LFSR;     // 16비트 레지스터 (내부용)
    wire        w_Feedback;

    // 16비트 최대 길이 다항식 (Tap: 16, 14, 13, 11)
    assign w_Feedback = r_LFSR[15] ^ r_LFSR[13] ^ r_LFSR[12] ^ r_LFSR[10];

    always@(posedge i_Clk, negedge i_Rst)
    begin
        if (!i_Rst) begin
            // 0이 아닌 초기값 (Seed)
            r_LFSR <= 16'h1234; 
        end
        else begin
            // Shift Left & Feedback
            r_LFSR <= {r_LFSR[14:0], w_Feedback};
        end
    end

    // [수정됨] 내부 16비트 중 하위 8비트를 잘라서 출력
    assign o_Rand = r_LFSR[7:0];

endmodule