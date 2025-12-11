module One_PushControl(
    input  wire i_Clk,
    input  wire i_Rst,
    input  wire i_Push,     // 스위치(버튼) 입력

    output reg  o_fPush     // 정제된 1클럭 펄스 출력
);

    //=============================
    // 1. 입력 동기화 (메타 안정성 + 노이즈 줄이기)
    //=============================
    reg r_PushSync0;
    reg r_PushSync1;

    parameter DEBOUNCE_MAX = 500_000;  // 10ms @ 50MHz 기준

    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_PushSync0 <= 1'b0;
            r_PushSync1 <= 1'b0;
        end else begin
            r_PushSync0 <= i_Push;
            r_PushSync1 <= r_PushSync0;
        end
    end

    wire w_Push = r_PushSync1;

    //=============================
    // 2. FSM 상태 정의
    //=============================
    localparam S_IDLE  = 2'd0;  // 버튼 안 눌림, 대기
    localparam S_PULSE = 2'd1;  // 1클럭 펄스 출력
    localparam S_WAIT  = 2'd2;  // 10ms 동안 디바운스 구간

    reg [1:0] r_State;
    reg [1:0] r_NextState;

    // 타이머 (10ms 카운트)
    reg [18:0] r_Cnt;  // 2^19 = 524,288 > 500,000 이라서 19비트면 충분

    //=============================
    // 3. 상태 레지스터
    //=============================
    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_State <= S_IDLE;
        end else begin
            r_State <= r_NextState;
        end
    end

    //=============================
    // 4. 타이머 동작
    //   S_WAIT일 때만 카운트, 나머지 상태에서는 0으로
    //=============================
    always @(posedge i_Clk or negedge i_Rst) begin
        if (!i_Rst) begin
            r_Cnt <= 19'd0;
        end else begin
            case (r_State)
                S_WAIT: begin
                    if (r_Cnt < (DEBOUNCE_MAX - 1))
                        r_Cnt <= r_Cnt + 1'b1;
                    else
                        r_Cnt <= r_Cnt;  // 최대치 유지
                end

                default: begin
                    r_Cnt <= 19'd0;
                end
            endcase
        end
    end

    //=============================
    // 5. 콤비네이셔널 로직 (다음 상태 & 출력)
    //=============================
    always @(*) begin
        // 기본값
        r_NextState = r_State;
        o_fPush     = 1'b0;

        case (r_State)
            //------------------------------------
            // 버튼 안 눌린 상태
            //------------------------------------
            S_IDLE: begin
                if (w_Push == 1'b1) begin
                    // 버튼이 눌리는 순간 → 펄스 발생 상태로
                    r_NextState = S_PULSE;
                end
            end

            //------------------------------------
            // 펄스 상태: o_fPush 1클럭만 1
            //------------------------------------
            S_PULSE: begin
                o_fPush     = 1'b1;      // 이 상태에서만 1 클럭 출력
                r_NextState = S_WAIT;    // 바로 WAIT 상태로 진입
            end

            //------------------------------------
            // 디바운스 대기 상태
            //------------------------------------
            S_WAIT: begin
                if (r_Cnt >= (DEBOUNCE_MAX - 1)) begin
                    // 10ms 다 지나고, 버튼이 떼어져 있으면 다시 IDLE
                    if (w_Push == 1'b0)
                        r_NextState = S_IDLE;
                    // 버튼이 여전히 눌려 있으면, 사용자가 손을 떼기 전까지 기다림
                end
            end

            default: begin
                r_NextState = S_IDLE;
            end
        endcase
    end

endmodule
