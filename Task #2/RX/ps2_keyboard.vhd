library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ps2_keyboard is
    GENERIC(
      clk_freq : INTEGER := 100_000_000; --system clock frequency in Hz
      delay_counts : INTEGER := 9); --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
    PORT(
      clk          : IN  STD_LOGIC;                     --system clock
      ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data     : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ps2_code_new : OUT STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
      ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --code received from PS/2
end ps2_keyboard;

architecture Behavioral of ps2_keyboard is

signal ps2_curr_clock: std_logic;
signal ps2_curr_data: std_logic;
signal debounced_ps2_clk: std_logic; --output clock of debounce module 
signal debounced_ps2_data: std_logic; --output data of debounce module 
signal ps2_word: std_logic_vector(10 downto 0); --11 bits word start bit/one byte/parity/stop bit
signal ps2_check_error: std_logic; --error start bit = 0 / stop bit = 1 / parity bit = 0
signal idle: integer range 0 to clk_freq / 18000; --this will give a period which is more than half the period of ps2 clk

component debounce is
  generic(delay_counts: integer := 9); --delay of 5us with clk frequency equal to 100MHZ 512/100MHZ ~ 5us
  Port (clk: in std_logic;
        inp_signal: in std_logic;
        delayed_out: out std_logic);    
end component;

begin
    --ps2 clk debouncing
    debounce_clk: debounce generic map(delay_counts) port map(clk,ps2_curr_clock,debounced_ps2_clk);
    
    --ps2 data debouncing
    debounce_data:debounce generic map(delay_counts) port map(clk,ps2_curr_data,debounced_ps2_data);
    
      --verify that parity, start, and stop bits are all correct
    ps2_check_error <= NOT (NOT ps2_word(0) AND ps2_word(10) AND (ps2_word(9) XOR ps2_word(8) XOR
        ps2_word(7) XOR ps2_word(6) XOR ps2_word(5) XOR ps2_word(4) XOR ps2_word(3) XOR 
        ps2_word(2) XOR ps2_word(1)));  
    
    --process to synchronize the protocol based on rising edge os system clock 
    process(clk) begin
        if(rising_edge(clk)) then
            ps2_curr_clock <= ps2_clk;
            ps2_curr_data <= ps2_data;
            
            --check that the last bit is received or not 
            if(debounced_ps2_clk = '0') then 
                idle <= 0;
            elsif(idle /= clk_freq/18000) then
                idle <= idle + 1;
            end if;
            
            if(idle = clk_freq/18000 and ps2_check_error = '0') then
                ps2_code_new <= '1';
                ps2_code <= ps2_word(8 DOWNTO 1); 
            else
                ps2_code_new <= '0'; 
            end if;   
        end if;
    end process;
    
    --ps2 sends the data at the negative edge of the ps2 clk 
    process(debounced_ps2_clk) begin
        if(falling_edge(debounced_ps2_clk)) then
            ps2_word <= debounced_ps2_data & ps2_word(10 downto 1); --receive the bits from the keyboard 
        end if;
    end process;
    
end Behavioral;
