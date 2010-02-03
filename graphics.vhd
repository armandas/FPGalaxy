library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity graphics is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        video_on: in std_logic;
        nes1_a, nes1_b, nes1_left, nes1_right: in std_logic;
        rgb_stream: out std_logic_vector(2 downto 0);
        shooting_sound, destruction_sound: out std_logic
    );
end graphics;

architecture dispatcher of graphics is
    signal master_coord_x, master_coord_y: std_logic_vector(9 downto 0);

    signal missile_coord_x, missile_coord_y: std_logic_vector(9 downto 0);

    -- x-coordinate of the spaceship
    signal spaceship_x, spaceship_y: std_logic_vector(9 downto 0);

    signal alien1_rgb: std_logic_vector(2 downto 0);
    signal spaceship_rgb: std_logic_vector(2 downto 0);
    signal missile_rgb: std_logic_vector(2 downto 0);

    signal destruction: std_logic;
    signal destroyed1, destroyed2, destroyed3: std_logic;
    signal colision: std_logic;
begin

    process(clk, reset)
    begin
        if reset = '0' then
            master_coord_x <= conv_std_logic_vector(192, 10);
            master_coord_y <= conv_std_logic_vector(32, 10);
        --elsif falling_edge(clk) then
        end if;
    end process;

    process(video_on, alien1_rgb, spaceship_rgb, missile_rgb)
    begin
        if video_on = '1' then
            rgb_stream <= "000" or
                          alien1_rgb or
                          spaceship_rgb or
                          missile_rgb;
        else
            rgb_stream <= (others => '0');
        end if;
    end process;

    destruction <= destroyed1 or destroyed2 or destroyed3 or colision;
    destruction_sound <= destruction;

    alien1:
        entity work.alien(generator)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            master_coord_x => master_coord_x,
            master_coord_y => master_coord_y,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            destroyed => destroyed1,
            rgb_pixel => alien1_rgb
        );

    spaceship:
        entity work.spaceship(behaviour)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            nes1_left => nes1_left, nes1_right => nes1_right,
            spaceship_x => spaceship_x,
            spaceship_y => spaceship_y,
            destroyed => colision,
            rgb_pixel => spaceship_rgb
        );

    missile:
        entity work.missile(behaviour)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            nes1_a => nes1_a, nes1_b => nes1_b,
            x_position => spaceship_x,
            y_position => spaceship_y,
            destruction => destruction,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            rgb_pixel => missile_rgb
        );
end dispatcher;

