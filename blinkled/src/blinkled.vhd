-- Copyright 2020 Augusto Fraga Giachero <afg@augustofg.net>
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinkled is
  generic (clk_div: integer := 5_999_999);
  port (
    clk: in std_logic;
    led0, led1, led2, led3, led4, led5, led6, led7: out std_logic
    );
end blinkled;

architecture leds_arch of blinkled is
  signal clk_2hz: std_logic := '0';
  signal leds_out: std_ulogic_vector (0 to 7) := "00000000";
begin
  (led0, led1, led2, led3, led4, led5, led6, led7) <= leds_out;

  process(clk)
    variable counter: unsigned (0 to 23) := x"000000";
  begin
    if rising_edge(clk) then
      if counter = clk_div then
        counter := x"000000";
        clk_2hz <= '1';
      else
        counter := counter + 1;
        clk_2hz <= '0';
      end if;
    end if;
  end process;

  process(clk_2hz)
  begin
    if rising_edge(clk_2hz) then
      leds_out <= not leds_out;
    end if;
  end process;
end leds_arch;
