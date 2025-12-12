library verilog;
use verilog.vl_types.all;
entity RhythmGame_Top is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(3 downto 0);
        SW              : in     vl_logic_vector(9 downto 0);
        HEX0            : out    vl_logic_vector(6 downto 0);
        HEX1            : out    vl_logic_vector(6 downto 0);
        HEX2            : out    vl_logic_vector(6 downto 0);
        HEX3            : out    vl_logic_vector(6 downto 0);
        HEX4            : out    vl_logic_vector(6 downto 0);
        HEX5            : out    vl_logic_vector(6 downto 0);
        LEDR            : out    vl_logic_vector(9 downto 0);
        o_DM_Row        : out    vl_logic_vector(7 downto 0);
        o_DM_Col        : out    vl_logic_vector(7 downto 0);
        o_Piezo         : out    vl_logic
    );
end RhythmGame_Top;
