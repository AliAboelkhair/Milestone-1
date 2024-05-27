library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA_Display is
    Port (
        clk   : in  std_logic;
        R_in  : in  std_logic;
        G_in  : in  std_logic;
        B_in  : in  std_logic;
        Hsync : out std_logic := '1';
        Vsync : out std_logic := '1';
        R_out : out std_logic_vector(3 downto 0);
        G_out : out std_logic_vector(3 downto 0);
        B_out : out std_logic_vector(3 downto 0)
    );
end VGA_Display;

architecture Behavioral of VGA_Display is
--ClockScaling
    shared variable counter : integer := 0;
    signal clk25: std_logic := '0';
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
    
    begin
    
    clock_generation : process (clk)
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
    
    process (clk25)
        variable HC   : integer := 1; --Horizontal Counter
        variable VC   : integer := 1; --Vertical Counter
    begin
        if rising_edge(clk25) then
            if HC < H_RES + H_FP + H_SYNC + H_BP then--HorizontalActiveArea---800
                if HC <= H_RES then--VisibleArea
-----------------------RED---------------------------------------------------------
                    if (R_in = '1') then
                        R_out <= "1111";
                    elsif (R_in = '0') then
                        R_out <= "0000";
                    end if;
-----------------------GREEN-------------------------------------------------------
                    if (G_in = '1') then
                        G_out <= "1111";
                    elsif (G_in = '0') then
                        G_out <= "0000";
                    end if;
-----------------------BLUE--------------------------------------------------------
                    if (B_in = '1') then
                        B_out <= "1111";
                    elsif (B_in = '0') then
                        B_out <= "0000";
                    end if;
                else
                    R_out <= "0000";
                    G_out <= "0000";
                    B_out <= "0000";
                end if;
-----------------------RESET------------------------------------------------------            
                if HC > H_RES + H_FP and HC < H_RES + H_FP + H_SYNC  then
                    Hsync <= '0';
                else
                    Hsync <= '1';
                end if;
            HC := HC + 1;
-----------------------IncrementVC------------------------------------------------           
            else    
                HC := 1;
                    if (VC < V_RES + V_FP + V_SYNC + V_BP) then--VerticalActiveArea
                        if VC > V_RES + V_FP and VC < V_RES + V_FP + V_SYNC then
                            Vsync <= '0';
                        else
                            Vsync <= '1';
                        end if;
                        VC := VC + 1;
                    else--ResetVC
                        VC := 1;
                    end if;   
            end if; --HorizontalActiveArea
        end if; -- risingEdge
    end process;
end Behavioral;
