library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alien2 is
    port(
        clk, not_reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        master_coord_x, master_coord_y: in std_logic_vector(9 downto 0);
        missile_coord_x, missile_coord_y: in std_logic_vector(9 downto 0);
        restart: in std_logic;
        destroyed: out std_logic;
        defeated: out std_logic;
        explosion_x, explosion_y: out std_logic_vector(9 downto 0);
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end alien2;

architecture generator of alien2 is
    type states is (act, wait_clk);
    signal state, state_next: states;

    -- width of the alien area (8 * 32)
    constant A_WIDTH: integer := 256;
    constant A_HEIGHT: integer := 32;
    -- 3rd level aliens are at the bottom (64px below master coord)
    constant OFFSET: integer := 32;

    constant FRAME_DELAY: integer := 5000000;

    signal output_enable: std_logic;

    -- address is made of row and column adresses
    -- addr <= (row_address & col_address);
    signal addr: std_logic_vector(9 downto 0);
    signal row_address, col_address: std_logic_vector(4 downto 0);

    signal origin_x, origin_x_next,
           origin_y, origin_y_next: std_logic_vector(9 downto 0);

    signal relative_x: std_logic_vector(9 downto 0);
    signal missile_relative_x: std_logic_vector(9 downto 0);
    signal position_in_frame: std_logic_vector(4 downto 0);

    -- whether missile is in alien zone
    signal missile_arrived: std_logic;

    signal attacked_alien: std_logic_vector(2 downto 0);
    signal destruction: std_logic;

    -- condition of aliens: left (0) to right (7)
    signal alive, alive_next: std_logic_vector(0 to 7);
    signal alien_alive: std_logic;
    -- second level aliens need two hits to get killed
    signal injured, injured_next: std_logic_vector(0 to 7);

    signal frame, frame_next: std_logic;
    signal frame_counter, frame_counter_next: std_logic_vector(22 downto 0);

    signal alien_rgb, alien21_rgb, alien22_rgb: std_logic_vector(2 downto 0);
    -- which alien is currently being drawn
    -- leftmost = 0, rightmost = 7
    signal alien_number: std_logic_vector(2 downto 0);
begin

    process(clk, not_reset)
    begin
        if not_reset = '0' then
            frame <= '0';
            frame_counter <= (others => '0');
            alive <= (others => '1');
            injured <= (others => '0');
            state <= act;
        elsif falling_edge(clk) then
            frame <= frame_next;
            frame_counter <= frame_counter_next;
            alive <= alive_next;
            injured <= injured_next;
            state <= state_next;
        end if;
    end process;

    missile_arrived <= '1' when missile_coord_y < master_coord_y + OFFSET + A_HEIGHT and
                                missile_coord_x > master_coord_x and
                                missile_coord_x < master_coord_x + A_WIDTH else
                       '0';

    missile_relative_x <= (missile_coord_x - master_coord_x) when missile_arrived = '1' else
                          (others => '0');
    attacked_alien <= missile_relative_x(7 downto 5) when missile_arrived = '1' else
                      (others => '0');
    position_in_frame <= missile_relative_x(4 downto 0) when missile_arrived = '1' else
                         (others => '0');

    process(missile_coord_x, master_coord_x,
            missile_arrived, position_in_frame,
            alive, injured, state, restart)
    begin
        state_next <= state;
        destruction <= '0';
        alive_next <= alive;
        injured_next <= injured;

        case state is
            when act =>
                if restart = '1' then
                    alive_next <= (others => '1');
                    injured_next <= (others => '0');
                elsif missile_arrived = '1' and
                   alive(conv_integer(attacked_alien)) = '1' and
                   position_in_frame > 0 and
                   position_in_frame < 29
                then
                    if injured(conv_integer(attacked_alien)) = '0' then
                        state_next <= wait_clk;
                        destruction <= '1';
                        injured_next(conv_integer(attacked_alien)) <= '1';
                    else
                        state_next <= wait_clk;
                        destruction <= '1';
                        alive_next(conv_integer(attacked_alien)) <= '0';
                    end if;
                end if;
            when wait_clk =>
                state_next <= act;
        end case;
     end process;

    relative_x <= px_x - master_coord_x;
    alien_number <= relative_x(7 downto 5);
    alien_alive <= alive(conv_integer(alien_number));

    frame_counter_next <= frame_counter + 1 when frame_counter < FRAME_DELAY else
                          (others => '0');

    frame_next <= (not frame) when frame_counter = 0 else frame;

    output_enable <= '1' when (alien_alive = '1' and 
                               px_x >= master_coord_x and
                               px_x < master_coord_x + A_WIDTH and
                               px_y >= master_coord_y + OFFSET and
                               px_y < master_coord_y + OFFSET + A_HEIGHT) else
                     '0';

    row_address <= px_y(4 downto 0) - master_coord_y(4 downto 0);
    col_address <= px_x(4 downto 0) - master_coord_x(4 downto 0);
    addr <= row_address & col_address;

    alien_rgb <= alien21_rgb when frame = '0' else
                 alien22_rgb;

    rgb_pixel <= alien_rgb when output_enable = '1' else
                 (others => '0');

    destroyed <= destruction;

    -- attacked alien number is multiplied by 32
    origin_x <= master_coord_x + (attacked_alien & "00000");
    origin_y <= master_coord_y + OFFSET;

    explosion_x <= origin_x;
    explosion_y <= origin_y;

    defeated <= '1' when alive = 0 else '0';

    alien_21:
        entity work.alien21_rom(content)
        port map(addr => addr, data => alien21_rgb);

    alien_22:
        entity work.alien22_rom(content)
        port map(addr => addr, data => alien22_rgb);

end generator;