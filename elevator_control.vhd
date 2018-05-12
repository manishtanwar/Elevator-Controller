
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/29/2017 08:26:04 PM
-- Design Name: 
-- Module Name: lab8_elevator_control - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 

--------------seven_segment_display---------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ssd is
Port ( bcdin : in STD_LOGIC_VECTOR (3 downto 0);
sevensegment : out STD_LOGIC_VECTOR (6 downto 0));
end ssd;

architecture ssd of ssd is
begin

process(bcdin)
begin

case bcdin is
when "0000" =>
sevensegment <= "1000000"; ---0
when "0001" =>
sevensegment <= "1111001"; ---1
when "0010" =>
sevensegment <= "0100100"; ---2
when "0011" =>
sevensegment <= "0110000"; ---3
when "0100" =>
sevensegment <= "1100011"; ---u
when "0101" =>
sevensegment <= "0100001"; ---d
when "0110" =>
sevensegment <= "0100011"; ---o
when "0111" =>
sevensegment <= "0100111"; ---c
when others =>
sevensegment <= "1111111"; 
end case;
end process;

end ssd;

-------------------------andoe---------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity anode1 is
    Port ( clock : in  STD_LOGIC;
           anodeout : out  STD_LOGIC_VECTOR (3 downto 0));
end anode1;

architecture anode1 of anode1 is
signal q_tmp: std_logic_vector(3 downto 0):= "1110";
begin
process(clock)
begin
if Rising_edge(clock) then
	q_tmp(1) <= q_tmp(0);
	q_tmp(2) <= q_tmp(1);
	q_tmp(3) <= q_tmp(2);
	q_tmp(0) <= q_tmp(3);
end if;
end process;
anodeout <= q_tmp;
end anode1;

----------clock Divider------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity clkdiv is 
    port( pushbutton : in std_logic;
            clock1 : in std_logic;
          out_clock : out std_logic
        );
end clkdiv;
    
architecture clkdiv of clkdiv is 
signal a: std_logic_vector(16 downto 0);
begin
    process(clock1)
    begin 
        if clock1'event and clock1 = '1' then
            a <= a+1;
        end if;
    end process;
    out_clock <= a(16) when pushbutton = '0' else (clock1);
end clkdiv;



-------------------lift1---------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity lift1_controller is
Port(
    lift1_floor :       in std_logic_vector(3 downto 0);
    lift1_from_rh :     in std_logic_vector (3 downto 0);
    reset :             in std_logic;
    door_open :         in std_logic_vector(1 downto 0);
    door_closed :       in std_logic_vector(1 downto 0);
    clk :               in std_logic;
    up_request_in     : in std_logic_vector(3 downto 0);
    down_request_in   : in std_logic_vector(3 downto 0);
    up_request_out    : out std_logic_vector(3 downto 0);
    down_request_out  : out std_logic_vector(3 downto 0);
    lift1_floor_indicator :  out std_logic_vector(3 downto 0);
    lift1_current_floor  : out std_logic_vector(1 downto 0);
    lift1_state          : out std_logic_vector(1 downto 0);  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift1_status :         out std_logic_vector(1 downto 0);  --00 when moving up--  --01 when moving down--
                                                                 --10 when halted with door open-- --11 when halted with door closed--
    lift_from_rh_out    :  out std_logic_vector(3 downto 0)                 
);
end lift1_controller;
architecture lift1_controller of lift1_controller is

signal curr_floor : std_logic_vector(1 downto 0) := "00";
signal lift_from_rh, lift_floor, union : std_logic_vector(3 downto 0);
signal counter    : std_logic_vector(30 downto 0) := "0000000000000000000000000000000";
signal sl         : std_logic_vector(1 downto 0);

type state is (idle_f0, idle, dc_f0, open_close_middle_f0 ,do_f0, dc, open_close_middle, do , up , down, up_stop, down_stop );  
signal curr_state, next_state : state := idle_f0;


------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%       reset dalna hain      %%%%%%%%%%%%%%%%%%%%%%----------------------------------------------
begin

process(lift_floor)
begin
    lift1_floor_indicator <= lift_floor;
end process;
process(curr_floor)
begin
    lift1_current_floor   <= curr_floor;
end process;



-------------- this process is triggered on rising and dropping edge of clock -------------------------------------

--process(lift1_from_rh, lift1_floor, clk, door_open(0), door_closed(0), reset)
process(clk, reset)
begin

lift_from_rh_out <= lift_from_rh;

    if reset = '1' then
        curr_floor <= "00";
        lift_from_rh <= "0000";
        lift_floor <= "0000";
        union <= "0000";
        curr_state <= idle_f0;
        --next_state <= idle_f0;
        counter <= (others => '0');
--    elsif Rising_edge(clk) then
--        curr_state <= next_state;
    else
    
    if lift1_from_rh(0) = '1' then
        lift_from_rh(0) <= '1';
        union(0) <= '1';
    end if;
    if lift1_from_rh(1) = '1' then
        lift_from_rh(1) <= '1';
        union(1) <= '1';
    end if;
    if lift1_from_rh(2) = '1' then
        lift_from_rh(2) <= '1';
        union(2) <= '1';
    end if;
    if lift1_from_rh(3) = '1' then
        lift_from_rh(3) <= '1';
        union(3) <= '1';
    end if;
    
                
    if lift1_floor(0) = '1' then
        lift_floor(0) <= '1';
        union(0) <= '1';
    end if;
    if lift1_floor(1) = '1' then
        lift_floor(1) <= '1';
        union(1) <= '1';
    end if;
    if lift1_floor(2) = '1' then
        lift_floor(2) <= '1';
        union(2) <= '1';
    end if;
    if lift1_floor(3) = '1' then
        lift_floor(3) <= '1';
        union(3) <= '1';
    end if;
    
    -------------- this assignment will work after one clk cycle ----------------
--    union(0) <= lift_from_rh(0) OR lift_floor(0);
--    union(1) <= lift_from_rh(1) OR lift_floor(1);
--    union(2) <= lift_from_rh(2) OR lift_floor(2);
--    union(3) <= lift_from_rh(3) OR lift_floor(3);

    if Rising_edge(clk) then
    
    case curr_state is 
            when idle_f0 =>     curr_floor <= "00";
                                sl <= "00";
                                lift1_state <= "00";
                                lift1_status <= "10";
                                if union = "0000" then
                                    curr_state <= idle_f0;
                                else 
                                    curr_state <= dc_f0;
                                    counter <= (others => '0');
                                end if;
                                
            when dc_f0   =>     counter <= counter + 1;
                                lift1_status <= "11";
                                if door_open(0) = '1' then
                                    curr_state <= open_close_middle_f0;
                                    counter <= (others => '0'); 
                                elsif counter(26) = '0' then   ---- 27
                                    curr_state <= dc_f0;
                                else
                                    ------ 3 if A curr_state <= up;
                                                                --counter <= (others => '0');
                                    if sl = "00" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;                                    
                                        elsif curr_floor = "01" then
                                            if union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "10" then
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "11" then
                                            if union(2 downto 0) /= "000" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        end if;
                                    end if;
                                    if sl = "01" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "01" then
                                            if union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "10" then
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "11" then
                                            if union(2 downto 0) /= "000" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if; 
                                        end if;
                                    end if; 
                                    if sl = "10" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                        end if;
                                    elsif curr_floor = "01" then
                                            if union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            elsif union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                    elsif curr_floor = "10" then
                                            if union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                    elsif curr_floor = "11" then
                                                if union(2 downto 0) /= "000" then
                                                    curr_state <= down;
                                                    counter <= (others => '0');
                                                end if; 
                                            end if;
                                    end if;
                                end if;
            
            when open_close_middle_f0 =>
                        lift1_status <= "11";
                        counter <= counter +1;
                        if counter(22) = '1' then
                            counter <= (others => '0');
                            curr_state <= do_f0;
                        else 
                            curr_state <= open_close_middle_f0;
                        end if;
           
           when do_f0 => 
                        lift1_status <= "10";
                        counter <= counter + 1;
                        if door_closed(0) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others => '0');
                        elsif counter(27) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others=> '0');
                        else
                            curr_state <= do_f0;
                        end if;          
            when up => 
                        sl <= "01";
                        lift1_state <= "01";
                        lift1_status <= "00";
                        counter <= counter + 1;
                        if counter(28) = '1' then  ----- 27
                            curr_floor <= curr_floor + 1;
                            curr_state <= up_stop;
                        else
                            curr_state <= up;
                        end if;
            when down => 
                        sl <= "10";
                        lift1_state <= "10";
                        lift1_status <= "01";
                        counter <= counter + 1;
                        if counter(28) = '1' then
                            curr_floor <= curr_floor - 1;
                            curr_state <= down_stop;
                        else
                            curr_state <= down;
                        end if;
            when up_stop =>
          
                        if union( to_integer(unsigned(curr_floor)) ) = '1' then
                            curr_state <= dc;
                            counter <= (others=> '0');
                        else
                            curr_state <= up;
                            counter <= (others=> '0');
                        end if; 
            when down_stop =>
                        if union( to_integer(unsigned(curr_floor)) ) = '1' then
                            curr_state <= dc;
                            counter <= (others=> '0');
                        else
                            curr_state <= down;
                            counter <= (others=> '0');
                        end if; 
            when dc =>  
                        lift1_status <= "11";
                        counter <= counter + 1;
                        lift_from_rh(to_integer(unsigned(curr_floor))) <= '0';
                        lift_floor(to_integer(unsigned(curr_floor))) <= '0';
                        union(to_integer(unsigned(curr_floor))) <= '0';
                        if door_open(0) = '1' then
                            curr_state <= open_close_middle;
                            counter <= (others => '0'); 
                        elsif counter(27) /= '1' then ------ 25
                            curr_state <= dc;
                        else 
                            if union(3 downto 0) = "0000" then
                                curr_state <= idle;
                            else 
                                curr_state <= do;
                                counter <= (others => '0'); 
                            end if;
                        end if;
            when open_close_middle =>
                        counter <= counter +1;
                        if counter(22) = '1' then
                            counter <= (others => '0');
                            curr_state <= do;
                        else 
                            curr_state <= open_close_middle;
                        end if;
            when idle => 
                        lift1_status <= "10";
                        sl <= "00";
                        lift1_state <= "00";
                        if union(3 downto 0) = "0000" then
                            curr_state <= idle;
                        else
                            curr_state <= dc_f0;
                        end if;
            when do =>
                        lift1_status <= "10";
                        counter <= counter + 1;
                        if door_closed(0) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others => '0');
                        elsif counter(27) = '1' then -----26
                            curr_state <= dc_f0;
                            counter <= (others=> '0');
                        else
                            curr_state <= do;
                        end if; 
                        
            when others =>
                        curr_state <= idle_f0;
                        
        end case;
    
    end if;
    end if;

    
    --idle_f0, idle, dc_f0, open_close_middle_f0 ,do_f0, dc, open_close_middle, do , up , down, up_stop, down_stop 
    
end process;

end lift1_controller; 

-------------------lift2---------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity lift2_controller is
Port(
    lift2_floor :       in std_logic_vector(3 downto 0);
    lift2_from_rh :     in std_logic_vector (3 downto 0);
    reset :             in std_logic;
    door_open :         in std_logic_vector(1 downto 0);
    door_closed :       in std_logic_vector(1 downto 0);
    clk :               in std_logic;
    up_request_in     : in std_logic_vector(3 downto 0);
    down_request_in   : in std_logic_vector(3 downto 0);
    up_request_out    : out std_logic_vector(3 downto 0);
    down_request_out  : out std_logic_vector(3 downto 0);
    lift2_floor_indicator :  out std_logic_vector(3 downto 0);
    lift2_current_floor  : out std_logic_vector(1 downto 0);
    lift2_state          : out std_logic_vector(1 downto 0);  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift2_status :         out std_logic_vector(1 downto 0);  --00 when moving up--  --01 when moving down--
                                                                 --10 when halted with door open-- --11 when halted with door closed--
    lift_from_rh_out    :  out std_logic_vector(3 downto 0)                 
);
end lift2_controller;
architecture lift2_controller of lift2_controller is

signal curr_floor : std_logic_vector(1 downto 0) := "00";
signal lift_from_rh, lift_floor, union : std_logic_vector(3 downto 0);
signal counter    : std_logic_vector(30 downto 0) := "0000000000000000000000000000000";
signal sl         : std_logic_vector(1 downto 0);

type state is (idle_f0, idle, dc_f0, open_close_middle_f0 ,do_f0, dc, open_close_middle, do , up , down, up_stop, down_stop );  
signal curr_state, next_state : state := idle_f0;


------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%       reset dalna hain      %%%%%%%%%%%%%%%%%%%%%%----------------------------------------------
begin

process(lift_floor)
begin
    lift2_floor_indicator <= lift_floor;
end process;
process(curr_floor)
begin
    lift2_current_floor   <= curr_floor;
end process;



-------------- this process is triggered on rising and dropping edge of clock -------------------------------------

--process(lift2_from_rh, lift2_floor, clk, door_open(0), door_closed(0), reset)
process(clk, reset)
begin

lift_from_rh_out <= lift_from_rh;

    if reset = '1' then
        curr_floor <= "00";
        lift_from_rh <= "0000";
        lift_floor <= "0000";
        union <= "0000";
        curr_state <= idle_f0;
        --next_state <= idle_f0;
        counter <= (others => '0');
--    elsif Rising_edge(clk) then
--        curr_state <= next_state;
    else
    
    if lift2_from_rh(0) = '1' then
        lift_from_rh(0) <= '1';
        union(0) <= '1';
    end if;
    if lift2_from_rh(1) = '1' then
        lift_from_rh(1) <= '1';
        union(1) <= '1';
    end if;
    if lift2_from_rh(2) = '1' then
        lift_from_rh(2) <= '1';
        union(2) <= '1';
    end if;
    if lift2_from_rh(3) = '1' then
        lift_from_rh(3) <= '1';
        union(3) <= '1';
    end if;
    
                
    if lift2_floor(0) = '1' then
        lift_floor(0) <= '1';
        union(0) <= '1';
    end if;
    if lift2_floor(1) = '1' then
        lift_floor(1) <= '1';
        union(1) <= '1';
    end if;
    if lift2_floor(2) = '1' then
        lift_floor(2) <= '1';
        union(2) <= '1';
    end if;
    if lift2_floor(3) = '1' then
        lift_floor(3) <= '1';
        union(3) <= '1';
    end if;
    
    -------------- this assignment will work after one clk cycle ----------------
--    union(0) <= lift_from_rh(0) OR lift_floor(0);
--    union(1) <= lift_from_rh(1) OR lift_floor(1);
--    union(2) <= lift_from_rh(2) OR lift_floor(2);
--    union(3) <= lift_from_rh(3) OR lift_floor(3);

    if Rising_edge(clk) then
    
    case curr_state is 
            when idle_f0 =>     curr_floor <= "00";
                                sl <= "00";
                                lift2_state <= "00";
                                lift2_status <= "10";
                                if union = "0000" then
                                    curr_state <= idle_f0;
                                else 
                                    curr_state <= dc_f0;
                                    counter <= (others => '0');
                                end if;
                                
            when dc_f0   =>     counter <= counter + 1;
                                lift2_status <= "11";
                                if door_open(0) = '1' then
                                    curr_state <= open_close_middle_f0;
                                    counter <= (others => '0'); 
                                elsif counter(26) = '0' then   ---- 27
                                    curr_state <= dc_f0;
                                else
                                    ------ 3 if A curr_state <= up;
                                                                --counter <= (others => '0');
                                    if sl = "00" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;                                    
                                        elsif curr_floor = "01" then
                                            if union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "10" then
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "11" then
                                            if union(2 downto 0) /= "000" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        end if;
                                    end if;
                                    if sl = "01" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "01" then
                                            if union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "10" then
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            elsif union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if;
                                        elsif curr_floor = "11" then
                                            if union(2 downto 0) /= "000" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            end if; 
                                        end if;
                                    end if; 
                                    if sl = "10" then
                                        if curr_floor = "00" then
                                            if union(3 downto 1) /= "000" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                        end if;
                                    elsif curr_floor = "01" then
                                            if union(0) /= '0' then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            elsif union(3 downto 2) /= "00" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                    elsif curr_floor = "10" then
                                            if union(1 downto 0) /= "00" then
                                                curr_state <= down;
                                                counter <= (others => '0');
                                            if union(3 downto 3) /= "0" then
                                                curr_state <= up;
                                                counter <= (others => '0');
                                            end if;
                                    elsif curr_floor = "11" then
                                                if union(2 downto 0) /= "000" then
                                                    curr_state <= down;
                                                    counter <= (others => '0');
                                                end if; 
                                            end if;
                                    end if;
                                end if;
            
            when open_close_middle_f0 =>
                        lift2_status <= "11";
                        counter <= counter +1;
                        if counter(22) = '1' then
                            counter <= (others => '0');
                            curr_state <= do_f0;
                        else 
                            curr_state <= open_close_middle_f0;
                        end if;
           
           when do_f0 => 
                        lift2_status <= "10";
                        counter <= counter + 1;
                        if door_closed(0) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others => '0');
                        elsif counter(27) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others=> '0');
                        else
                            curr_state <= do_f0;
                        end if;          
            when up => 
                        sl <= "01";
                        lift2_state <= "01";
                        lift2_status <= "00";
                        counter <= counter + 1;
                        if counter(28) = '1' then  ----- 27
                            curr_floor <= curr_floor + 1;
                            curr_state <= up_stop;
                        else
                            curr_state <= up;
                        end if;
            when down => 
                        sl <= "10";
                        lift2_state <= "10";
                        lift2_status <= "01";
                        counter <= counter + 1;
                        if counter(28) = '1' then
                            curr_floor <= curr_floor - 1;
                            curr_state <= down_stop;
                        else
                            curr_state <= down;
                        end if;
            when up_stop =>
          
                        if union( to_integer(unsigned(curr_floor)) ) = '1' then
                            curr_state <= dc;
                            counter <= (others=> '0');
                        else
                            curr_state <= up;
                            counter <= (others=> '0');
                        end if; 
            when down_stop =>
                        if union( to_integer(unsigned(curr_floor)) ) = '1' then
                            curr_state <= dc;
                            counter <= (others=> '0');
                        else
                            curr_state <= down;
                            counter <= (others=> '0');
                        end if; 
            when dc =>  
                        lift2_status <= "11";
                        counter <= counter + 1;
                        lift_from_rh(to_integer(unsigned(curr_floor))) <= '0';
                        lift_floor(to_integer(unsigned(curr_floor))) <= '0';
                        union(to_integer(unsigned(curr_floor))) <= '0';
                        if door_open(0) = '1' then
                            curr_state <= open_close_middle;
                            counter <= (others => '0'); 
                        elsif counter(27) /= '1' then ------ 25
                            curr_state <= dc;
                        else 
                            if union(3 downto 0) = "0000" then
                                curr_state <= idle;
                            else 
                                curr_state <= do;
                                counter <= (others => '0'); 
                            end if;
                        end if;
            when open_close_middle =>
                        counter <= counter +1;
                        if counter(22) = '1' then
                            counter <= (others => '0');
                            curr_state <= do;
                        else 
                            curr_state <= open_close_middle;
                        end if;
            when idle => 
                        lift2_status <= "10";
                        sl <= "00";
                        lift2_state <= "00";
                        if union(3 downto 0) = "0000" then
                            curr_state <= idle;
                        else
                            curr_state <= dc_f0;
                        end if;
            when do =>
                        lift2_status <= "10";
                        counter <= counter + 1;
                        if door_closed(0) = '1' then
                            curr_state <= dc_f0;
                            counter <= (others => '0');
                        elsif counter(27) = '1' then -----26
                            curr_state <= dc_f0;
                            counter <= (others=> '0');
                        else
                            curr_state <= do;
                        end if; 
                        
            when others =>
                        curr_state <= idle_f0;
                        
        end case;
    
    end if;
    end if;

    
    --idle_f0, idle, dc_f0, open_close_middle_f0 ,do_f0, dc, open_close_middle, do , up , down, up_stop, down_stop 
    
end process;

end lift2_controller; 




-----------------request_handler----------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity request_handler is
Port(
    lift1_current_floor  : in std_logic_vector(1 downto 0);
    lift2_current_floor  : in std_logic_vector(1 downto 0);
    lift1_state          : in std_logic_vector(1 downto 0);  -- idle = 00 and requp = 01 and reqdown = 10
    lift2_state          : in std_logic_vector(1 downto 0);
    up_request   :         in std_logic_vector(3 downto 0);  -- up request recieved from some floor
    down_request :         in std_logic_vector(3 downto 0);  -- down request recieved from some floor
    reset :             in std_logic;
    clk :               in std_logic;
    lift1_from_rh : out std_logic_vector (3 downto 0); -- when idle it sends floor number to lift 1 to goto
    lift2_from_rh : out std_logic_vector (3 downto 0) -- when idle it sends floor number to lift 2 to goto
    
);
end request_handler;
architecture request_handler of request_handler is
signal up_request_registered    :    std_logic_vector(3 downto 0);
signal down_request_registered  :    std_logic_vector(3 downto 0);
signal lift1_up_0               :    std_logic_vector(1 downto 0);
signal lift1_up_1               :    std_logic_vector(1 downto 0);
signal lift1_up_2               :    std_logic_vector(1 downto 0);
signal lift1_up_3               :    std_logic_vector(1 downto 0);

signal lift2_up_0               :    std_logic_vector(1 downto 0);
signal lift2_up_1               :    std_logic_vector(1 downto 0);
signal lift2_up_2               :    std_logic_vector(1 downto 0);
signal lift2_up_3               :    std_logic_vector(1 downto 0);

signal lift1_down_0               :    std_logic_vector(1 downto 0);
signal lift1_down_1               :    std_logic_vector(1 downto 0);
signal lift1_down_2               :    std_logic_vector(1 downto 0);
signal lift1_down_3               :    std_logic_vector(1 downto 0);


signal lift2_down_0               :    std_logic_vector(1 downto 0);
signal lift2_down_1               :    std_logic_vector(1 downto 0);
signal lift2_down_2               :    std_logic_vector(1 downto 0);
signal lift2_down_3               :    std_logic_vector(1 downto 0);

signal flag                         :   std_logic := '0';

begin

process(clk, reset)
begin

if reset = '1' then
    up_request_registered    <= "0000";
    down_request_registered  <= "0000";
elsif rising_edge(clk) then
    if up_request(0) = '1' then
        up_request_registered(0) <= '1';
    end if;
    if up_request(1) = '1' then
            up_request_registered(1) <= '1';
    end if;
    if up_request(2) = '1' then
            up_request_registered(2) <= '1';
    end if;
    if up_request(3) = '1' then
            up_request_registered(3) <= '0';
     end if;
             
    if down_request(0) = '1' then
        down_request_registered(0) <= '0';
    end if;
    if down_request(1) = '1' then
            down_request_registered(1) <= '1';
    end if;
    if down_request(2) = '1' then
            down_request_registered(2) <= '1';
    end if;
    if down_request(3) = '1' then
            down_request_registered(3) <= '1';
    end if;
    
    if flag = '1' then
            flag <= '0';
            
            lift1_from_rh(0) <= '0';
            lift1_from_rh(1) <= '0';
            lift1_from_rh(2) <= '0';
            lift1_from_rh(3) <= '0';    
            lift2_from_rh(0) <= '0';
            lift2_from_rh(1) <= '0';
            lift2_from_rh(2) <= '0';
            lift2_from_rh(3) <= '0';    
                    
    else
        flag <= '1';
             
             if lift1_state = "01" and lift2_state = "01" then
               
                        if lift1_current_floor = "00" then
                           if up_request_registered(1) = '1' then
                               lift1_from_rh(1) <= '1';
                               up_request_registered(1) <= '0';
                           elsif up_request_registered(2) = '1' then
                               lift1_from_rh(2) <= '1';
                               up_request_registered(2) <= '0';         
                           end if;
                        elsif lift1_current_floor = "01" and lift2_current_floor = "00" then
                          if up_request_registered(1) = '1' then
                             lift2_from_rh(1) <= '1';
                             up_request_registered(1) <= '0';
                          end if;
                          if up_request_registered(2) = '1' then
                              lift1_from_rh(2) <= '1';
                              up_request_registered(2) <= '0';
                          end if;
                        elsif lift1_current_floor = "01" and lift2_current_floor /= "00" then
                          if up_request_registered(2) = '1' then
                              lift1_from_rh(2) <= '1';
                              up_request_registered(2) <= '0';
                          end if;
                        elsif lift1_current_floor = "10" and lift2_current_floor = "00" then
                          if up_request_registered(1) = '1' then
                              lift2_from_rh(1) <= '1';
                              up_request_registered(1) <= '0';
                          elsif up_request_registered(2) = '1' then
                              lift2_from_rh(2) <= '1';
                              up_request_registered(2) <= '0';
                          end if;
                        elsif lift1_current_floor = "10" and lift2_current_floor = "01" then
                          if up_request_registered(2) = '1' then
                              lift2_from_rh(2) <= '1';
                              up_request_registered(2) <= '0';
                          end if;
                        end if;    
                
              elsif lift1_state = "10" and lift2_state = "01" then
                              if lift1_current_floor = "01" and lift2_current_floor = "00" then
                                      if up_request_registered(1) = '1' then
                                          lift2_from_rh(1) <= '1';
                                          up_request_registered(1) <= '0';
                                      elsif up_request_registered(2) = '1' then
                                          lift2_from_rh(2) <= '1';
                                          up_request_registered(2) <= '0';         
                                      end if;
                                   elsif lift1_current_floor = "01" and lift2_current_floor = "01" then
                                     if up_request_registered(2) = '1' then
                                         lift2_from_rh(2) <= '1';
                                         up_request_registered(2) <= '0';         
                                     end if;
                                   elsif lift1_current_floor = "01" and lift2_current_floor = "10" then
                               elsif lift1_current_floor = "10" and lift2_current_floor = "00" then
                                   if up_request_registered(1) = '1' then
                                      lift2_from_rh(1) <= '1';
                                      up_request_registered(1) <= '0';
                                  elsif up_request_registered(2) = '1' then
                                      lift2_from_rh(2) <= '1';
                                      up_request_registered(2) <= '0';         
                                  end if;
                                  
                                  if down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                   end if;
                               elsif lift1_current_floor = "10" and lift2_current_floor = "01" then
                                  if up_request_registered(2) = '1' then
                                      lift2_from_rh(2) <= '1';
                                      up_request_registered(2) <= '0';         
                                  end if;
                                  
                                  if down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                   end if;
                               elsif lift1_current_floor = "10" and lift2_current_floor = "10" then
                                   if down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                   end if;
                               elsif lift1_current_floor = "11" and lift2_current_floor = "00" then
                                       if up_request_registered(1) = '1' then
                                          lift2_from_rh(1) <= '1';
                                          up_request_registered(1) <= '0';
                                      elsif up_request_registered(2) = '1' then
                                          lift2_from_rh(2) <= '1';
                                          up_request_registered(2) <= '0';         
                                      end if;
                                      
                                      if down_request_registered(2) = '1' then
                                           lift1_from_rh(2) <= '1';
                                           down_request_registered(2) <= '0';
                                       elsif down_request_registered(1) = '1' then
                                           lift1_from_rh(1) <= '1';
                                           down_request_registered(1) <= '0';
                                       end if;
                                   elsif lift1_current_floor = "11" and lift2_current_floor = "01" then
                                      if up_request_registered(2) = '1' then
                                          lift2_from_rh(2) <= '1';
                                          up_request_registered(2) <= '0';         
                                      end if;
                                      
                                      if down_request_registered(2) = '1' then
                                          lift1_from_rh(2) <= '1';
                                          down_request_registered(2) <= '0';
                                      elsif down_request_registered(1) = '1' then
                                          lift1_from_rh(1) <= '1';
                                          down_request_registered(1) <= '0';
                                      end if;
                                   elsif lift1_current_floor = "11" and lift2_current_floor = "10" then
                                      if down_request_registered(2) = '1' then
                                           lift1_from_rh(2) <= '1';
                                           down_request_registered(2) <= '0';
                                       elsif down_request_registered(1) = '1' then
                                           lift1_from_rh(1) <= '1';
                                           down_request_registered(1) <= '0';
                                       end if;     
                                    end if;
              elsif lift2_state = "10" and lift1_state = "01" then
                              if lift2_current_floor = "01" and lift1_current_floor = "00" then
                                    if up_request_registered(1) = '1' then
                                        lift1_from_rh(1) <= '1';
                                        up_request_registered(1) <= '0';
                                    elsif up_request_registered(2) = '1' then
                                        lift1_from_rh(2) <= '1';
                                        up_request_registered(2) <= '0';         
                                    end if;
                                 elsif lift2_current_floor = "01" and lift1_current_floor = "01" then
                                   if up_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';         
                                   end if;
                                 elsif lift2_current_floor = "01" and lift1_current_floor = "10" then
                             elsif lift2_current_floor = "10" and lift1_current_floor = "00" then
                                 if up_request_registered(1) = '1' then
                                    lift1_from_rh(1) <= '1';
                                    up_request_registered(1) <= '0';
                                elsif up_request_registered(2) = '1' then
                                    lift1_from_rh(2) <= '1';
                                    up_request_registered(2) <= '0';         
                                end if;
                                
                                if down_request_registered(1) = '1' then
                                     lift2_from_rh(1) <= '1';
                                     down_request_registered(1) <= '0';
                                 end if;
                             elsif lift2_current_floor = "10" and lift1_current_floor = "01" then
                                if up_request_registered(2) = '1' then
                                    lift1_from_rh(2) <= '1';
                                    up_request_registered(2) <= '0';         
                                end if;
                                
                                if down_request_registered(1) = '1' then
                                     lift2_from_rh(1) <= '1';
                                     down_request_registered(1) <= '0';
                                 end if;
                             elsif lift2_current_floor = "10" and lift1_current_floor = "10" then
                                 if down_request_registered(1) = '1' then
                                     lift2_from_rh(1) <= '1';
                                     down_request_registered(1) <= '0';
                                 end if;
                             elsif lift2_current_floor = "11" and lift1_current_floor = "00" then
                                     if up_request_registered(1) = '1' then
                                        lift1_from_rh(1) <= '1';
                                        up_request_registered(1) <= '0';
                                    elsif up_request_registered(2) = '1' then
                                        lift1_from_rh(2) <= '1';
                                        up_request_registered(2) <= '0';         
                                    end if;
                                    
                                    if down_request_registered(2) = '1' then
                                         lift2_from_rh(2) <= '1';
                                         down_request_registered(2) <= '0';
                                     elsif down_request_registered(1) = '1' then
                                         lift2_from_rh(1) <= '1';
                                         down_request_registered(1) <= '0';
                                     end if;
                                 elsif lift2_current_floor = "11" and lift1_current_floor = "01" then
                                    if up_request_registered(2) = '1' then
                                        lift1_from_rh(2) <= '1';
                                        up_request_registered(2) <= '0';         
                                    end if;
                                    
                                    if down_request_registered(2) = '1' then
                                        lift2_from_rh(2) <= '1';
                                        down_request_registered(2) <= '0';
                                    elsif down_request_registered(1) = '1' then
                                        lift2_from_rh(1) <= '1';
                                        down_request_registered(1) <= '0';
                                    end if;
                                 elsif lift2_current_floor = "11" and lift1_current_floor = "10" then
                                    if down_request_registered(2) = '1' then
                                         lift2_from_rh(2) <= '1';
                                         down_request_registered(2) <= '0';
                                     elsif down_request_registered(1) = '1' then
                                         lift2_from_rh(1) <= '1';
                                         down_request_registered(1) <= '0';
                                     end if;     
                                  end if;
              elsif lift1_state = "10" and lift2_state = "10" then             
                              if lift1_current_floor = "11" then
                                 if down_request_registered(1) = '1' then
                                     lift1_from_rh(1) <= '1';
                                     down_request_registered(1) <= '0';
                                 elsif down_request_registered(2) = '1' then
                                     lift1_from_rh(2) <= '1';
                                     down_request_registered(2) <= '0';         
                                 end if;
                              elsif lift1_current_floor = "10" and lift2_current_floor = "11" then
                                if down_request_registered(2) = '1' then
                                   lift2_from_rh(2) <= '1';
                                   down_request_registered(2) <= '0';
                                end if;
                                if down_request_registered(1) = '1' then
                                    lift1_from_rh(1) <= '1';
                                    down_request_registered(1) <= '0';
                                end if;
                              elsif lift1_current_floor = "10" and lift2_current_floor /= "11" then
                                if down_request_registered(1) = '1' then
                                    lift1_from_rh(1) <= '1';
                                    down_request_registered(1) <= '0';
                                end if;
                              elsif lift1_current_floor = "01" and lift2_current_floor = "11" then
                                if down_request_registered(2) = '1' then
                                    lift2_from_rh(2) <= '1';
                                    down_request_registered(2) <= '0';
                                elsif down_request_registered(1) = '1' then
                                    lift2_from_rh(1) <= '1';
                                    down_request_registered(1) <= '0';
                                end if;
                              elsif lift1_current_floor = "01" and lift2_current_floor = "10" then
                                if down_request_registered(1) = '1' then
                                    lift2_from_rh(1) <= '1';
                                    down_request_registered(1) <= '0';
                                end if;
                              end if;    
              elsif lift1_state = "00" then             
                              if lift1_current_floor = "00" then
                                  if up_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif up_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';         
                                  elsif down_request_registered(3) = '1' then
                                       lift1_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  end if;
  
                                elsif lift1_current_floor = "01" then
                                  if up_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';         
                                  elsif down_request_registered(3) = '1' then
                                       lift1_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif up_request_registered(0) = '1' then
                                       lift1_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  end if;
  
                                elsif lift1_current_floor = "10" then
                                  if down_request_registered(3) = '1' then
                                       lift1_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif up_request_registered(0) = '1' then
                                       lift1_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  elsif up_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  end if;
                                
                                elsif lift1_current_floor = "11" then
                                  if up_request_registered(0) = '1' then
                                       lift1_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  elsif up_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif up_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift1_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift1_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  elsif down_request_registered(0) = '1' then
                                       lift1_from_rh(0) <= '1';
                                       down_request_registered(0) <= '0';
                                  end if;
                                end if;     
              elsif lift2_state = "00" then             
                              if lift2_current_floor = "00" then
                                  if up_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif up_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';         
                                  elsif down_request_registered(3) = '1' then
                                       lift2_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  end if;
                
                                elsif lift2_current_floor = "01" then
                                  if up_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';         
                                  elsif down_request_registered(3) = '1' then
                                       lift2_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif up_request_registered(0) = '1' then
                                       lift2_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  end if;
                
                                elsif lift2_current_floor = "10" then
                                  if down_request_registered(3) = '1' then
                                       lift2_from_rh(3) <= '1';
                                       down_request_registered(3) <= '0';
                                  elsif up_request_registered(0) = '1' then
                                       lift2_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  elsif up_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  end if;
                                
                                elsif lift2_current_floor = "11" then
                                  if up_request_registered(0) = '1' then
                                       lift2_from_rh(0) <= '1';
                                       up_request_registered(0) <= '0';
                                  elsif up_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       up_request_registered(1) <= '0';
                                  elsif up_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       up_request_registered(2) <= '0';
                                  elsif down_request_registered(2) = '1' then
                                       lift2_from_rh(2) <= '1';
                                       down_request_registered(2) <= '0';
                                  elsif down_request_registered(1) = '1' then
                                       lift2_from_rh(1) <= '1';
                                       down_request_registered(1) <= '0';
                                  elsif down_request_registered(0) = '1' then
                                       lift2_from_rh(0) <= '1';
                                       down_request_registered(0) <= '0';
                                  end if;
                                end if;   
              end if;        
    end if;
    
    
end if;


end process;


end request_handler;

----------------------------------------------------------------------------------

--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity lab8_elevator_control is
Port (  up_request :        in std_logic_vector(3 downto 0);
        down_request :      in std_logic_vector(3 downto 0);
        reset :             in std_logic;
        door_open :         in std_logic_vector(1 downto 0);
        door_closed :       in std_logic_vector(1 downto 0);
        clk :               in std_logic;
        lift1_floor :       in std_logic_vector(3 downto 0);
        lift2_floor :       in std_logic_vector(3 downto 0);
        --sim_mode :          in std_logic;
        lift1_floor_indicator :     out std_logic_vector(3 downto 0);
        lift2_floor_indicator :     out std_logic_vector(3 downto 0);
        cathode :                   out std_logic_vector(6 downto 0);
        anode :                     out std_logic_vector(3 downto 0);
        up_request_indicator :      out std_logic_vector(3 downto 0);
        down_request_indicator :    out std_logic_vector(3 downto 0)
);
end lab8_elevator_control;

architecture Behavioral of lab8_elevator_control is


component lift1_controller is
Port(
    lift1_floor :       in std_logic_vector(3 downto 0);
    lift1_from_rh :     in std_logic_vector (3 downto 0);
    reset :             in std_logic;
    door_open :         in std_logic_vector(1 downto 0);
    door_closed :       in std_logic_vector(1 downto 0);
    clk :               in std_logic;
    up_request_in     : in std_logic_vector(3 downto 0);
    down_request_in   : in std_logic_vector(3 downto 0);
    up_request_out    : out std_logic_vector(3 downto 0);
    down_request_out  : out std_logic_vector(3 downto 0);
    lift1_floor_indicator :  out std_logic_vector(3 downto 0);
    lift1_current_floor  : out std_logic_vector(1 downto 0);
    lift1_state          : out std_logic_vector(1 downto 0);  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift1_status :         out std_logic_vector(1 downto 0);  --00 when moving up--  --01 when moving down--
                                                                 --10 when halted with door open-- --11 when halted with door closed--
    lift_from_rh_out    :  out std_logic_vector(3 downto 0)
);
end component;

component lift2_controller is
Port(
    lift2_floor :       in std_logic_vector(3 downto 0);
    lift2_from_rh :     in std_logic_vector (3 downto 0);
    reset :             in std_logic;
    door_open :         in std_logic_vector(1 downto 0);
    door_closed :       in std_logic_vector(1 downto 0);
    clk :               in std_logic;
    up_request_in     : in std_logic_vector(3 downto 0);
    down_request_in   : in std_logic_vector(3 downto 0);
    up_request_out    : out std_logic_vector(3 downto 0);
    down_request_out  : out std_logic_vector(3 downto 0);
    lift2_floor_indicator :  out std_logic_vector(3 downto 0);
    lift2_current_floor  : out std_logic_vector(1 downto 0);
    lift2_state          : out std_logic_vector(1 downto 0);  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift2_status :         out std_logic_vector(1 downto 0);  --00 when moving up--  --01 when moving down--
                                                                 --10 when halted with door open-- --11 when halted with door closed--
    lift_from_rh_out    :  out std_logic_vector(3 downto 0)
);
end component;

component request_handler is
Port(
--    lift1_status :         in std_logic_vector(2 downto 0);
--    lift2_status :         in std_logic_vector(2 downto 0);
    lift1_current_floor  : in std_logic_vector(1 downto 0);
    lift2_current_floor  : in std_logic_vector(1 downto 0);
    lift1_state          : in std_logic_vector(1 downto 0);  -- idle = 00 and requp = 01 and reqdown = 10
    lift2_state          : in std_logic_vector(1 downto 0);
    up_request   :         in std_logic_vector(3 downto 0);  -- up request recieved from some floor
    down_request :         in std_logic_vector(3 downto 0);  -- down request recieved from some floor
    reset :             in std_logic;
    clk :               in std_logic;
    lift1_from_rh : out std_logic_vector (3 downto 0); -- when idle it sends floor number to lift 1 to goto
    lift2_from_rh : out std_logic_vector (3 downto 0) -- when idle it sends floor number to lift 2 to goto
    
    
);
end component;

component anode1 is
    Port ( clock : in  STD_LOGIC;
           anodeout : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

component ssd is
Port ( bcdin : in STD_LOGIC_VECTOR (3 downto 0);
sevensegment : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component clkdiv is 
    port( pushbutton : in std_logic;
          clock1 : in std_logic;
          out_clock : out std_logic
        );
end component;


signal lift1_state, lift2_state : std_logic_vector(1 downto 0);
signal lift1_status,lift2_status : std_logic_vector(1 downto 0);
signal lift1_from_rh,lift2_from_rh : std_logic_vector(3 downto 0);
signal lift1_current_floor,lift2_current_floor : std_logic_vector(1 downto 0);
signal up_request_lift1,up_request_lift2, down_request_lift1,down_request_lift2, up_request_level, down_request_level : std_logic_vector(3 downto 0);
signal cathode_temp : std_logic_vector(6 downto 0) := "1111111";
signal anode_temp, print_num : std_logic_vector(3 downto 0);
signal clock_to_be_used : std_logic;
signal sim_mode :          std_logic;
signal lift1_from_rh_out, lift2_from_rh_out : std_logic_vector(3 downto 0);
signal up_request_indicator_temp, down_request_indicator_temp : std_logic_vector(3 downto 0) := "0000";
begin


process(clk)
begin
    if reset = '1' then 
        up_request_indicator <= "0000";
    else   
    if up_request(0) = '1' and (lift1_from_rh(0) = '1' OR lift2_from_rh(0) = '1') then
        up_request_indicator(0) <= '1';
    end if;
    if up_request(1) = '1' and (lift1_from_rh(1) = '1' OR lift2_from_rh(1) = '1') then
        up_request_indicator(1) <= '1';
    end if;
    if up_request(2) = '1' and (lift1_from_rh(2) = '1' OR lift2_from_rh(2) = '1') then
        up_request_indicator(2) <= '1';
    end if;
    if up_request(3) = '1' and (lift1_from_rh(3) = '1' OR lift2_from_rh(3) = '1') then
        up_request_indicator(3) <= '0';
    end if;
    
    if Rising_edge(clk) then
        if (lift1_from_rh_out(to_integer(unsigned(lift1_current_floor))) = '1') then
            up_request_indicator(to_integer(unsigned(lift1_current_floor))) <= '0';    
        end if;
    end if;
    
    if Rising_edge(clk) then
        if (lift2_from_rh_out(to_integer(unsigned(lift2_current_floor))) = '1') then
            up_request_indicator(to_integer(unsigned(lift2_current_floor))) <= '0';    
        end if;
    end if;
    end if;
end process;

process(clk,reset)
begin
    if reset = '1' then 
        down_request_indicator <= "0000";
    else
    if down_request(0) = '1' and (lift1_from_rh(0) = '1' OR lift2_from_rh(0) = '1') then
        down_request_indicator(0) <= '0';
    end if;
    if down_request(1) = '1' and (lift1_from_rh(1) = '1' OR lift2_from_rh(1) = '1') then
        down_request_indicator(1) <= '1';
    end if;
    if down_request(2) = '1' and (lift1_from_rh(2) = '1' OR lift2_from_rh(2) = '1') then
        down_request_indicator(2) <= '1';
    end if;
    if down_request(3) = '1' and (lift1_from_rh(3) = '1' OR lift2_from_rh(3) = '1') then
        down_request_indicator(3) <= '1';
    end if;
    
    if Rising_edge(clk) then
        if (lift1_from_rh_out(to_integer(unsigned(lift1_current_floor))) = '1') then
            down_request_indicator(to_integer(unsigned(lift1_current_floor))) <= '0';    
        end if;
    end if;
    
    if Rising_edge(clk) then
        if (lift2_from_rh_out(to_integer(unsigned(lift2_current_floor))) = '1') then
            down_request_indicator(to_integer(unsigned(lift2_current_floor))) <= '0';    
        end if;
    end if;
    end if;
end process;


lift1: lift1_controller port map(
    lift1_floor =>        lift1_floor,
    lift1_from_rh =>      lift1_from_rh,
    reset  =>           reset,
    door_open =>         door_open,
    door_closed =>       door_closed,
    clk =>               clk,
    up_request_in     =>  up_request_level,
    down_request_in   => down_request_level,
    up_request_out    => up_request_lift1,
    down_request_out  => down_request_lift1,
    lift1_floor_indicator => lift1_floor_indicator,
    lift1_current_floor  => lift1_current_floor,
    lift1_state          => lift1_state,  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift1_status =>    lift1_status,
    lift_from_rh_out  => lift1_from_rh_out
); 

lift2: lift2_controller port map(
    lift2_floor =>        lift2_floor,
    lift2_from_rh =>      lift2_from_rh,
    reset  =>           reset,
    door_open =>         door_open,
    door_closed =>       door_closed,
    clk =>               clk,
    up_request_in     =>  up_request_level,
    down_request_in   => down_request_level,
    up_request_out    => up_request_lift2,
    down_request_out  => down_request_lift2,
    lift2_floor_indicator => lift2_floor_indicator,
    lift2_current_floor  => lift2_current_floor,
    lift2_state          => lift2_state,  --of type idle,reqUp,reqDown type----------- idle = 00 and requp = 01 and reqdown = 10
    lift2_status =>    lift2_status,
    lift_from_rh_out => lift2_from_rh_out
); 

rq:  request_handler port map(
    lift1_current_floor  => lift1_current_floor,
    lift2_current_floor  => lift2_current_floor,
    lift1_state          => lift1_state,
    lift2_state          =>  lift2_state,
    up_request              =>  up_request,
    down_request         => down_request,
    reset                   => reset,
    clk                    => clk,
    lift1_from_rh         =>  lift1_from_rh,
    lift2_from_rh         =>  lift2_from_rh
);
                             
                                          
LK_TO_BE_USED: clkdiv port map(	pushbutton => sim_mode,
                                  clock1 => clk,
                                  out_clock => clock_to_be_used);
                                  
ODE: anode1 Port map ( 
        clock => clock_to_be_used,
        anodeout => anode_temp
        );

sim_mode <= '0';
anode <= anode_temp;                               
cathode <= cathode_temp; 

SS: ssd Port map ( bcdin => print_num,
                    sevensegment => cathode_temp);                       
                                                          
process(lift1_status, lift1_current_floor, lift2_status, lift2_current_floor, anode_temp)
begin 

if(anode_temp(3) = '0') then
  print_num <= "01" & lift1_status(1 downto 0);
  
  elsif (anode_temp(2) = '0') then
  print_num <= "00" & lift1_current_floor(1 downto 0);
  
  elsif(anode_temp(1) = '0') then
  print_num <= "01" & lift2_status(1 downto 0);
      
  elsif(anode_temp(0) = '0') then
  print_num <= "00" & lift2_current_floor(1 downto 0);
end if;
end process;


end Behavioral;