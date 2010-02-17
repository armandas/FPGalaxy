library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shooting_sound is
    generic(
        ADDR_WIDTH: integer := 5
    );
    port(
        addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data: out std_logic_vector(8 downto 0)
    );
end shooting_sound;

architecture content of shooting_sound is
    type tune is array(0 to 2 ** ADDR_WIDTH - 1)
        of std_logic_vector(8 downto 0);
    constant TEST: tune :=
    (
        "100001001",
        "011001011",
        "001001010",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000",
        "000000000"
);
begin
    data <= TEST(conv_integer(addr));
end content;

