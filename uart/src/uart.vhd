-------------------------------------------------------------------------------
-- Title      : Simple UART core
-------------------------------------------------------------------------------
-- Author     : Augusto Fraga Giachero
-- Platform   : FPGA-generic
-- Standard   : VHDL 93
-------------------------------------------------------------------------------
-- Description: Simple TX/RX UART core with a configurable baud-rate. Data
--              is sampled at the middle of the bit. You should ensure that
--              freq(clk_i) >> Baud rate for a reliable operation.
-------------------------------------------------------------------------------
-- Copyright 2021-2023 Augusto Fraga Giachero <afg@augustofg.net>
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

entity uart is
  port (
    -- Core clock
    clk_i:           in  std_logic;
    -- Core reset (active low)
    rst_n_i:         in  std_logic;
    -- Baud-rate divider: baud = freq(clk_i) / (clk_div_i + 1)
    clk_div_i:       in  unsigned (15 downto 0);
    -- Byte to be transmitted
    tx_data_i:       in  std_logic_vector (7 downto 0);
    -- Start data transmission
    tx_start_i:      in  std_logic;
    -- Indicate if there is an ongoing trasmission
    tx_busy_o:       out std_logic := '1';
    -- UART TX output
    tx_o:            out std_logic := '1';
    -- Byte received
    rx_data_o:       out std_logic_vector (7 downto 0) := x"00";
    -- Data valid pulse (indicates that a new byte was received)
    rx_data_valid_o: out std_logic;
    -- UART RX input
    rx_i:            in  std_logic
    );
end uart;

architecture uart_arch of uart is
  type tx_state_t is (idle, trans_sta_bit, trans_data_bits, trans_sto_bit);
  type rx_state_t is (idle, align_bit_sample, read_data_bits);
  signal tx_state: tx_state_t := idle;
  signal rx_state: rx_state_t := idle;
  signal rx_sync: std_logic := '0';
  signal rx_now: std_logic := '0';
  signal rx_prev: std_logic := '0';
begin

  tx_busy_o <= '1' when tx_state /= idle else tx_start_i;

  process(clk_i)
    variable tx_cnt: unsigned (15 downto 0) := x"0000";
    variable tx_bit_cnt: integer range 0 to 7 := 0;
    variable tx_data_buf: std_logic_vector (7 downto 0);
    variable rx_cnt: unsigned (15 downto 0) := x"0000";
    variable rx_bit_cnt: integer range 0 to 8 := 0;
    variable rx_data_buf: std_logic_vector (7 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        tx_state <= idle;
        tx_o <= '1';
        tx_cnt := x"0000";
        rx_prev <= '0';
        rx_data_valid_o <= '0';
      else
        -- Synchronize rx_i with clk_i (clock domain crossing)
        rx_sync <= rx_i;
        rx_now <= rx_sync;
        rx_prev <= rx_now;
        -- Set rx data valid back to '0'
        rx_data_valid_o <= '0';
        case rx_state is
          when idle =>
            -- Wait for the start bit
            if rx_prev = '1' and rx_now =  '0' then
              rx_state <= align_bit_sample;
            end if;

          when align_bit_sample =>
            -- Wait for a half bit time to align sampling to the middle of the
            -- next bit
            if rx_cnt = ('0' & clk_div_i(clk_div_i'high downto 1)) then
              if rx_now = '1' then          -- If the start bit isn't '0' as
                rx_state <= idle;           -- expected, go to idle
              else
                rx_state <= read_data_bits;
              end if;
              rx_cnt := x"0000";
            else
              rx_cnt := rx_cnt + 1;
            end if;

          when read_data_bits =>
            -- Read 8 data bits + stop bit
            if rx_cnt = clk_div_i then
              rx_cnt := x"0000";
              if rx_bit_cnt = 8 then
                -- Generate a valid pulse if the stop bit is correct
                if rx_now = '1' then
                  rx_data_valid_o <= '1';
                end if;
                rx_state <= idle;
                rx_bit_cnt := 0;
                rx_data_o <= rx_data_buf;
              else
                rx_bit_cnt := rx_bit_cnt + 1;
                rx_data_buf := rx_now & rx_data_buf(7 downto 1);
              end if;
            else
              rx_cnt := rx_cnt + 1;
            end if;
        end case;

        case tx_state is
          when idle =>
            if tx_start_i = '1' then
              tx_data_buf := tx_data_i;
              tx_state <= trans_sta_bit;
            end if;

          when trans_sta_bit =>
            tx_o <= '0';
            if tx_cnt = clk_div_i then
              tx_state <= trans_data_bits;
              tx_cnt := x"0000";
            else
              tx_cnt := tx_cnt + 1;
            end if;

          when trans_data_bits =>
            tx_o <= tx_data_buf(0);
            if tx_cnt = clk_div_i then
              tx_cnt := x"0000";
              if tx_bit_cnt = 7 then
                tx_state <= trans_sto_bit;
                tx_bit_cnt := 0;
              else
                tx_bit_cnt := tx_bit_cnt + 1;
                tx_data_buf := '0' & tx_data_buf(7 downto 1);
              end if;
            else
              tx_cnt := tx_cnt + 1;
            end if;

          when trans_sto_bit =>
            tx_o <= '1';
            if tx_cnt = clk_div_i then
              tx_state <= idle;
              tx_cnt := x"0000";
            else
              tx_cnt := tx_cnt + 1;
            end if;
        end case;

      end if;
    end if;
  end process;

end uart_arch;
