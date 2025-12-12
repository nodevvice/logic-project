library verilog;
use verilog.vl_types.all;
entity FND is
    port(
        sel             : in     vl_logic_vector(3 downto 0);
        o_FND           : out    vl_logic_vector(6 downto 0)
    );
end FND;
