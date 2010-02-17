library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity level_info is
    port(
        clk, not_reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        level: in std_logic_vector(8 downto 0);
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end level_info;

architecture display of level_info is
    constant WIDTH: integer := 48;
    constant HEIGHT: integer := 8;

    signal font_addr: std_logic_vector(8 downto 0);
    signal font_data: std_logic_vector(0 to 7);
    signal font_pixel: std_logic;

    signal text_font_addr: std_logic_vector(8 downto 0);
    signal number_font_addr: std_logic_vector(8 downto 0);

    signal text_enable: std_logic;
    signal number_enable: std_logic;

    signal bcd: std_logic_vector(3 downto 0);
    signal bcd0, bcd1, bcd2: std_logic_vector(3 downto 0);
begin

    text_enable <= '1' when (px_x >= 0 and
                             px_x < WIDTH and
                             px_y >= 0 and
                             px_y < HEIGHT) else
                   '0';

    -- +16 and +40 used to right-align the level with score
    number_enable <= '1' when (px_x >= WIDTH + 16 and
                               px_x < WIDTH + 40 and
                               px_y >= 0 and
                               px_y < HEIGHT) else
                     '0';

    with px_x(9 downto 3) select
        text_font_addr <= "101100000" when "0000000", -- L
                          "100101000" when "0000001", -- E
                          "110110000" when "0000010", -- V
                          "100101000" when "0000011", -- E
                          "101100000" when "0000100", -- L
                          "000000000" when others;    -- space

    bcd <= bcd0 when px_x(9 downto 3) = 10 else
           bcd1 when px_x(9 downto 3) = 9 else
           bcd2 when px_x(9 downto 3) = 8 else
           (others => '0');

    -- numbers start at memory location 128
    -- '1' starts at 136, '2' at 144 and so on
    -- bcd is multiplied by 8 to get the right digit
    number_font_addr <= conv_std_logic_vector(128, 9) + (bcd & "000");

    font_addr <= px_y(2 downto 0) + text_font_addr when text_enable = '1' else
                 px_y(2 downto 0) + number_font_addr when number_enable = '1' else
                 (others => '0');

    font_pixel <= font_data(conv_integer(px_x(2 downto 0)));
    rgb_pixel <= "111" when font_pixel = '1' else "000";

    bin_to_bcd:
        entity work.bin2bcd(behaviour)
        generic map(N_BIN => 9)
        port map(
            clk => clk, not_reset => not_reset,
            binary_in => level,
            bcd0 => bcd0, bcd1 => bcd1, bcd2 => bcd2,
            bcd3 => open, bcd4 => open
        );

    codepage:
        entity work.codepage_rom(content)
        port map(addr => font_addr, data => font_data);

end display;

