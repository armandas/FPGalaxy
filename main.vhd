library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity main is
    port(
        clk, reset: in std_logic;
        hsync, vsync: out std_logic;
        rgb: out std_logic_vector(2 downto 0)
        --buzzer: out std_logic
    );
end main;

architecture behavior of main is
    signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
    signal video_on: std_logic;
    signal px_x, px_y: std_logic_vector(9 downto 0);

    signal shot, destroyed: std_logic;
begin
    process(clk)
    begin
        if falling_edge(clk) then
            rgb_reg <= rgb_next;
        end if;
    end process;

    vga:
        entity work.vga(sync)
        port map(
            clk => clk, reset => reset,
            hsync => hsync, vsync => vsync,
            video_on => video_on, p_tick => open,
            pixel_x => px_x, pixel_y => px_y
        );

    graphics:
        entity work.graphics(dispatcher)
        port map(
            clk => clk, reset => reset,
            px_x => px_x, px_y => px_y,
            video_on => video_on,
            rgb_stream => rgb_next,
            shot => shot, destroyed => destroyed
        );

    rgb <= rgb_reg;

end behavior;

