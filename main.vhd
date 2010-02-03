library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity main is
    port(
        clk, reset: in std_logic;
        hsync, vsync: out std_logic;
        rgb: out std_logic_vector(2 downto 0);
        --buzzer: out std_logic
        data_1, data_2: in std_logic;
        clk_out: out std_logic;
        ps_control: out std_logic
    );
end main;

architecture behavior of main is
    signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
    signal video_on: std_logic;
    signal px_x, px_y: std_logic_vector(9 downto 0);

    signal shot, destroyed: std_logic;

    signal nes1_a, nes1_b,
           nes1_select, nes1_start,
           nes1_up, nes1_down,
           nes1_left, nes1_right: std_logic;

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
            nes1_a => nes1_a, nes1_b => nes1_b,
            nes1_left => nes1_left, nes1_right => nes1_right,
            rgb_stream => rgb_next,
            shooting_sound => shot, destruction_sound => destroyed
        );

    NES_controllers:
        entity work.controller(arch)
        port map(
            clk => clk, reset => reset,
            data_1 => data_1, data_2 => data_2,
            clk_out => clk_out,
            ps_control => ps_control,
            gamepad1(0) => nes1_a,      gamepad1(1) => nes1_b,
            gamepad1(2) => nes1_select, gamepad1(3) => nes1_start,
            gamepad1(4) => nes1_up,     gamepad1(5) => nes1_down,
            gamepad1(6) => nes1_left,   gamepad1(7) => nes1_right,
            gamepad2 => open
        );

    rgb <= rgb_reg;

end behavior;

