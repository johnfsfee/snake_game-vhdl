library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
  port (
    de1_clk_50       : in  std_logic;
    snake_x, snake_y : in  integer;
    fruit_x, fruit_y : in  integer;
    vga_r            : out std_logic_vector(3 downto 0);
    vga_g            : out std_logic_vector(3 downto 0);
    vga_b            : out std_logic_vector(3 downto 0);
    vga_vs, vga_hs   : out std_logic
    );
end entity;

architecture rtl of vga is
  constant h_active_video : integer := 800;
  constant h_front_porch  : integer := h_active_video + 56;
  constant h_sync         : integer := h_front_porch + 120;
  constant h_back_porch   : integer := h_sync + 64;
  constant h_pixels       : integer := 1040;

  constant v_active_video : integer := 600;
  constant v_front_porch  : integer := v_active_video + 37;
  constant v_sync         : integer := v_front_porch + 6;
  constant v_back_porch   : integer := v_sync + 23;
  constant v_pixels       : integer := 666;

  -- procedimento para incrementar contadores verticais e horizontais
  procedure incrementa(
    signal contador   : inout integer;
    constant max      : in    integer;
    constant habilita : in    boolean;
    variable estouro  : out   boolean) is
  begin
    estouro := false;
    if habilita then
      if contador = max - 1 then
        estouro  := true;
        contador <= 0;
      else
        contador <= contador +1;
      end if;
    end if;
  end procedure;

  --procedimento para imprimir um quadrado na tela
  procedure quadrado(
    constant enable : in    boolean;
    constant h, v   : in    integer;
    constant x, y   : in    integer;
    constant w      : in    integer;
    constant color  : in    std_logic_vector(11 downto 0);
    variable draw   : inout std_logic_vector(11 downto 0)) is
  begin
    --draw_out := draw_in;
    if enable then
      --logica de caixa
      if (v >= y and v < y + w) and (h >= x and h < x + w) then
        draw := color;
      end if;
    end if;
  end procedure;

  --alias (apelidos)
  alias clk : std_logic is de1_clk_50;

  --signals
  signal horizontal : integer range 0 to h_pixels := 0;  --800x600 72hz
  signal vertical   : integer range 0 to v_pixels := 0;  ---800x600 72hz
  signal active     : boolean;
begin

  pixel_proc : process(clk)
    variable controle : boolean;
  begin
    if rising_edge(clk) then
      vga_hs <= '1';
      vga_vs <= '1';
      active <= false;
      if horizontal >= h_front_porch and horizontal < h_sync then
        vga_hs <= '0';
      end if;
      if vertical >= v_front_porch and vertical < v_sync then
        vga_vs <= '0';
      end if;
      if horizontal < h_active_video and vertical <= v_active_video then
        active <= true;
      end if;
      incrementa(horizontal, h_pixels, true, controle);
      incrementa(vertical, v_pixels, controle, controle);
    end if;
  end process;

  process(horizontal, vertical, active, clk)
    variable draw                         : std_logic_vector(11 downto 0);
    --armazenar posicoes convertidas dos pixels
    variable snake_pixel_x, snake_pixel_y : integer;
    variable fruit_pixel_x, fruit_pixel_y : integer;
  begin
    if rising_edge(clk) then
      draw          := (others => '0');
      -- converter grid para pixels
      -- 20 é o comprimentoxaltura
      snake_pixel_x := snake_x * 20;
      snake_pixel_y := snake_y * 20;
      fruit_pixel_x := fruit_x * 20;
      fruit_pixel_y := fruit_y * 20;
      -- desenhar cobra
      quadrado(active, horizontal, vertical,
               snake_pixel_x, snake_pixel_y,
               20, x"0F0", draw);       -- cobra verde
      --desenhar fruta
      quadrado(active, horizontal, vertical,
               fruit_pixel_x, fruit_pixel_y,
               20, x"F00", draw);       -- fruta vermelha

      vga_r <= draw(11 downto 8);       --red
      vga_g <= draw(7 downto 4);        --green
      vga_b <= draw(3 downto 0);        --blue
    end if;
  end process;
end architecture;
