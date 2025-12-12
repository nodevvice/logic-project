`timescale 1ns / 1ps

module Tb_RhythmGame;

    // Inputs
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;

    // Outputs
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;
    wire [7:0] o_DM_Row, o_DM_Col;
    wire o_Piezo;

    // Instantiate the Unit Under Test (UUT)
    RhythmGame_Top uut (
        .CLOCK_50(CLOCK_50), 
        .KEY(KEY), 
        .SW(SW), 
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), 
        .LEDR(LEDR), 
        .o_DM_Row(o_DM_Row), 
        .o_DM_Col(o_DM_Col), 
        .o_Piezo(o_Piezo)
    );

    // Clock Generation (50MHz -> Period 20ns)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Test Scenario
    initial begin
        // 1. 초기화
        $display("Sim Start: Initialize");
        KEY = 4'b1111; // 버튼 안 누름 (Active Low라 1이 떼어진 상태)
        SW = 10'd0;    // 리셋 상태 (SW[9]=0)
        
        #100;
        
        // 2. 리셋 해제 및 설정
        $display("Reset Release");
        SW[9] = 1;     // Active Low Reset 해제
        SW[1:0] = 2'b00; // 속도 1배
        
        #100;

        // 3. 게임 시작
        $display("Game Start Trigger");
        SW[8] = 1;     // Start Button ON
        #40;
        SW[8] = 0;     // Start Button OFF
        
        // 4. 게임 진행 대기 (노트가 내려오는 시간)
        // 시뮬레이션 시간을 줄이기 위해 GameLogic의 속도 상수를 줄여서 테스트하거나,
        // 여기서는 단순히 동작 여부만 확인하기 위해 넉넉히 기다립니다.
        $display("Wait for Notes...");
        #1000000; // 1ms 경과 (실제로는 노트가 떨어지기에 짧지만, 로직 흐름 확인용)
        
        // 5. 버튼 입력 테스트 (Lane 0 입력)
        $display("Key 0 Press");
        KEY[0] = 0; // 누름
        #200000;    // 꾹 누르고 있음 (디바운싱 테스트)
        KEY[0] = 1; // 뗌
        
        // 6. 결과 관찰
        #100000;
        
        $display("Test Finished");
        $stop;
    end

endmodule