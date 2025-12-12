library verilog;
use verilog.vl_types.all;
entity OnePushControl is
    generic(
        DEBOUNCE_MAX    : integer := 500000
    );
    port(
        i_Clk           : in     vl_logic;
        i_Rst           : in     vl_logic;
        i_Push          : in     vl_logic;
        o_fPush         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEBOUNCE_MAX : constant is 1;
end OnePushControl;
