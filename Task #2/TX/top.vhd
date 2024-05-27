library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);   
  Port (
        clk   : in  std_logic;
        PS2Clk : in std_logic;
        PS2Data : in std_logic;
        Rx_serial: in std_logic;
        --reset : in std_logic;
        Hsync : out std_logic;
        Vsync : out std_logic;
        R_out : out std_logic_vector(3 downto 0);
        G_out : out std_logic_vector(3 downto 0);
        B_out : out std_logic_vector(3 downto 0);
        LED_out : out std_logic_vector(6 downto 0);
        Anode : out std_logic_vector(3 downto 0);
        ascii_new: out std_logic;
        tx_active_led: out std_logic;
        tx_uart_serial: out std_logic);
end top;

architecture Behavioral of top is

component Car_Game is 
     Port (
        clk   : in  std_logic;
        reset : in std_logic;
        right_2,left_2,up_2,down_2: in std_logic;
        --right_2,left_2,up_2,down_2: in std_logic;
        Rx_serial: in std_logic;
        Hsync : out std_logic;
        Vsync : out std_logic;
        R_out : out std_logic_vector(3 downto 0);
        G_out : out std_logic_vector(3 downto 0);
        B_out : out std_logic_vector(3 downto 0);
        LED_out : out std_logic_vector(6 downto 0);
        Anode : out std_logic_vector(3 downto 0);
        tx_active_led: out std_logic;
        tx_uart_serial: out std_logic
    );
end component;

component ps2_keyboard_to_ascii is
  GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
end component;

signal ascii_new_ps2: std_logic;
signal ascii_code_ps2: std_logic_vector(6 downto 0);
signal move_car_left: std_logic;
signal move_car_right: std_logic;
signal move_car_up: std_logic;
signal move_car_down: std_logic;
signal reset: std_logic;

begin
    ps2: ps2_keyboard_to_ascii generic map(clk_freq,ps2_debounce_counter_size) port map(clk,PS2Clk,PS2Data,ascii_new_ps2,ascii_code_ps2);
    
    Game: Car_Game port map(clk,reset,move_car_right,move_car_left,move_car_up,move_car_down,Rx_serial,Hsync,Vsync,R_out,G_out,B_out,LED_out,Anode,tx_active_led,tx_uart_serial); 
    
    move_car_left <= '1' when (ascii_new_ps2 = '1' and ascii_code_ps2 = "1100001") else '0';
    move_car_right <= '1' when (ascii_new_ps2 = '1' and ascii_code_ps2 = "1100100") else '0';
    move_car_up <= '1' when (ascii_new_ps2 = '1' and ascii_code_ps2 = "1110111") else '0';
    move_car_down <= '1' when (ascii_new_ps2 = '1' and ascii_code_ps2 = "1110011") else '0';
    reset <= '1' when (ascii_new_ps2 = '1' and ascii_code_ps2 = "0100000") else '0';
    
    ascii_new <= ascii_new_ps2;

end Behavioral;
