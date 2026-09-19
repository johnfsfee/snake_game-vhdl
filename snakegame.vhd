library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity snakegame is
  port(
    de1_clk_50 : in  std_logic;         --clk
    rst        : in  std_logic;         --reset
    ps2_clk    : in  std_logic;         -- clk interno do teclado ps/2
    ps2_data   : in  std_logic;         -- dados enviados em serie pelo teclado
    vga_r      : out std_logic_vector(3 downto 0);  --vetor
    vga_g      : out std_logic_vector(3 downto 0);  -- verde
    vga_b      : out std_logic_vector(3 downto 0);  -- azul
    vga_vs     : out std_logic;         -- sync vertical
    vga_hs     : out std_logic          -- sync horizontal
    );
end snakegame;

architecture structural of snakegame is

  --fios mandam de um componente para o outro
  signal s_ps2_code : std_logic_vector(7 downto 0);
  signal s_ps2_new  : std_logic;
  signal s_snake_x  : integer range 0 to 39;
  signal s_snake_y  : integer range 0 to 29;
  signal s_fruit_x  : integer range 0 to 39;
  signal s_fruit_y  : integer range 0 to 29;

begin

  KBD : entity work.ps2_keyboard
    port map(
      clk          => de1_clk_50,       --in
      ps2_clk      => ps2_clk,          --in
      ps2_data     => ps2_data,         --in
      ps2_code_new => s_ps2_new,        --out
      ps2_code     => s_ps2_code        --out
      );

  BRAIN : entity work.game_controller
    port map(
      clk      => de1_clk_50,           --in
      reset    => rst,                  --in
      ps2_code => s_ps2_code,           --in
      ps2_new  => s_ps2_new,            --in
      snake_x  => s_snake_x,            --out
      snake_y  => s_snake_y,            --out
      fruit_x  => s_fruit_x,            --out
      fruit_y  => s_fruit_y             --out
      );

  DISP : entity work.vga
    port map(
      de1_clk_50 => de1_clk_50,         --in
      snake_x    => s_snake_x,          --in
      snake_y    => s_snake_y,          --in
      fruit_x    => s_fruit_x,          --in
      fruit_y    => s_fruit_y,          --in
      vga_r      => vga_r,              --out
      vga_g      => vga_g,              --out
      vga_b      => vga_b,              --out
      vga_vs     => vga_vs,             --out
      vga_hs     => vga_hs              --out
      );

end architecture;
