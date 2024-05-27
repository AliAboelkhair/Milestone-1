library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Car_Game is
 Port (
        clk   : in  std_logic;
        reset : in std_logic;
        right_2,left_2,up_2,down_2: in std_logic;
        Rx_serial: in std_logic;
        Hsync : out std_logic;
        Vsync : out std_logic;
        R_out : out std_logic_vector(3 downto 0);
        G_out : out std_logic_vector(3 downto 0);
        B_out : out std_logic_vector(3 downto 0);
        LED_out : out std_logic_vector(6 downto 0);
        Anode : out std_logic_vector(3 downto 0);
        tx_active_led: out std_logic;
        tx_uart_serial : out std_logic 
    );
end Car_Game;

architecture Behavioral of Car_Game is

component blk_mem_gen_0 is
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);  
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
end component;

component blk_mem_gen_1 is
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(10  DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);  
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
end component;

component blk_mem_gen_2 is
  PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
end component;

component car_obst_2 is
  PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
end component;

component blk_mem_gen_3 is
    PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
end component;

component uart_rx is
  generic (
    g_CLKS_PER_BIT : integer := 2605     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;

component uart_tx is
  generic (
    g_CLKS_PER_BIT : integer := 2605     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic; --start transmission bit 
    i_TX_Byte   : in  std_logic_vector(7 downto 0); --input byte
    o_TX_Active : out std_logic; --start transmission
    o_TX_Serial : out std_logic; -- start data bits stop 
    o_TX_Done   : out std_logic  --done transmission 
    );
end component;

component counter_text is
    port(
    clk : in std_logic;
    video_on : in std_logic;
    score : in std_logic_vector(31 downto 0);
    x,y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector(11 downto 0));
end component;

component score_text is
    port(
    clk: in std_logic;
    video_on : in std_logic;
    x,y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector(11 downto 0));
end component;

component high_score_text is
    port(
    clk: in std_logic;
    video_on : in std_logic;
    x,y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector(11 downto 0));
end component;

component GameOver_Display is
    port(
    clk: in std_logic;
    video_on : in std_logic;
    x,y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector(11 downto 0));
end component;

--ClockScaling
    shared variable counter : integer := 0;
    signal clk25: std_logic := '0';  
--Flags For Each Player to stop road movement when pressing a button
    signal Pressed: std_logic :=  '0';
    signal Pressed_2: std_logic :=  '0';
--Player1 to Obstacle1 player1
    signal GameOver_player1_Top: std_logic := '0';
    signal GameOver_player1_Bot: std_logic := '0';
    signal GameOver_player1_Right: std_logic := '0';
    signal GameOver_player1_Left: std_logic := '0';
--Player2 to Obstacle1 player2  
    signal GameOver_player2_Top: std_logic := '0';
    signal GameOver_player2_Bot: std_logic := '0';
    signal GameOver_player2_Right: std_logic := '0';
    signal GameOver_player2_Left: std_logic := '0';
--Player1 to Obstacle2 player1
    signal GameOver_player1_Top_2: std_logic := '0';
    signal GameOver_player1_Bot_2: std_logic := '0';
    signal GameOver_player1_Right_2: std_logic := '0';
    signal GameOver_player1_Left_2: std_logic := '0';
--Player2 to Obstacle2 player2 
    signal GameOver_player2_Top_2: std_logic := '0';
    signal GameOver_player2_Bot_2: std_logic := '0';
    signal GameOver_player2_Right_2: std_logic := '0';
    signal GameOver_player2_Left_2: std_logic := '0';
--Player1 to Player2  
    signal PVP_Top: std_logic := '0';
    signal PVP_Bot: std_logic := '0';
    signal PVP_Right: std_logic := '0';
    signal PVP_Left: std_logic := '0';
--Player2 to Player1
    signal PVP_Top2: std_logic := '0';
    signal PVP_Bot2: std_logic := '0';
    signal PVP_Right2: std_logic := '0';
    signal PVP_Left2: std_logic := '0';
--12 Bits RGB Extraction from memory for Road and 16 bits memory address for road
    signal RGB_sig_road: std_logic_vector(11 downto 0);
    signal address_road : STD_LOGIC_VECTOR(16 downto 0) := (others => '0');
--12 Bits RGB Extraction from memory for Car1 and 16 bits memory address for car1     
    signal RGB_sig_car: std_logic_vector(11 downto 0);
    signal address_car : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
--12 Bits RGB Extraction from memory for Car2 and 16 bits memory address for car2 
    signal RGB_sig_car_2: std_logic_vector(11 downto 0);
    signal address_car_2 : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
--12 Bits RGB Extraction from memory for Obstacle and 16 bits memory address for Obstacle
    signal RGB_sig_obstacle: std_logic_vector(11 downto 0);
    --signal address_obstacle : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal address_obstacle_1 : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal address_obstacle_2 : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal RGB_sig_obstacle_2: std_logic_vector(11 downto 0);
 --RGB Signals for VGA
    signal R_sig_out : std_logic_vector(3 downto 0);
    signal G_sig_out : std_logic_vector(3 downto 0);
    signal B_sig_out : std_logic_vector(3 downto 0);
    signal Hsync_out : std_logic;
    signal Vsync_out : std_logic;   
--Uart Reciever    
    signal RX_DV: std_logic;
    signal RX_byte: std_logic_vector(7 downto 0);
--Uart Transmit    
    signal TX_DV: std_logic;
    signal Transmit_byte: std_logic_vector(7 downto 0);
    signal TX_Active: std_logic;
    signal TX_serial: std_logic;
    signal TX_done: std_logic;
--Movement
    signal right: std_logic;
    signal left: std_logic;
    signal up: std_logic;
    signal down: std_logic;
--HorizontalValues
    constant H_RES    : integer := 640;
    constant H_FP     : integer := 16;
    constant H_SYNC   : integer := 96;
    constant H_BP     : integer := 48;
--VerticalValues
    constant V_RES    : integer := 480;
    constant V_FP     : integer := 10;
    constant V_SYNC   : integer := 2;
    constant V_BP     : integer := 33;
--first Car Corners
    shared variable Car_Len : integer := 40;
    shared variable Car_top : integer := 390; 
    shared variable Car_bot : integer := Car_top + Car_Len;
    shared variable Car_left : integer := 260;
    shared variable Car_right : integer := Car_left + Car_Len;   
--Second Car Corners 
    shared variable Car_Len_2 : integer := 40;
    shared variable Car_top_2 : integer := 390; 
    shared variable Car_bot_2 : integer := Car_top_2 + Car_Len_2;
    shared variable Car_left_2 : integer := 330;
    shared variable Car_right_2 : integer := Car_left_2 + Car_Len_2;   
--Obstacle 1
    shared variable obstacle_Len : integer := 40;
    shared variable obstacle_top : integer := 20; 
    shared variable obstacle_bot : integer := obstacle_top + obstacle_Len;
    shared variable obstacle_left : integer := 250;
    shared variable obstacle_right : integer := obstacle_left + obstacle_Len; 
--Obstacle 2 
    shared variable obstacle_Len_2 : integer := 40;
    shared variable obstacle_top_2 : integer := 80; 
    shared variable obstacle_bot_2 : integer := obstacle_top_2 + obstacle_Len_2;
    shared variable obstacle_left_2 : integer := 350;
    shared variable obstacle_right_2 : integer := obstacle_left_2 + obstacle_Len_2;
    constant obstacle_location: integer := 20;
--Score 7-segment
    shared variable Score : integer := 0;
    signal LED_C: STD_logic_vector (3 downto 0);
    signal LED_Active : STD_logic_vector (1 downto 0);
    signal displayed_number: STD_LOGIC_VECTOR (15 downto 0);
    signal one_second_counter: STD_LOGIC_VECTOR (27 downto 0);
    signal half_second_counter: STD_LOGIC_VECTOR (27 downto 0);
    signal one_second_enable: std_logic;
    signal half_second_enable: std_logic;
    signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
--Score on screen
    signal score_input: std_logic_vector(31 downto 0) := (others => '0');
    signal video_on : std_logic := '0';
    signal x : std_logic_vector(9 downto 0);
    signal y : std_logic_vector (9 downto 0);
    signal score_data: std_logic_vector(11 downto 0);
    signal score_data_25: std_logic_vector(11 downto 0);
--Score text on screen
    signal score_word: std_logic_vector(11 downto 0);    
    signal high_score_word: std_logic_vector(11 downto 0);
    signal GameOver_word: std_logic_vector(11 downto 0);
    signal GameOver_TX: std_logic := '0';
    signal GameOver_RX: std_logic := '0';

    shared variable HC : integer := 1;
    shared variable VC : integer := 1;
       
begin
 clock_generation : process (clk)--ClockScaling Process
    begin
        if rising_edge(clk) then
            if counter = 1 then
                counter := 0;
                clk25   <= not clk25;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;

    Blk_Ram_Road: blk_mem_gen_0 port map(clk25,'1',"0", address_road, (others => '0'), RGB_sig_road);--Block memory assignment
    Blk_Ram_Car: blk_mem_gen_1 port map(clk25,'1',"0", address_car, (others => '0'), RGB_sig_car);--Block memory assignment
    Blk_Ram_Car_obstacle: blk_mem_gen_2 port map(clk25,'1',"0", address_obstacle_1, (others => '0'), RGB_sig_obstacle);--Block memory assignment
    Blk_Ram_Car_obstacle_2: car_obst_2 port map(clk25,'1',"0", address_obstacle_2, (others => '0'), RGB_sig_obstacle_2);--Block memory assignment    
    BLK_Ram_Car_2: blk_mem_gen_3 port map(clk25,'1',"0", address_car_2, (others => '0'), RGB_sig_car_2);--Block memory assignment
    Uart_RX_serial: uart_rx generic map(2605) port map(clk25,Rx_serial,RX_DV,RX_byte);
    Uart_transmitter: uart_tx generic map(2605) port map(clk25,TX_DV,Transmit_byte,TX_Active,TX_serial,TX_done);
    Display_score: counter_text port map(clk => clk25, video_on => '1', score => score_input, x => x, y => y, rgb => score_data);
    Display_Score_Text: score_text port map(clk => clk25, video_on => '1', x => x, y => y, rgb => score_word);
    Display_High_score_Text: high_score_text port map(clk => clk25, video_on => '1', x => x, y => y, rgb => high_score_word);
    Display_GameOver: GameOver_Display port map(clk => clk25, video_on => '1', x => x, y => y, rgb => GameOver_word);
  
SevenSegment : process (LED_C)
    begin
        case LED_C is
        when "0000" => LED_out <= "0000001"; -- "0"     
        when "0001" => LED_out <= "1001111"; -- "1" 
        when "0010" => LED_out <= "0010010"; -- "2" 
        when "0011" => LED_out <= "0000110"; -- "3" 
        when "0100" => LED_out <= "1001100"; -- "4" 
        when "0101" => LED_out <= "0100100"; -- "5" 
        when "0110" => LED_out <= "0100000"; -- "6" 
        when "0111" => LED_out <= "0001111"; -- "7" 
        when "1000" => LED_out <= "0000000"; -- "8"     
        when "1001" => LED_out <= "0000100"; -- "9" 
        when others => LED_out <= "0000001";
        end case;
    end process;
OneSecondRefresh: process(clk,reset)
    begin 
        if(reset = '1') then
            refresh_counter <= (others => '0');
        elsif(rising_edge(clk)) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;
 
LED_Active <= refresh_counter(19 downto 18);
    
AnodeAssignment :process(LED_Active)
    begin
        case LED_Active is
        when "00" =>
            Anode <= "0111"; -- activate LED1 and Deactivate LED2, LED3, LED4
            LED_C <= std_logic_vector(to_unsigned(to_integer(unsigned(displayed_number)) / 1000, LED_C'length));
        when "01" =>
            Anode <= "1011"; -- activate LED2 and Deactivate LED1, LED3, LED4         
            LED_C <= std_logic_vector(to_unsigned(to_integer(unsigned(displayed_number)) mod 1000 / 100,LED_C'length));
        when "10" =>
            Anode <= "1101"; -- activate LED3 and Deactivate LED2, LED1, LED4
            LED_C <= std_logic_vector(to_unsigned(to_integer(unsigned(displayed_number)) mod 1000 mod 100 / 10, LED_C'length)); 
        when "11" =>
            Anode <= "1110"; -- activate LED4 and Deactivate LED2, LED3, LED1
            LED_C <= std_logic_vector(to_unsigned(to_integer(unsigned(displayed_number)) mod 1000 mod 100 mod 10, LED_C'length));      
        end case;
    end process;
    
    
process(clk, reset)
begin
        if(reset = '1') then
            one_second_counter <= (others => '0');
            half_second_counter <= (others => '0');
        elsif(rising_edge(clk)) then
            if(one_second_counter>=99999999 and
             GameOver_player2_Left = '0' and
             GameOver_player2_Right = '0' and
             GameOver_player2_Top = '0' and
             GameOver_player2_Left_2 = '0' and
             GameOver_player2_Right_2 = '0' and
             GameOver_player2_Top_2 = '0' and
             PVP_Left2 = '0' and
             PVP_Right2 = '0' and 
             PVP_Top2 = '0') then
                one_second_counter <= (others => '0');
                
             elsif(GameOver_player2_Left = '0' and
                 GameOver_player2_Right = '0' and
                 GameOver_player2_Top = '0' and
                 GameOver_player2_Left_2 = '0' and
                 GameOver_player2_Right_2 = '0' and
                 GameOver_player2_Top_2 = '0' and
                 PVP_Left2 = '0' and
                 PVP_Right2 = '0' and
                 PVP_Top2 = '0') then
                    one_second_counter <= one_second_counter + 1;
            end if;
                
            if(half_second_counter >= 49999999 and 
            GameOver_player2_Left = '0' and    
            GameOver_player2_Right = '0' and   
            GameOver_player2_Top = '0' and 
            GameOver_player2_Left_2 = '0' and    
            GameOver_player2_Right_2 = '0' and   
            GameOver_player2_Top_2 = '0' and      
            PVP_Left = '0' and                
            PVP_Right = '0' and               
            PVP_Top = '0') then
                     half_second_counter <= (others => '0');
                     
            elsif(GameOver_player2_Left = '0' and
                      GameOver_player2_Right = '0' and
                      GameOver_player2_Top = '0' and
                      GameOver_player2_Left_2 = '0' and
                      GameOver_player2_Right_2 = '0' and
                      GameOver_player2_Top_2 = '0' and
                      PVP_Left2 = '0' and
                      PVP_Right2 = '0' and
                      PVP_Top2 = '0') then 
                        half_second_counter <= half_second_counter + 1;
                end if;
        end if;
end process;

one_second_enable <= '1' when one_second_counter=99999999 else '0';
half_second_enable <= '1' when (half_second_counter=49999999 and up_2 = '1') else '0';

DisplayedNumber: process(clk, reset)
    begin
        if(reset = '1') then
            displayed_number <= (others => '0');
            score_input <= (others => '0');
        elsif(rising_edge(clk)) then
            if(one_second_enable='1') then
                displayed_number <= displayed_number + 1;
                score_input <= score_input + 1;
            elsif(half_second_enable = '1') then
                displayed_number <= displayed_number + 1;
                score_input <= score_input + 1;
            end if;
        end if;
end process;
    
    process (clk25)
        variable delay_counter : integer := 0;
        variable delay : integer := 125000;
        variable move_road : integer := 1;
    begin
        if rising_edge(clk25) then
            if HC < H_RES + H_FP + H_SYNC + H_BP then --HorizontalActiveArea---800
                if HC <= H_RES then --VisibleArea   
                
                    if(GameOver_RX = '1') then 
                        if((HC >= 192 and HC < 448) and (VC >= 208 and VC < 272)) then
                            R_sig_out <= GameOver_word(11 downto 8);
                            G_sig_out <= GameOver_word(7 downto 4);
                            B_sig_out <= GameOver_word(3 downto 0);
                        end if;  
                    elsif(score_input = 150) then
                        GameOver_TX <= '1';
                    else    
                            
                   if((HC >= 24 and HC < 71) and (VC >= 64 and VC < 80)) then
                        R_sig_out <= score_word(11 downto 8);
                        G_sig_out <= score_word(7 downto 4);
                        B_sig_out <= score_word(3 downto 0);
                    
                    elsif((HC >= 24 and HC < 110) and (VC >= 48 and VC < 64)) then          
                        R_sig_out <= high_score_word(11 downto 8);
                        G_sig_out <= high_score_word(7 downto 4);
                        B_sig_out <= high_score_word(3 downto 0);
                        
                    elsif((HC >= 72 and HC <= 119) and (VC >= 64 and VC < 80)) then
                        R_sig_out <= score_data(11 downto 8);
                        G_sig_out <= score_data(7 downto 4);
                        B_sig_out <= score_data(3 downto 0);                         
                    else               
                    if((HC >= 200 and HC < 450)) then 
                        if((HC >= Car_left and HC < Car_right) and (VC >= Car_top and VC < Car_bot)) then
                            if(RGB_sig_Car /= "000000000000") then
                                R_sig_out <= RGB_sig_Car(11 downto 8);
                                G_sig_out <= RGB_sig_Car(7 downto 4);
                                B_sig_out <= RGB_sig_Car(3 downto 0);
                                address_car <= address_car + 1;
                                address_road <= address_road + 1;
                            else
                                R_sig_out <= RGB_sig_road(11 downto 8);
                                G_sig_out <= RGB_sig_road(7 downto 4);
                                B_sig_out <= RGB_sig_road(3 downto 0);
                                address_car <= address_car + 1;
                                address_road <= address_road + 1; 
                            end if;                              
                        elsif((HC >= Car_left_2 and HC < Car_right_2) and (VC >= Car_top_2 and VC < Car_bot_2)) then
                            if(RGB_sig_Car_2 /= "000000000000") then
                                R_sig_out <= RGB_sig_car_2(11 downto 8);
                                G_sig_out <= RGB_sig_car_2(7 downto 4);
                                B_sig_out <= RGB_sig_car_2(3 downto 0);
                                address_car_2 <= address_car_2 + 1;
                                address_road <= address_road + 1;     
                            else
                                R_sig_out <= RGB_sig_road(11 downto 8);
                                G_sig_out <= RGB_sig_road(7 downto 4);
                                B_sig_out <= RGB_sig_road(3 downto 0);
                                address_car_2 <= address_car_2 + 1;
                                address_road <= address_road + 1;                            
                            end if;
                        elsif((HC >= obstacle_left and HC < obstacle_right) and (VC >= obstacle_top and VC < obstacle_bot)) then
                            if(RGB_sig_obstacle /= "000000000000") then
                                R_sig_out <= RGB_sig_obstacle(11 downto 8);
                                G_sig_out <= RGB_sig_obstacle(7 downto 4);
                                B_sig_out <= RGB_sig_obstacle(3 downto 0);
                                address_obstacle_1 <= address_obstacle_1 + 1;
                                address_road <= address_road + 1;  
                            else
                                R_sig_out <= RGB_sig_road(11 downto 8);
                                G_sig_out <= RGB_sig_road(7 downto 4);
                                B_sig_out <= RGB_sig_road(3 downto 0);
                                address_obstacle_1 <= address_obstacle_1 +1;
                                address_road <= address_road + 1;
                            end if;    
                            
                        elsif((HC >= obstacle_left_2 and HC < obstacle_right_2) and (VC >= obstacle_top_2 and VC < obstacle_bot_2)) then
                            if(RGB_sig_obstacle_2 /= "000000000000") then
                                R_sig_out <= RGB_sig_obstacle_2(11 downto 8);
                                G_sig_out <= RGB_sig_obstacle_2(7 downto 4);
                                B_sig_out <= RGB_sig_obstacle_2(3 downto 0);
                                address_obstacle_2 <= address_obstacle_2 + 1 ;
                                address_road <= address_road + 1;  
                            else
                                R_sig_out <= RGB_sig_road(11 downto 8);
                                G_sig_out <= RGB_sig_road(7 downto 4);
                                B_sig_out <= RGB_sig_road(3 downto 0);
                                address_obstacle_2 <= address_obstacle_2 + 1;
                                address_road <= address_road + 1;
                            end if;                           
                        else
                            R_sig_out <= RGB_sig_Road(11 downto 8);
                            G_sig_out <= RGB_sig_Road(7 downto 4);
                            B_sig_out <= RGB_sig_Road(3 downto 0);
                            address_road <= address_road + 1;
                        end if;
                    else
                        R_sig_out <= "0000";
                        G_sig_out <= "0000";
                        B_sig_out <= "0000";                    
                    end if;
                    end if;
                    end if; 
                    
                   if (left = '1' and right = '0' and GameOver_player1_Left = '0' and GameOver_player1_Left_2 = '0' and PVP_Left = '0') then --PressedLeft
                        Pressed <= '1';
                        if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_left >= 230) then
                                Car_left := Car_left - 1; 
                            else
                                Car_left := 230;
                            end if;
                        else
                            delay_counter := delay_counter + 1;  
                        end if;    
                        Pressed <= '0';
                    elsif (left = '0' and right = '1' and GameOver_player1_Right = '0' and GameOver_player1_Right_2 = '0' and PVP_Right = '0') then --PressedRight
                         Pressed <= '1';
                         if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_left  <= 390) then
                                Car_left := Car_left + 1;
                            else 
                                Car_left := 390;
                            end if;
                         else
                            delay_counter := delay_counter + 1;  
                         end if;
                         Pressed <= '0';
                     elsif (down = '0' and up = '1' and GameOver_player1_Top = '0' and GameOver_player1_Top_2 = '0' and PVP_Top = '0') then --PressedUp
                         Pressed <= '1';
                         if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_top  >= 1) then
                                Car_top := Car_top - 1;
                            else 
                                Car_top := 1;
                            end if;
                         else
                            delay_counter := delay_counter + 1;  
                         end if;
                         Pressed <= '0';
                     elsif (down = '1' and up = '0') then --PressedDown
                            Pressed <= '1';
                          if (delay_counter = delay)then
                             delay_counter := 0;
                             if(GameOver_player1_Bot <= '0' and GameOver_player1_Bot_2 <= '0' and PVP_Bot = '0')then
                                if (Car_top  <= 480 - Car_Len) then
                                    Car_top := Car_top + 1;
                                else 
                                    Car_top := 480 - Car_Len;
                                end if;
                             end if;
                          else
                            delay_counter := delay_counter + 1;  
                          end if;
                          if(GameOver_player1_Bot <= '0' and GameOver_player1_Bot_2 <= '0' and PVP_Bot = '0')then
                            Pressed <= '0';
                          end if;
                    elsif (reset = '1')then --Reset
                        GameOver_player1_Left <= '0';
                        GameOver_player1_Right <= '0';
                        GameOver_player1_Top <= '0'; 
                        GameOver_player1_Bot <= '0';
                        GameOver_player2_Left <= '0';
                        GameOver_player2_Right <= '0';
                        GameOver_player2_Top <= '0'; 
                        GameOver_player2_Bot <= '0';
                        GameOver_player1_Left_2 <= '0';
                        GameOver_player1_Right_2 <= '0';
                        GameOver_player1_Top_2 <= '0'; 
                        GameOver_player1_Bot_2 <= '0';
                        GameOver_player2_Left_2 <= '0';
                        GameOver_player2_Right_2 <= '0';
                        GameOver_player2_Top_2 <= '0'; 
                        GameOver_player2_Bot_2 <= '0';                        
                        PVP_Top <= '0';
                        PVP_Bot <= '0';
                        PVP_Left <= '0';
                        PVP_Right <= '0';
                        PVP_Top2 <= '0';
                        PVP_Bot2 <= '0';
                        PVP_Left2 <= '0';
                        PVP_Right2 <= '0';
                        GameOver_TX <= '0';
                        Car_top := 390;
                        Car_left := 260;
                        Car_top_2 := 390;
                        Car_left_2 := 330;
                        obstacle_top := 20;
                        obstacle_left := 250;
                        obstacle_top_2 := 80;
                        obstacle_left_2 := 350;
                    end if;
                    
                    if (left_2 = '1' and right_2 = '0' and GameOver_player2_left = '0' and GameOver_player2_left_2 = '0' and PVP_Left2 = '0') then --PressedLeft
                        Pressed_2 <= '1';
                        if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_left_2 >= 230) then
                                Car_left_2 := Car_left_2 - 1; 
                            else
                                Car_left_2 := 230;
                            end if;
                        else
                            delay_counter := delay_counter + 1;  
                        end if;    
                        Pressed_2 <= '0';
                    elsif (left_2 = '0' and right_2 = '1' and GameOver_player2_right = '0' and GameOver_player2_right_2 = '0' and PVP_Right2 = '0') then --PressedRight
                         Pressed_2 <= '1';
                         if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_left_2  <= 390) then
                                Car_left_2 := Car_left_2 + 1;
                            else 
                                Car_left_2 := 390;
                            end if;
                         else
                            delay_counter := delay_counter + 1;  
                         end if;
                         Pressed_2 <= '0';  
                     elsif (down_2 = '0' and up_2 = '1' and GameOver_player2_top = '0' and GameOver_player2_top_2 = '0' and PVP_Top2 = '0') then --PressedUp
                         Pressed_2 <= '1';
                         if (delay_counter = delay)then
                            delay_counter := 0;
                            if (Car_top_2  >= 1) then
                                Car_top_2 := Car_top_2 - 1;
                            else 
                                Car_top_2 := 1;
                            end if;
                         else
                            delay_counter := delay_counter + 1;  
                         end if;
                         Pressed_2 <= '0';
                     elsif (down_2 = '1' and up_2 = '0') then --PressedDown
                          Pressed_2 <= '1';
                          if (delay_counter = delay)then
                             delay_counter := 0;
                             if(GameOver_player2_Bot <= '0' and GameOver_player2_Bot_2 <= '0' and PVP_Bot2 = '0')then
                                if (Car_top_2  <= 480 - Car_Len_2) then
                                    Car_top_2 := Car_top_2 + 1;
                                else 
                                    Car_top_2 := 480 - Car_Len_2;
                                end if;
                             end if;
                          else
                            delay_counter := delay_counter + 1;  
                          end if;
                          if(GameOver_player2_Bot <= '0' and GameOver_player2_Bot_2 <= '0' and PVP_Bot2 = '0')then
                             Pressed_2 <= '0';
                          end if;
                 end if;
            end if;                    
-----------------------RESET------------------------------------------------------            
                if HC > H_RES + H_FP and HC < H_RES + H_FP + H_SYNC then --Hsync is only 0 at the sync pulse region
                    Hsync_out <= '0';
                else
                    Hsync_out <= '1';
                end if;
            HC := HC + 1;
-----------------------IncrementVC------------------------------------------------           
            else    
                HC := 1;
                    if (VC < V_RES + V_FP + V_SYNC + V_BP) then --VerticalActiveArea
                        if VC > V_RES + V_FP and VC < V_RES + V_FP + V_SYNC then --Vsync is only 0 at the sync pulse region
                            Vsync_out <= '0';
                        else
                            Vsync_out <= '1';
                        end if;
                        
                        VC := VC + 1;
                        
                        if(address_road >= 119999) then
                            address_road <= (others => '0');
                        end if;
                        
                    else --ResetVC
                        VC := 1;
                        address_car <= (others => '0'); --resetting the address after each frame
                        address_car_2 <= (others => '0');
                        address_obstacle_1 <= (others => '0');
                        address_obstacle_2 <= (others => '0');

                        if(obstacle_top < 480 and 
                        GameOver_player1_Left = '0' and
                        GameOver_player1_Right = '0' and
                        GameOver_player1_Top = '0' and
                        GameOver_player1_Bot = '0' and
                        GameOver_player2_Left = '0' and
                        GameOver_player2_Right = '0' and
                        GameOver_player2_Top = '0' and
                        GameOver_player2_Bot = '0') then
                            obstacle_top := obstacle_top + 1;
                        else if(GameOver_player1_Left = '0' and
                        GameOver_player1_Right = '0' and
                        GameOver_player1_Top = '0' and
                        GameOver_player1_Bot = '0' and
                        GameOver_player2_Left = '0' and
                        GameOver_player2_Right = '0' and
                        GameOver_player2_Top = '0' and
                        GameOver_player2_Bot = '0') then
                            obstacle_top := 0;
                            case(obstacle_left) is
                                when 250 => obstacle_left := 330;
                                when 330 => obstacle_left := 300;
                                when 300 => obstacle_left := 280;
                                when 280 => obstacle_left := 370; 
                                when 370 => obstacle_left := 400;
                                when 400 => obstacle_left := 350;
                                when 350 => obstacle_left := 390;
                                when 390 => obstacle_left := 250;
                                when others => obstacle_left := 250;
                            end case;
                        end if;
                        end if;
                                              
                        if(obstacle_top_2 < 480 and 
                        GameOver_player1_Left_2 = '0' and
                        GameOver_player1_Right_2 = '0' and
                        GameOver_player1_Top_2 = '0' and
                        GameOver_player1_Bot_2 = '0' and
                        GameOver_player2_Left_2 = '0' and
                        GameOver_player2_Right_2 = '0' and
                        GameOver_player2_Top_2 = '0' and
                        GameOver_player2_Bot_2 = '0') then
                            obstacle_top_2 := obstacle_top_2 + 1;
                        else if(GameOver_player1_Left_2 = '0' and
                        GameOver_player1_Right_2 = '0' and
                        GameOver_player1_Top_2 = '0' and
                        GameOver_player1_Bot_2 = '0' and
                        GameOver_player2_Left_2 = '0' and
                        GameOver_player2_Right_2 = '0' and
                        GameOver_player2_Top_2 = '0' and
                        GameOver_player2_Bot_2 = '0') then
                            obstacle_top_2 := 0;
                            case(obstacle_left_2) is
                                when 350 => obstacle_left_2 := 260;
                                when 260 => obstacle_left_2 := 400;
                                when 400 => obstacle_left_2 := 340;
                                when 340 => obstacle_left_2 := 240; 
                                when 240 => obstacle_left_2 := 310;
                                when 310 => obstacle_left_2 := 230;
                                when 230 => obstacle_left_2 := 315;
                                when 315 => obstacle_left_2 := 350;
                                when others => obstacle_left_2 := 350;
                            end case;
                        end if;
                        end if;
----------------------------------------Car1 Collision with Obstacle1------------------------------------------------------------------------                        
                          --Top Collision  
                          if((obstacle_bot >= car_top -3 and (obstacle_bot <= car_bot -3)) and (obstacle_left <= car_right and obstacle_right >= car_left)) then 
                            GameOver_player1_Top <= '1';
                          else 
                            GameOver_player1_Top <= '0';
                          end if;
                          --Bot Collision
                          if((obstacle_top <= car_bot +3 and (obstacle_top >= car_top +3)) and (obstacle_left <= car_right and obstacle_right >= car_left)) then 
                            GameOver_player1_Bot <= '1';
                          else 
                            GameOver_player1_Bot <= '0';
                          end if;
                          --Right Collision
                          if((obstacle_left <= car_right +3 and (obstacle_left >= car_left +3)) and (obstacle_top <= car_bot and obstacle_bot >= car_top)) then 
                            GameOver_player1_Right <= '1';
                          else 
                            GameOver_player1_Right <= '0';
                          end if;
                          --Left Collision
                          if((obstacle_right >= car_left -3 and (obstacle_right <= car_right -3)) and (obstacle_top <= car_bot and obstacle_bot >= car_top)) then 
                            GameOver_player1_Left <= '1';
                          else 
                            GameOver_player1_Left <= '0';
                          end if;   
                          
----------------------------------------Car1 Collision with Obstacle2------------------------------------------------------------------------                        
                          --Top Collision  
                          if((obstacle_bot_2 >= car_top -3 and (obstacle_bot_2 <= car_bot -3)) and (obstacle_left_2 <= car_right and obstacle_right_2 >= car_left)) then 
                            GameOver_player1_Top_2 <= '1';
                          else 
                            GameOver_player1_Top_2 <= '0';
                          end if;
                          --Bot Collision
                          if((obstacle_top_2 <= car_bot +3 and (obstacle_top_2 >= car_top +3)) and (obstacle_left_2 <= car_right and obstacle_right_2 >= car_left)) then 
                            GameOver_player1_Bot_2 <= '1';
                          else 
                            GameOver_player1_Bot_2 <= '0';
                          end if;
                          --Right Collision
                          if((obstacle_left_2 <= car_right +3 and (obstacle_left_2 >= car_left +3)) and (obstacle_top_2 <= car_bot and obstacle_bot_2 >= car_top)) then 
                            GameOver_player1_Right_2 <= '1';
                          else 
                            GameOver_player1_Right_2 <= '0';
                          end if;
                          --Left Collision
                          if((obstacle_right_2 >= car_left -3 and (obstacle_right_2 <= car_right -3)) and (obstacle_top_2 <= car_bot and obstacle_bot_2 >= car_top)) then 
                            GameOver_player1_Left_2 <= '1';
                          else 
                            GameOver_player1_Left_2 <= '0';
                          end if;   
                                                                    
--------------------------------------------------Car2 Collision with Obstacle1--------------------------------------------------------------                          
                          --Top Collision  
                          if((obstacle_bot >= car_top_2 -3 and (obstacle_bot <= car_bot_2 -3)) and (obstacle_left <= car_right_2 and obstacle_right >= car_left_2)) then 
                            GameOver_player2_Top <= '1';
                          else 
                            GameOver_player2_Top <= '0';
                          end if;
                          --Bot Collision
                          if((obstacle_top <= car_bot_2 +3 and (obstacle_top >= car_top_2 +3)) and (obstacle_left <= car_right_2 and obstacle_right >= car_left_2)) then 
                            GameOver_player2_Bot <= '1';
                          else 
                            GameOver_player2_Bot <= '0';
                          end if;
                          --Right Collision
                          if((obstacle_left <= car_right_2 +3 and (obstacle_left >= car_left_2 +3)) and (obstacle_top <= car_bot_2 and obstacle_bot >= car_top_2)) then 
                            GameOver_player2_Right <= '1';
                          else 
                            GameOver_player2_Right <= '0';
                          end if;
                          --Left Collision
                          if((obstacle_right >= car_left_2 -3 and (obstacle_right <= car_right_2 -3)) and (obstacle_top <= car_bot_2 and obstacle_bot >= car_top_2)) then 
                            GameOver_player2_Left <= '1';
                          else 
                            GameOver_player2_Left <= '0';
                          end if;  
                          
--------------------------------------------------Car2 Collision with Obstacle2--------------------------------------------------------------                          
                          --Top Collision  
                          if((obstacle_bot_2 >= car_top_2 -3 and (obstacle_bot_2 <= car_bot_2 -3)) and (obstacle_left_2 <= car_right_2 and obstacle_right_2 >= car_left_2)) then 
                            GameOver_player2_Top_2 <= '1';
                          else 
                            GameOver_player2_Top_2 <= '0';
                          end if;
                          --Bot Collision
                          if((obstacle_top_2 <= car_bot_2 +3 and (obstacle_top_2 >= car_top_2 +3)) and (obstacle_left_2 <= car_right_2  and obstacle_right_2 >= car_left_2)) then 
                            GameOver_player2_Bot_2 <= '1';
                          else 
                            GameOver_player2_Bot_2 <= '0';
                          end if;
                          --Right Collision
                          if((obstacle_left_2 <= car_right_2 +3 and (obstacle_left_2 >= car_left_2 +3)) and (obstacle_top_2 <= car_bot_2 and obstacle_bot_2 >= car_top_2)) then 
                            GameOver_player2_Right_2 <= '1';
                          else 
                            GameOver_player2_Right_2 <= '0';
                          end if;
                          --Left Collision
                          if((obstacle_right_2 >= car_left_2 -3 and (obstacle_right_2 <= car_right_2 -3)) and (obstacle_top_2 <= car_bot_2 and obstacle_bot_2 >= car_top_2)) then 
                            GameOver_player2_Left_2 <= '1';
                          else 
                            GameOver_player2_Left_2 <= '0';
                          end if; 
                          
----------------------------------Car1 Collision with Car2----------------------------------------------------------------------       
                          --Car1 bot with car2 top  
                          if((car_bot >= car_top_2 -3 and (car_bot <= car_bot_2 -3)) and (car_left <= car_right_2 and car_right >= car_left_2)) then 
                            PVP_Bot <= '1';
                            PVP_Top2 <= '1';
                          else 
                            PVP_Bot <= '0';                           
                            PVP_Top2 <= '0';
                          end if;
                          --Car1 top with car2 bot
                          if((car_top <= car_bot_2 +3 and (car_top >= car_top_2 +3)) and (car_left <= car_right_2 and car_right >= car_left_2)) then 
                            PVP_Top <= '1';
                            PVP_Bot2 <= '1';
                          else 
                            PVP_Top <= '0'; 
                            PVP_Bot2 <= '0';
                          end if;
                          --Car1 left with Car2 right
                          if((car_left <= car_right_2 +3 and (car_left >= car_left_2 +3)) and (car_top <= car_bot_2 and car_bot >= car_top_2)) then 
                            PVP_Left <= '1';
                            PVP_Right2 <= '1';
                          else 
                            PVP_Left <= '0';  
                            PVP_Right2 <= '0';
                          end if;
                          --Car1 right with car2 left
                          if((car_right >= car_left_2 -3 and (car_right <= car_right_2 -3)) and (car_top <= car_bot_2 and car_bot >= car_top_2)) then 
                            PVP_Right <= '1';  
                            PVP_Left2 <= '1';
                          else 
                            PVP_Right <= '0';
                            PVP_Left2 <= '0';
                          end if; 
-------------------------------------------------------------------------------------------------------------------------------------------------                                           
                        if(move_road = 480) then
                            move_road := 1;
                        elsif((move_road < 480))then 
                            move_road := move_road + 1;
                            if(Pressed = '0' and PVP_Bot = '0' and GameOver_player1_Bot_2 = '0'and GameOver_player1_Bot = '0')then
                                Car_top := Car_top + 1;
                            end if;
                            if(Pressed_2 = '0' and PVP_Bot2 = '0' and GameOver_player2_Bot_2 = '0'and GameOver_player2_Bot = '0')then
                                Car_top_2 := Car_top_2 + 1;
                            end if;                            
                            if (Car_bot >= 480) then
                                Car_top := 440 ;
                            end if;
                            if (Car_bot_2 >= 480) then
                                Car_top_2 := 440 ;
                            end if;
                        end if;
                        address_road <= std_logic_vector(TO_UNSIGNED((119999 - (250 * move_road)) + 1,17)); --Move the road
                    end if;   
            end if; --HorizontalActiveArea
            end if; -- risingEdge
    end process;
    
    TX_DV <= '1';
    Transmit_byte <= right_2 & left_2 & up_2 & down_2 & reset & GameOver_TX & "00";
    tx_uart_serial <= TX_serial;
    tx_active_led <= TX_Active;
    
    right <= RX_byte(7) when(RX_DV = '1');
    left <= RX_byte(6) when(RX_DV = '1');
    up <= RX_byte(5) when(RX_DV = '1');
    down <= RX_byte(4) when(RX_DV = '1');
    GameOver_RX <= RX_byte(3) when(RX_DV = '1');
    
    R_out <= R_sig_out;
    G_out <= G_sig_out; 
    B_out <= B_sig_out; 
    Hsync <= Hsync_out;
    Vsync <= Vsync_out;
    
    x <= std_logic_vector(TO_UNSIGNED(HC, 10));
    y <= std_logic_vector(TO_UNSIGNED(VC, 10));
    
end Behavioral;
