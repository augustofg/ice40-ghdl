-- Copyright 2021 Augusto Fraga Giachero <afg@augustofg.net>
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

entity uart_tb is
  port (
    tx_o: out std_logic;
    tx_ready_o: out std_logic;
    rx_data_o: out std_logic_vector (7 downto 0);
    rx_full_o: out std_logic
    );
end uart_tb;

architecture uart_tb_arch of uart_tb is
  signal clk: std_logic := '0';
  signal tx_start: std_logic := '0';
begin
  uart_inst: entity work.uart
    port map (
      rst_n_i => '1',
      clk_i => clk,
      clk_div_i => x"04E1",
      tx_data_i => x"41",
      tx_start_i => tx_start,
      tx_ready_o => tx_ready_o,
      tx_o => tx_o,
      rx_data_o => rx_data_o,
      rx_read_i => '0',
      rx_full_o => rx_full_o,
      rx_i => tx_o
      );

  process
  begin
    wait for 1 us;
    tx_start <= '1';
    wait for 1 us;
    tx_start <= '0';
    wait for 1100 us;
    std.env.finish;
  end process;

  process
  begin
    -- 12MHz clock
    loop
      clk <= '0';
      wait for 41666 ps;
      clk <= '1';
      wait for 41666 ps;
    end loop;
  end process;

end uart_tb_arch;
