library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity graphics is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        video_on: in std_logic;
        rgb_stream: out std_logic_vector(0 to 2);
        shot, destroyed: out std_logic
    );
end graphics;

architecture dispatcher of graphics is
    signal master_coord_x, master_coord_y: std_logic_vector(9 downto 0);

    signal missile_enabled: std_logic;
    signal missile_coord_x, missile_coord_y: std_logic_vector(9 downto 0);

    signal alien1_rgb: std_logic_vector(0 to 2);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            master_coord_x <= conv_std_logic_vector(192, 10);
            master_coord_y <= conv_std_logic_vector(32, 10);
            missile_coord_x <= (others => '0');
            missile_coord_y <= (others => '0');
            missile_enabled <= '0';
        --elsif falling_edge(clk) then
        end if;
    end process;

    process(video_on, alien1_rgb)
    begin
        if video_on = '1' then
            rgb_stream <= "000" or
                          alien1_rgb;
        else
            rgb_stream <= (others => '0');
        end if;
    end process;

    alien1:
        entity work.alien(generator)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            master_coord_x => master_coord_x,
            master_coord_y => master_coord_y,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            destroyed => destroyed,
            rgb_pixel => alien1_rgb
        );
end dispatcher;

