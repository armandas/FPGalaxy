library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity explosion is
    port(
        clk, reset: in std_logic;
        px_x, px_y: in std_logic_vector(9 downto 0);
        destruction: in std_logic;
        origin_x, origin_y: std_logic_vector(9 downto 0);
        rgb_pixel: out std_logic_vector(2 downto 0)
    );
end explosion;

architecture behaviour of explosion is
    -- frame size (32x32 px)
    constant SIZE: integer := 32;

    -- colour masks
    constant RED: std_logic_vector := "100";
    constant YELLOW: std_logic_vector := "110";

    -- for delay of 100ms
    constant DELAY: integer := 2000000;
    signal counter, counter_next: std_logic_vector(20 downto 0);

    type states is (idle, state1, state2, state3);
    signal state, state_next: states;

    signal output_enable: std_logic;

    -- address is made of row and column adresses
    -- addr <= (row_address & col_address);
    signal addr: std_logic_vector(9 downto 0);
    signal row_address, col_address: std_logic_vector(4 downto 0);

    signal explosion_rgb, explosion_mask: std_logic_vector(2 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '0' then
            state <= idle;
            counter <= (others => '0');
        elsif falling_edge(clk) then
            state <= state_next;
            counter <= counter_next;
        end if;
    end process;

    animation: process(state, counter, destruction)
    begin
        state_next <= state;
        counter_next <= counter;

        case state is
            when idle =>
                counter_next <= (others => '0');
                if destruction = '1' then
                    state_next <= state1;
                end if;
            when state1 =>
                if counter = DELAY - 1 then
                    counter_next <= (others => '0');
                    state_next <= state2;
                else
                    counter_next <= counter + 1;
                end if;
            when state2 =>
                if counter = DELAY - 1 then
                    counter_next <= (others => '0');
                    state_next <= state3;
                else
                    counter_next <= counter + 1;
                end if;
            when state3 =>
                if counter = DELAY - 1 then
                    counter_next <= (others => '0');
                    state_next <= idle;
                else
                    counter_next <= counter + 1;
                end if;
        end case;
    end process;

    output_enable <= '1' when (state /= idle and 
                               px_x >= origin_x and
                               px_x < origin_x + SIZE and
                               px_y >= origin_y and
                               px_y < origin_y + SIZE) else
                     '0';

    explosion_mask <= explosion_rgb when state = state1 and
                                         -- only allow reg through
                                         explosion_rgb(1) = '0' else
                      explosion_rgb when state = state2 and
                                         -- allow red and yellow through
                                         explosion_rgb(0) = '0' else
                                         -- allow all colours through
                      explosion_rgb when state = state3 else
                      (others => '0');

    rgb_pixel <= explosion_mask when output_enable = '1' else (others => '0');

    row_address <= px_y(4 downto 0) - origin_y(4 downto 0);
    col_address <= px_x(4 downto 0) - origin_x(4 downto 0);
    addr <= row_address & col_address;

    explosion:
        entity work.explosion_rom(content)
        port map(addr => addr, data => explosion_rgb);

end behaviour;