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

entity uart_top is
  port (
    clk_i:     in  std_logic;
    ftdi_rx_i: in  std_logic;
    ftdi_tx_o: out std_logic;
    led0_o, led1_o, led2_o, led3_o: out std_logic;
    led4_o, led5_o, led6_o, led7_o: out std_logic
    );
end uart_top;

architecture uart_top_arch of uart_top is
  constant uart_div: unsigned (15 downto 0) := x"04E1";
  signal tx_buf: std_logic_vector (7 downto 0) := x"41";
  signal tx_start: std_logic := '0';
  signal tx_busy: std_logic := '0';
  signal rx_buf: std_logic_vector (7 downto 0);
  signal rx_data_valid: std_logic := '0';
begin

  (led0_o, led1_o, led2_o, led3_o, led4_o, led5_o, led6_o, led7_o) <= rx_buf;

  uart_inst: entity work.uart
    port map (
      rst_n_i => '1',
      clk_i => clk_i,
      clk_div_i => uart_div,
      tx_data_i => tx_buf,
      tx_start_i => tx_start,
      tx_busy_o => tx_busy,
      tx_o => ftdi_tx_o,
      rx_data_o => rx_buf,
      rx_data_valid_o => rx_data_valid,
      rx_i => ftdi_rx_i
      );

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rx_data_valid = '1' then
        -- Invert character casing (only a-z or A-Z)
        if (unsigned(rx_buf) >= x"41" and unsigned(rx_buf) <= x"5A") or
          (unsigned(rx_buf) >= x"61" and unsigned(rx_buf) <= x"7A") then
          tx_buf <= rx_buf xor x"20";
        else
          tx_buf <= rx_buf;
        end if;
        tx_start <= '1';
      else
        tx_start <= '0';
      end if;
    end if;
  end process;

end uart_top_arch;
