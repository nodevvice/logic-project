library verilog;
use verilog.vl_types.all;
entity DotMatrix is
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        i_Data          : in     vl_logic_vector(63 downto 0);
        o_DM_Col        : out    vl_logic_vector(7 downto 0);
        o_DM_Row        : out    vl_logic_vector(7 downto 0);
        o_fDone         : out    vl_logic
    );
end DotMatrix;
