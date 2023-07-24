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
end uart_tb;

architecture uart_tb_arch of uart_tb is

  procedure f_gen_clk(constant freq : in    natural;
                      signal   clk  : inout std_logic) is
  begin
    loop
      wait for (0.5 / real(freq)) * 1 sec;
      clk <= not clk;
    end loop;
  end procedure f_gen_clk;

  procedure f_wait_cycles(signal   clk    : in std_logic;
                          constant cycles : natural) is
  begin
    for i in 1 to cycles loop
      wait until rising_edge(clk);
    end loop;
  end procedure f_wait_cycles;

  procedure f_write_uart(data:        in  std_logic_vector(7 downto 0);
                         baud:        in  integer;
                         signal tx:   out std_logic) is
  begin
    for bit_cnt in 0 to 9 loop
      if bit_cnt = 0 then
        tx <= '0';
      elsif bit_cnt >= 1 and bit_cnt <= 8 then
        tx <= data(bit_cnt-1);
      else
        tx <= '1';
      end if;
      wait for (1.0 / real(baud)) * 1.0 sec;
    end loop;
  end procedure;

  procedure f_read_uart(data:        out std_logic_vector(7 downto 0);
                        baud:        in  integer;
                        signal rx:   in  std_logic) is
    variable data_tmp: std_logic_vector(7 downto 0) := (others => '0');
  begin
    -- Detect start bit
    wait until rx = '0';
    -- Sync to the middle of the first data bit
    wait for (1.5 / real(baud)) * 1.0 sec;
    for bit_cnt in 0 to 7 loop
      data_tmp(bit_cnt) := rx;
      wait for (1.0 / real(baud)) * 1.0 sec;
    end loop;
    data := data_tmp;
  end procedure;

  signal clk: std_logic := '0';
  signal rst_n: std_logic := '0';
  signal tx_start: std_logic := '0';
  signal tx_data: std_logic_vector(7 downto 0) := (others => '0');
  signal tx_busy: std_logic := '0';
  signal tx: std_logic := '1';
  signal rx_data: std_logic_vector(7 downto 0);
  signal rx_data_valid: std_logic := '0';
  signal rx: std_logic := '1';

  signal check_tx_data_done: boolean := false;
  signal check_rx_data_done: boolean := false;
  signal gen_rx_data_done: boolean := false;
begin
  uart_inst: entity work.uart
    port map (
      rst_n_i => rst_n,
      clk_i => clk,
      clk_div_i => x"0068",
      tx_data_i => tx_data,
      tx_start_i => tx_start,
      tx_busy_o => tx_busy,
      tx_o => tx,
      rx_data_o => rx_data,
      rx_data_valid_o => rx_data_valid,
      rx_i => rx
      );

  -- Generate 12MHz clock
  f_gen_clk(12_000_000, clk);

  p_gen_tx_data:
  process
  begin
    -- Reset the core
    rst_n <= '0';
    f_wait_cycles(clk, 10);
    rst_n <= '1';
    f_wait_cycles(clk, 1);

    -- Generate bytes with values from 0 to 255 and start a
    -- transmission
    for byte in 0 to 255 loop
      tx_data <= std_logic_vector(to_unsigned(byte, 8));
      tx_start <= '1';
      f_wait_cycles(clk, 1);
      tx_start <= '0';
      wait until tx_busy = '0';
      f_wait_cycles(clk, 1);
    end loop;

    -- Wait for all process to finish
    if check_tx_data_done = false then
      wait until check_tx_data_done = true;
    end if;

    if check_rx_data_done = false then
      wait until check_rx_data_done = true;
    end if;

    if gen_rx_data_done = false then
      wait until gen_rx_data_done = true;
    end if;

    std.env.finish;
  end process;

  p_check_tx_data:
  process
    variable data_read: std_logic_vector(7 downto 0);
  begin
    wait until rst_n = '1';
    -- Validate the transmitted data
    for byte in 0 to 255 loop
      f_read_uart(data_read, 115200, tx);
      assert data_read = std_logic_vector(to_unsigned(byte, 8)) severity failure;
    end loop;
    check_tx_data_done <= true;
  end process;

  p_gen_rx_data:
  process
  begin
    wait until rst_n = '1';
    f_wait_cycles(clk, 1);
    -- Generate bytes with values from 0 to 255 and receive then
    for byte in 255 downto 0 loop
      f_write_uart(std_logic_vector(to_unsigned(byte, 8)), 115200, rx);
    end loop;
    gen_rx_data_done <= true;
  end process;

  p_check_rx_data:
  process
  begin
    -- Validate the received bytes
    for byte in 255 downto 0 loop
      wait until rx_data_valid = '1';
      assert rx_data = std_logic_vector(to_unsigned(byte, 8)) severity failure;
      f_wait_cycles(clk, 1);
    end loop;
    check_rx_data_done <= true;
  end process;

end uart_tb_arch;
