library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity graphics is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        video_on: in std_logic;
        nes_a, nes_b, nes_left, nes_right: in std_logic;
        rgb_stream: out std_logic_vector(2 downto 0);
        shooting_sound, destruction_sound: out std_logic
    );
end graphics;

architecture dispatcher of graphics is
    constant A_WIDTH: integer := 256;
    constant DELAY: integer := 25000000;

    type states is (left, right);
    signal state, state_next: states;
    type states_v is (up, down);
    signal state_v, state_v_next: states_v;

    -- alien movement counter
    signal counter, counter_next: std_logic_vector(24 downto 0);

    signal master_coord_x, master_coord_x_next,
           master_coord_y, master_coord_y_next: std_logic_vector(9 downto 0);

    signal missile_coord_x, missile_coord_y: std_logic_vector(9 downto 0);

    -- x-coordinate of the spaceship
    signal spaceship_x, spaceship_y: std_logic_vector(9 downto 0);

    -- origin for explosion animation
    signal origin_x, origin_x_next: std_logic_vector(9 downto 0);
    signal origin_y, origin_y_next: std_logic_vector(9 downto 0);

    -- alien-level-specific origins
    signal origin1_x, origin1_y,
           origin2_x, origin2_y,
           origin3_x, origin3_y: std_logic_vector(9 downto 0);

    signal alien1_rgb, alien2_rgb, alien3_rgb: std_logic_vector(2 downto 0);
    signal spaceship_rgb: std_logic_vector(2 downto 0);
    signal missile_rgb: std_logic_vector(2 downto 0);
    signal explosion_rgb: std_logic_vector(2 downto 0);

    signal destruction: std_logic;
    signal destroyed1, destroyed2, destroyed3: std_logic;
    signal defeated1, defeated2, defeated3: std_logic;

    signal level, level_next: positive range 1 to 32;
begin

    process(clk, reset)
    begin
        if reset = '0' then
            master_coord_x <= conv_std_logic_vector(192, 10);
            master_coord_y <= conv_std_logic_vector(34, 10);
            origin_x <= (others => '0');
            origin_y <= (others => '0');
            level <= 1;
            state <= right;
            state_v <= up;
            counter <= (others => '0');
        elsif falling_edge(clk) then
            master_coord_x <= master_coord_x_next;
            master_coord_y <= master_coord_y_next;
            origin_x <= origin_x_next;
            origin_y <= origin_y_next;
            level <= level_next;
            state <= state_next;
            state_v <= state_v_next;
            counter <= counter_next;
        end if;
    end process;

    counter_next <= counter + 1 when counter < DELAY else (others => '0');

    level_next <= level + 1 when defeated1 = '1' and
                                 defeated2 = '1' and
                                 defeated3 = '1' else
                  level;

    process(state, state_v, state_next,
            master_coord_x, master_coord_y,
            counter)
    begin
        state_next <= state;
        state_v_next <= state_v;
        master_coord_x_next <= master_coord_x;
        master_coord_y_next <= master_coord_y;
        
        if counter = 0 then
            case state_v is
                when up =>
                    state_v_next <= down;
                    master_coord_y_next <= master_coord_y - 4;
                when down =>
                    state_v_next <= up;
                    master_coord_y_next <= master_coord_y + 4;
            end case;

            case state is
                when right =>
                    if master_coord_x + A_WIDTH = 640 then
                        state_next <= left;
                    else
                        master_coord_x_next <= master_coord_x + 16;
                    end if;
                when left =>
                    if master_coord_x = 0 then
                        state_next <= right;
                    else
                        master_coord_x_next <= master_coord_x - 16;
                    end if;
            end case;
        end if;
    end process;

    process(video_on,
            alien1_rgb, alien2_rgb, alien3_rgb,
            spaceship_rgb,
            missile_rgb, explosion_rgb)
    begin
        if video_on = '1' then
            rgb_stream <= "000" or
                          alien1_rgb or
                          alien2_rgb or
                          alien3_rgb or
                          spaceship_rgb or
                          missile_rgb or
                          explosion_rgb;
        else
            rgb_stream <= (others => '0');
        end if;
    end process;

    destruction <= destroyed1 or destroyed2 or destroyed3;
    destruction_sound <= destruction;

    origin_x_next <= origin1_x when destroyed1 = '1' else
                     origin2_x when destroyed2 = '1' else
                     origin3_x when destroyed3 = '1' else
                     origin_x;

    origin_y_next <= origin1_y when destroyed1 = '1' else
                     origin2_y when destroyed2 = '1' else
                     origin3_y when destroyed3 = '1' else
                     origin_y;

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
            defeated => defeated1,
            explosion_x => origin1_x, explosion_y => origin1_y,
            rgb_pixel => alien1_rgb
        );

    alien2:
        entity work.alien2(generator)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            master_coord_x => master_coord_x,
            master_coord_y => master_coord_y,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            destroyed => destroyed2,
            defeated => defeated2,
            explosion_x => origin2_x, explosion_y => origin2_y,
            rgb_pixel => alien2_rgb
        );

    alien3:
        entity work.alien3(generator)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            master_coord_x => master_coord_x,
            master_coord_y => master_coord_y,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            destroyed => destroyed3,
            defeated => defeated3,
            explosion_x => origin3_x, explosion_y => origin3_y,
            rgb_pixel => alien3_rgb
        );
    spaceship:
        entity work.spaceship(behaviour)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            nes_left => nes_left, nes_right => nes_right,
            spaceship_x => spaceship_x,
            spaceship_y => spaceship_y,
            rgb_pixel => spaceship_rgb
        );

    missile:
        entity work.missile(behaviour)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            nes_a => nes_a, nes_b => nes_b,
            x_position => spaceship_x,
            y_position => spaceship_y,
            destruction => destruction,
            missile_coord_x => missile_coord_x,
            missile_coord_y => missile_coord_y,
            shooting => shooting_sound,
            rgb_pixel => missile_rgb
        );

    explosion:
        entity work.explosion(behaviour)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            destruction => destruction,
            origin_x => origin_x, origin_y => origin_y,
            rgb_pixel => explosion_rgb
        );
end dispatcher;

