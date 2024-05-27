library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity debounce is
  generic(delay_counts: integer := 9); --delay of 5us with clk frequency equal to 100MHZ 512/100MHZ ~ 5us
  Port (clk: in std_logic;
        inp_signal: in std_logic;
        delayed_out: out std_logic);
end debounce;

architecture Behavioral of debounce is

signal curr_input: std_logic;
signal prev_input: std_logic;
signal reset_counter: std_logic;
signal delay_counter: std_logic_vector(delay_counts downto 0) := (others => '0');

begin

reset_counter <= curr_input xor prev_input; --if the two signal are the same then reset counter = 0 meaning that the input is held not noise

process(clk) begin
    if(rising_edge(clk)) then 
        curr_input <= inp_signal;
        prev_input <= curr_input;
        if(reset_counter = '1') then 
            delay_counter <= (others => '0');
        elsif(delay_counter(delay_counts) = '1') then --512 in this case 
            delayed_out <= inp_signal;
        else 
            delay_counter <= delay_counter + 1;
        end if;
    end if;
end process;

end Behavioral;
