library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alien is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        master_coord_x, master_coord_y: in std_logic_vector(9 downto 0);
        missile_coord_x, missile_coord_y: in std_logic_vector(9 downto 0);
        destroyed: out std_logic;
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end alien;

architecture generator of alien is
    -- width of the alien area (8 * 32)
    constant A_WIDTH: integer := 256;
    constant A_HEIGHT: integer := 32;

    signal output_enable: std_logic;

    -- condition of aliens: left (0) to right (7)
    signal alive: std_logic_vector(0 to 7);

    signal frame: std_logic;
    signal frame_counter, frame_counter_next: std_logic_vector(24 downto 0);

    signal alien1_addr: std_logic_vector(9 downto 0);
    signal alien11_rgb, alien12_rgb: std_logic_vector(0 to 2);
begin

    output_enable <= '1' when (px_x >= master_coord_x and
                               px_x < master_coord_x + A_WIDTH and
                               px_y >= master_coord_y and
                               px_y < master_coord_y + A_HEIGHT) else
                     '0';

    rgb_pixel <= "111" when output_enable = '1' else "000";

    alien_11:
        entity work.alien11_rom(content)
        port map(addr => alien1_addr, data => alien11_rgb);

    alien_12:
        entity work.alien12_rom(content)
        port map(addr => alien1_addr, data => alien12_rgb);

end generator;