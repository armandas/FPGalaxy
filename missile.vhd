library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity missile is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        nes1_a: in std_logic;
        x_position, y_position: in std_logic_vector(9 downto 0);
        destruction: in std_logic;
        missile_coord_x, missile_coord_y: out std_logic_vector(9 downto 0);
        rgb_pixel: out std_logic_vector(0 to 2)
    );
end missile;

architecture behaviour of missile is
    constant WIDTH: integer := 4;
    constant HEIGHT: integer := 4;
    type rom_type is array(0 to HEIGHT - 1) of
         std_logic_vector(WIDTH - 1 downto 0);
    constant MISSILE: rom_type := ("0100", "1110", "1110", "1010");
    constant DELAY: integer := 50000;

    signal counter, counter_next: std_logic_vector(15 downto 0);

    signal row_address, col_address: std_logic_vector(1 downto 0);
    signal data: std_logic_vector(WIDTH - 1 downto 0);

    signal output_enable: std_logic;
    signal missile_ready, missile_ready_next: std_logic;

    signal x_coordinate, x_coordinate_next: std_logic_vector(9 downto 0);
    signal y_coordinate, y_coordinate_next: std_logic_vector(9 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            missile_ready <= '1';
            x_coordinate <= x_position;
            y_coordinate <= y_position;
        elsif falling_edge(clk) then
            counter <= counter_next;
            missile_ready <= missile_ready_next;
            x_coordinate <= x_coordinate_next;
            y_coordinate <= y_coordinate_next;
        end if;
    end process;

    missile_ready_next <= '0' when (nes1_a = '1' and
                                    missile_ready = '1') else
                          '1' when (destruction = '1' or
                                    y_coordinate < 10) else
                           missile_ready;

    output_enable <= '1' when (missile_ready = '0' and
                               px_x >= x_coordinate and 
                               px_x < x_coordinate + WIDTH and
                               px_y >= y_coordinate and
                               px_y < y_coordinate + HEIGHT) else
                     '0';

    row_address <= px_y(1 downto 0) - y_coordinate(1 downto 0);
    col_address <= px_x(1 downto 0) - x_coordinate(1 downto 0);

    data <= MISSILE(conv_integer(row_address));

    rgb_pixel <= "111" when (output_enable = '1' and
                             data(conv_integer(col_address)) = '1') else
                 "000";

    counter_next <= counter + 1 when counter < DELAY else (others => '0');

    x_coordinate_next <= x_position when (missile_ready = '1' and
                                          nes1_a = '1') else
                         x_coordinate when missile_ready = '0' else
                         (others => '0');

    y_coordinate_next <= y_coordinate - 1 when (missile_ready = '0' and
                                                counter = 0) else
                         y_position when missile_ready = '1' else
                         y_coordinate;

end behaviour;