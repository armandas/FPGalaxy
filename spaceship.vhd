library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity spaceship is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        nes1_left, nes1_right: std_logic;
        spaceship_x, spaceship_y: out std_logic_vector(9 downto 0);
        destroyed: out std_logic;
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end spaceship;

architecture behaviour of spaceship is
    -- how far down the spaceship will be
    constant OFFSET: integer := 416;
    -- size of the spaceship frame (32x32)
    constant SIZE: integer := 32;

    -- address is made of row and column adresses
    -- addr <= (row_address & col_address);
    signal addr: std_logic_vector(9 downto 0);
    signal row_address, col_address: std_logic_vector(4 downto 0);

    signal output_enable: std_logic;

    signal spaceship_rgb: std_logic_vector(2 downto 0);

    -- x-coordinate of the spaceship
    signal position, position_next: std_logic_vector(9 downto 0);
begin
    process(clk, reset, position_next)
    begin
        if reset = '0' then
            position <= conv_std_logic_vector(305, 10);
        elsif falling_edge(clk) then
            position <= position_next;
        end if;
    end process;

    position_next <= position + 1 when (nes1_right = '1') else
                     position - 1 when (nes1_left = '1') else
                     position;

    row_address <= px_y(4 downto 0) - OFFSET;
    col_address <= px_x(4 downto 0) - position(4 downto 0);
    addr <= row_address & col_address;

    output_enable <= '1' when (px_x >= position and
                               px_x < position + SIZE and
                               px_y >= OFFSET and
                               px_y < OFFSET + SIZE) else
                     '0';

    rgb_pixel <= spaceship_rgb when output_enable = '1' else
                 (others => '0');

    -- +13 gives the center coordinate
    -- this is used in missile.vhd
    spaceship_x <= position + 13;
    spaceship_y <= conv_std_logic_vector(OFFSET, 10);

    spaceship_rom:
        entity work.spaceship_rom(content)
        port map(addr => addr, data => spaceship_rgb);

end behaviour;

