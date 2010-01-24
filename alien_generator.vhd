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
    -- state of aliens left (0) to right (7)
    signal alive: std_logic_vector(0 to 7);
begin


    alien_11:
        entity work.alien11_rom(content)
        port map(addr => alien1_addr, data => alien11_rgb);

    alien_12:
        entity work.alien12_rom(content)
        port map(addr => alien1_addr, data => alien12_rgb);

end generator;