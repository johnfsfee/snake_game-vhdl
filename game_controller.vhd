library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_controller is
  port (
    clk      : in  std_logic;              -- 50MHz
    reset    : in  std_logic;
    ps2_code : in  std_logic_vector(7 downto 0);
    ps2_new  : in  std_logic;
    snake_x  : out integer range 0 to 39;  -- grid x (0-39)
    snake_y  : out integer range 0 to 29;  -- grid y (0-29)
    fruit_x  : out integer range 0 to 39;
    fruit_y  : out integer range 0 to 29
    );
end entity;

architecture rtl of game_controller is
  signal timer        : integer               := 0;
  signal game_tick    : std_logic             := '0';
  signal curr_x       : integer range 0 to 39 := 20;
  signal curr_y       : integer range 0 to 29 := 15;
  type direction is (UP, DOWN, left, right);
  signal curr_dir     : direction             := right;
  signal curr_fruit_x : integer range 0 to 39 := 10;  -- fruta inicial X
  signal curr_fruit_y : integer range 0 to 29 := 10;  -- fruta inicial Y
  -- Declarar sinal de contador
  signal fruit_timer  : unsigned(15 downto 0) := (others => '0');
begin
  -- velocidade do jogo: Dividir 50MHz ate ~10Hz (5,000,000 cyclos)
  process(clk)
  begin
    if rising_edge(clk) then
      fruit_timer <= fruit_timer + 1;                 -- giro infinito
      if timer = 5000000 then
        timer     <= 0;
        game_tick <= '1';
      else
        timer     <= timer + 1;
        game_tick <= '0';
      end if;
    end if;
  end process;

  -- logica direcional (mapping dos códigos de scan ps/2)
  process(clk)
  begin
    if rising_edge(clk) then
      if ps2_new = '1' then
        case ps2_code is
          when x"1D"  => curr_dir <= UP;     -- W
          when x"1B"  => curr_dir <= DOWN;   -- S
          when x"1C"  => curr_dir <= left;   -- A
          when x"23"  => curr_dir <= right;  -- D
          when others => null;
        end case;
      end if;
    end if;
  end process;

  -- logica movimento
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        curr_x       <= 20; curr_y <= 15;
        curr_fruit_x <= 10;             -- resetar posicao da fruta
        curr_fruit_y <= 10;
      elsif game_tick = '1' then
        case curr_dir is
          --   when UP =>
          --     if curr_y > 0 then curr_y <= curr_y - 1; end if;
          --   when DOWN =>
          --     if curr_y < 29 then curr_y <= curr_y + 1; end if;
          --   when left =>
          --     if curr_x > 0 then curr_x <= curr_x - 1; end if;
          --   when right =>
          --     if curr_x < 39 then curr_x <= curr_x + 1; end if;
          when UP =>
            if curr_y = 0 then curr_y <= 29; else curr_y <= curr_y - 1; end if;
          when DOWN =>
            if curr_y = 29 then curr_y <= 0; else curr_y <= curr_y + 1; end if;
          when left =>
            if curr_x = 0 then curr_x <= 39; else curr_x <= curr_x - 1; end if;
          when right =>
            if curr_x = 39 then curr_x <= 0; else curr_x <= curr_x + 1; end if;
        end case;
        -- logica comer: checa se cabeca esta na fruta
        if (curr_x = curr_fruit_x) and (curr_y = curr_fruit_y) then
          -- usar timer com alta velocidade para novas posicoes "random"
          curr_fruit_x <= to_integer(fruit_timer(5 downto 0)) mod 40;
          curr_fruit_y <= to_integer(fruit_timer(11 downto 6)) mod 30;
        end if;
      end if;
    end if;
  end process;

  snake_x <= curr_x;
  snake_y <= curr_y;
  fruit_x <= curr_fruit_x;
  fruit_y <= curr_fruit_y;
end architecture;
