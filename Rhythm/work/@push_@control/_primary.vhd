library verilog;
use verilog.vl_types.all;
entity Push_Control is
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        i_Push          : in     vl_logic_vector(3 downto 0);
        o_fPush         : out    vl_logic_vector(3 downto 0)
    );
end Push_Control;
