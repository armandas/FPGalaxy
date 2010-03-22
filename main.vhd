library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fpgalaxy is
    port(
        clk, not_reset: in std_logic;
        hsync, vsync: out std_logic;
        nes_data: in std_logic;
        rgb: out std_logic_vector(2 downto 0);
        buzzer: out std_logic;
        nes_clk_out: out std_logic;
        nes_ps_control: out std_logic
    );
end fpgalaxy;

architecture behaviour of fpgalaxy is
    signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
    signal video_on: std_logic;
    signal px_x, px_y: std_logic_vector(9 downto 0);

    signal shot, destroyed: std_logic;

    signal nes_a, nes_b,
           nes_select, nes_start,
           nes_up, nes_down,
           nes_left, nes_right: std_logic;

    signal buzzer1, buzzer2: std_logic;
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
            clk => clk, not_reset => not_reset,
            hsync => hsync, vsync => vsync,
            video_on => video_on, p_tick => open,
            pixel_x => px_x, pixel_y => px_y
        );

    graphics:
        entity work.fpgalaxy_graphics(dispatcher)
        port map(
            clk => clk, not_reset => not_reset,
            px_x => px_x, px_y => px_y,
            video_on => video_on,
            nes_a => nes_a, nes_b => nes_b,
            nes_left => nes_left, nes_right => nes_right,
            rgb_stream => rgb_next,
            shooting_sound => shot, destruction_sound => destroyed
        );

    sound1:
        entity work.player(behaviour)
        port map(
            clk => clk, not_reset => not_reset,
            shooting_sound => shot, explosion_sound => '0',
            buzzer => buzzer1
        );
    buzzer <= buzzer1 or buzzer2;
    sound2:
        entity work.player(behaviour)
        port map(
            clk => clk, not_reset => not_reset,
            shooting_sound => '0', explosion_sound => destroyed,
            buzzer => buzzer2
        );

    NES_controller:
        entity work.controller(arch)
        port map(
            clk => clk, not_reset => not_reset,
            data_in => nes_data,
            clk_out => nes_clk_out,
            ps_control => nes_ps_control,
            gamepad(0) => nes_a,      gamepad(1) => nes_b,
            gamepad(2) => nes_select, gamepad(3) => nes_start,
            gamepad(4) => nes_up,     gamepad(5) => nes_down,
            gamepad(6) => nes_left,   gamepad(7) => nes_right
        );

    rgb <= rgb_reg;

end behaviour;

