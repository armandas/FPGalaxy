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
        origin_x, origin_y: out std_logic_vector(9 downto 0);
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end alien;

architecture generator of alien is
    -- width of the alien area (8 * 32)
    constant A_WIDTH: integer := 256;
    constant A_HEIGHT: integer := 32;
    -- 3rd level aliens are at the bottom (64px below master coord)
    constant OFFSET: integer := 64;

    constant FRAME_DELAY: integer := 50000000;

    signal output_enable: std_logic;

    -- address is made of row and column adresses
    -- addr <= (row_address & col_address);
    signal addr: std_logic_vector(9 downto 0);
    signal row_address, col_address: std_logic_vector(4 downto 0);

    signal relative_x: std_logic_vector(9 downto 0);
    signal missile_relative_x: std_logic_vector(9 downto 0);
    signal position_in_frame: std_logic_vector(4 downto 0);

    signal attacked_alien: std_logic_vector(2 downto 0);
    signal destruction: std_logic;

    -- condition of aliens: left (0) to right (7)
    signal alive, alive_next: std_logic_vector(0 to 7);
    signal alien_alive: std_logic;

    signal frame, frame_next: std_logic;
    signal frame_counter, frame_counter_next: std_logic_vector(24 downto 0);

    signal alien_rgb, alien11_rgb, alien12_rgb: std_logic_vector(2 downto 0);
    -- which alien is currently being drawn
    -- leftmost = 0, rightmost = 7
    signal alien_number: std_logic_vector(2 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '0' then
            frame <= '0';
            frame_counter <= (others => '0');
            alive <= (others => '1');
        elsif falling_edge(clk) then
            frame <= frame_next;
            frame_counter <= frame_counter_next;
            alive <= alive_next;
        end if;
    end process;

    missile_relative_x <= missile_coord_x - master_coord_x;
    attacked_alien <= missile_relative_x(7 downto 5);
    position_in_frame <= missile_relative_x(4 downto 0);

    process(missile_coord_x, missile_coord_y,
            master_coord_x, master_coord_y,
            alive, position_in_frame, attacked_alien)
    begin
        alive_next <= alive;
        destruction <= '0';

        if missile_coord_y < master_coord_y + OFFSET + A_HEIGHT and
           missile_coord_x > master_coord_x and
           missile_coord_x < master_coord_x + A_WIDTH and
           alive(conv_integer(attacked_alien)) = '1' and
           position_in_frame > 0 and position_in_frame < 29
        then
            destruction <= '1';
            alive_next(conv_integer(attacked_alien)) <= '0';

            -- attacked alien number is multiplied by 32
            origin_x <= master_coord_x + (attacked_alien & "00000");
            origin_y <= master_coord_y + OFFSET;
        end if;
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

    alien_rgb <= alien11_rgb when frame = '0' else
                 alien12_rgb;

    rgb_pixel <= alien_rgb when output_enable = '1' else
                 (others => '0');

    destroyed <= destruction;

    alien_11:
        entity work.alien11_rom(content)
        port map(addr => addr, data => alien11_rgb);

    alien_12:
        entity work.alien12_rom(content)
        port map(addr => addr, data => alien12_rgb);

end generator;