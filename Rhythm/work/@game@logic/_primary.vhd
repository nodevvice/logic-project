library verilog;
use verilog.vl_types.all;
entity GameLogic is
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        i_Pulse         : in     vl_logic_vector(3 downto 0);
        i_Rand_Val      : in     vl_logic_vector(7 downto 0);
        i_Speed_Opt     : in     vl_logic_vector(1 downto 0);
        i_View_Mode     : in     vl_logic;
        i_Start_Btn     : in     vl_logic;
        o_Map_Data      : out    vl_logic_vector(63 downto 0);
        o_Score         : out    vl_logic_vector(15 downto 0);
        o_Combo         : out    vl_logic_vector(7 downto 0);
        o_HP            : out    vl_logic_vector(9 downto 0);
        o_Sound_Cmd     : out    vl_logic_vector(1 downto 0)
    );
end GameLogic;
