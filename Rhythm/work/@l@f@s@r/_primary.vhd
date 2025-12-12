library verilog;
use verilog.vl_types.all;
entity LFSR is
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        o_Rand          : out    vl_logic_vector(7 downto 0)
    );
end LFSR;
