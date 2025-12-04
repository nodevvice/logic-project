module One_Push_Unit (
    input i_Clk,
    input i_Rst_n,
    input i_Raw_1bit,      // 버튼 1개 입력
    output reg o_Pulse_1bit // 버튼 1개 출력
);

    reg [1:0] state;
    reg [19:0] timer;

    // 상태 상수 정의
    parameter S_IDLE = 2'd0;
    parameter S_LOCK = 2'd1;
    // 10ms 대기 시간 (50MHz 기준 500,000)
    parameter LOCK_TIME = 20'd500_000; 

    always @(posedge i_Clk or negedge i_Rst_n) begin
        if (!i_Rst_n) begin
            state <= S_IDLE;
            timer <= 20'd0;
            o_Pulse_1bit <= 1'b0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    // 버튼이 눌리면 (1이 들어오면)
                    if (i_Raw_1bit == 1'b1) begin
                        o_Pulse_1bit <= 1'b1;    // [즉시 발사!]
                        timer <= LOCK_TIME;      // 타이머 장전
                        state <= S_LOCK;         // 잠금 상태로 이동
                    end
                    else begin
                        o_Pulse_1bit <= 1'b0;
                    end
                end

                S_LOCK: begin
                    o_Pulse_1bit <= 1'b0; // 펄스는 바로 끔

                    if (timer > 0) begin
                        timer <= timer - 1; // 시간 줄이기
                    end
                    else begin
                        // 시간 다 됐고 + 버튼 뗐으면 복귀
                        if (i_Raw_1bit == 1'b0) begin
                            state <= S_IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule