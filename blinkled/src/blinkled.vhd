library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinkled is
  port (
    clk: in std_logic;
    led0, led1, led2, led3, led4, led5, led6, led7: out std_logic
    );
end blinkled;

architecture leds_arch of blinkled is
  signal clk_2hz: std_logic;
  signal leds_out: std_ulogic_vector (0 to 7) := "00000000";
begin
  (led0, led1, led2, led3, led4, led5, led6, led7) <= leds_out;

  process(clk)
    variable counter: unsigned (0 to 23);
  begin
    if rising_edge(clk) then
      if counter = 5_999_999 then
        counter := x"000000";
        clk_2hz <= '1';
      else
        counter := counter + 1;
        clk_2hz <= '0';
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk_2hz) then
      leds_out <= not leds_out;
    end if;
  end process;
end leds_arch;
