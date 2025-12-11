module OnePushControl(
    input  wire i_Clk,
    input  wire i_Rst,      // Active-Low Reset
    input  wire i_Push,     // Active-Low Input (DE1-SoC KEY: 누르면 0)

    output reg  o_fPush     // 1클럭 펄스 출력 (누르는 순간 1)
);

    //=============================
    // 1. 입력 반전 및 동기화
    //=============================
    // DE1-SoC 버튼은 누르면 0이므로, 내부 로직을 편하게 하기 위해 반전(~) 시킴
    wire w_PushActiveHigh = ~i_Push; 

    parameter DEBOUNCE_MAX = 500_000

    reg r_PushSync0;
    reg r_PushSync1;

    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_PushSync0 <= 1'b0;
            r_PushSync1 <= 1'b0;
        end else begin
            r_PushSync0 <= w_PushActiveHigh; // 반전된 신호를 동기화
            r_PushSync1 <= r_PushSync0;
        end
    end

    wire w_Push = r_PushSync1; // 이제 '1'이면 눌린 상태

    //=============================
    // 2. FSM 상태 정의
    //=============================
    localparam S_IDLE  = 2'd0;
    localparam S_PULSE = 2'd1;
    localparam S_WAIT  = 2'd2;

    reg [1:0]  r_State, r_NextState;
    reg [18:0] r_Cnt; // 타이머

    //=============================
    // 3. 상태 레지스터 및 타이머
    //=============================
    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_State <= S_IDLE;
            r_Cnt   <= 19'd0;
        end else begin
            r_State <= r_NextState;

            // 타이머 로직: WAIT 상태에서만 카운트 증가
            if (r_State == S_WAIT) begin
                if (r_Cnt < DEBOUNCE_MAX)
                    r_Cnt <= r_Cnt + 1'b1;
            end else begin
                r_Cnt <= 19'd0; // 다른 상태면 리셋
            end
        end
    end

    //=============================
    // 4. 다음 상태 결정 (Combinational)
    //=============================
    always @(*) begin
        r_NextState = r_State;
        o_fPush     = 1'b0;

        case (r_State)
            S_IDLE: begin
                // 버튼이 눌리면(1) PULSE 상태로 이동
                if (w_Push == 1'b1) 
                    r_NextState = S_PULSE;
            end

            S_PULSE: begin
                // 출력 1 발생 후 즉시 대기 상태로
                o_fPush     = 1'b1;
                r_NextState = S_WAIT;
            end

            S_WAIT: begin
                // 디바운싱 시간(10ms)이 지났는지 확인
                if (r_Cnt >= DEBOUNCE_MAX) begin
                    // 시간이 지났는데 버튼이 떼어졌다면(0) IDLE로 복귀
                    if (w_Push == 1'b0)
                        r_NextState = S_IDLE;
                    // 여전히 눌려있다면 여기서 대기 (누르고 있는 동안 연타 방지)
                end
            end
            
            default: r_NextState = S_IDLE;
        endcase
    end

endmodule