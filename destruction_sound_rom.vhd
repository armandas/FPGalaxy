library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity explosion_sound is
    generic(
        ADDR_WIDTH: integer := 5
    );
    port(
        addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        data: out std_logic_vector(8 downto 0)
    );
end explosion_sound;

architecture content of explosion_sound is
    type tune is array(0 to 2 ** ADDR_WIDTH - 1)
        of std_logic_vector(8 downto 0);
    constant TEST: tune :=
    (
        "001001001",
        "010001001",
        "001001001",
        "010001001",
        "001001010",
        "010001010",
        "001001010",
        "010001010",
        "001001011",
        "010001011",
        "001001011",
        "010001011",
        "001001100",
        "010001100",
        "001001100",
        "010001100",
        "001001101",
        "010001101",
        "001001101",
        "010001101",
        "001001110",
        "010001110",
        "001001110",
        "010001110",
        "001001111",
        "010001111",
        "001001111",
        "010001111",
        "001001111",
        "000000000",
        "000000000",
        "000000000"
    );
begin
    data <= TEST(conv_integer(addr));
end content;

