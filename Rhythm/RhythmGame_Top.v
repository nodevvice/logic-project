module RhythmGame_Top (
    input  wire        CLOCK_50,    // 50MHz 시스템 클럭
    input  wire [3:0]  KEY,         // 게임 플레이 버튼 (Lanes 3,2,1,0)
    input  wire [9:0]  SW,          // 제어 스위치 (Reset, Start, Option)

    output wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, // 7-Segment
    output wire [9:0]  LEDR,        // HP 게이지
    
    // 도트 매트릭스 연결용 GPIO (외부 핀)
    // Row: GPIO[7:0], Col: GPIO[15:8] 라고 가정
    output wire [7:0]  o_DM_Row, 
    output wire [7:0]  o_DM_Col,
    
    output wire        o_Piezo      // 부저 (현재는 Mute)
);

    // ==========================================
    // 1. 내부 신호 선언
    // ==========================================
    wire        w_Rst_n;      // Active Low Reset
    wire [3:0]  w_Push_Pulse; // 정제된 버튼 입력
    wire [7:0]  w_Rand_Val;   // LFSR 난수
    
    wire [63:0] w_Map_Data;   // 게임 로직 -> 도트 매트릭스 데이터
    wire [15:0] w_Score;
    wire [7:0]  w_Combo;
    wire [1:0]  w_Sound_Cmd;
    wire [9:0]  w_HP;

    // Reset: SW[9] 사용 (Switch Down = 0 = Active Low Reset)
    assign w_Rst_n = SW[9];

    // ==========================================
    // 2. 모듈 인스턴스화 (Connection)
    // ==========================================

    // [1] 난수 생성기
    LFSR u_LFSR (
        .i_Clk   (CLOCK_50),
        .i_Rst   (w_Rst_n),
        .o_Rand  (w_Rand_Val)
    );

    // [2] 버튼 입력 제어 (Debounce + Edge Detect)
    // KEY 입력은 하드웨어적으로 Active Low이지만, 
    // OnePushControl 내부에서 반전 처리하도록 수정했으므로 그대로 연결
    PushControl u_Input (
        .i_Clk   (CLOCK_50),
        .i_Rst   (w_Rst_n),
        .i_Push  (KEY),         // KEY[3:0] -> Lane 3,2,1,0
        .o_fPush (w_Push_Pulse)
    );

    // [3] 게임 메인 로직
    GameLogic u_GameCore (
        .i_Clk       (CLOCK_50),
        .i_Rst       (w_Rst_n),
        .i_Pulse     (w_Push_Pulse),
        .i_Rand_Val  (w_Rand_Val),
        
        .i_Speed_Opt (SW[1:0]),     // SW 0,1번으로 속도 조절
        .i_View_Mode (SW[2]),       // SW 2번으로 High Score 보기
        .i_Start_Btn (SW[8]),       // SW 8번으로 게임 시작
        
        .o_Map_Data  (w_Map_Data),
        .o_Score     (w_Score),
        .o_Combo     (w_Combo),
        .o_HP        (w_HP),
        .o_Sound_Cmd (w_Sound_Cmd)
    );

    // [4] 화면 출력 (도트 매트릭스 드라이버)
    DotMatrix u_Display (
        .i_Clk      (CLOCK_50),
        .i_Rst      (w_Rst_n),
        .i_Data     (w_Map_Data),
        .o_DM_Col   (o_DM_Col),     // -> GPIO 핀 연결
        .o_DM_Row   (o_DM_Row),     // -> GPIO 핀 연결
        .o_fDone    ()              // 사용 안 함
    );

    // [5] UI (7-Segment & Sound)
    UI u_UI (
        .i_Clk       (CLOCK_50),
        .i_Rst_n     (w_Rst_n),
        .i_Score     (w_Score),
        .i_Combo     (w_Combo),
        .i_Sound_Cmd (w_Sound_Cmd),
        
        .o_HEX0(HEX0), .o_HEX1(HEX1), .o_HEX2(HEX2), .o_HEX3(HEX3),
        .o_HEX4(HEX4), .o_HEX5(HEX5),
        .o_Piezo(o_Piezo)
    );

    // [6] LED 표시 (HP)
    assign LEDR = w_HP;

endmodule
