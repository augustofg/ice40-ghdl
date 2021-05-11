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

entity blinkled_tb is
  port (
    led0, led1, led2, led3, led4, led5, led6, led7: out std_logic
    );
end blinkled_tb;

architecture blinkled_tb_arch of blinkled_tb is
  signal clk: std_logic := '0';
begin
  blinkled_inst: entity work.blinkled
    -- Divide input clock by 6_000 instead of 6_000_000 to reduce
    -- simulation costs
    generic map(5999)
    port map(
      clk_i => clk,
      led0_o => led0,
      led1_o => led1,
      led2_o => led2,
      led3_o => led3,
      led4_o => led4,
      led5_o => led5,
      led6_o => led6,
      led7_o => led7
      );

  process
  begin
    -- 12KHz clock
    for i in 0 to 24_000 loop
      clk <= '1';
      wait for 41666 ns;
      clk <= '0';
      wait for 41666 ns;
    end loop;
    std.env.finish;
  end process;

end blinkled_tb_arch;
