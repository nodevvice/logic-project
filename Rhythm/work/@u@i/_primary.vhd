library verilog;
use verilog.vl_types.all;
entity UI is
    port(
        i_Score         : in     vl_logic_vector(15 downto 0);
        i_Combo         : in     vl_logic_vector(7 downto 0);
        i_Sound_Cmd     : in     vl_logic_vector(1 downto 0);
        o_HEX0          : out    vl_logic_vector(6 downto 0);
        o_HEX1          : out    vl_logic_vector(6 downto 0);
        o_HEX2          : out    vl_logic_vector(6 downto 0);
        o_HEX3          : out    vl_logic_vector(6 downto 0);
        o_HEX4          : out    vl_logic_vector(6 downto 0);
        o_HEX5          : out    vl_logic_vector(6 downto 0);
        o_Piezo         : out    vl_logic
    );
end UI;
