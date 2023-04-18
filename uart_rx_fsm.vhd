-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Milan Jakubec (xjakub41)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       CNT : in std_logic_vector(4 downto 0); -- na pocitani hodinovych signalu, nejvic potrebuju pocitat do 24, takze 4 downto 0
       CNTBIT : in std_logic_vector(3 downto 0); -- na pocitani zachycenych bitu, nejvic potrebuju pocitat do 8, takze 3 downto 0
       DIN : in std_logic;
       DOUT_VLD : out std_logic

    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_types is (AWAITING_START, STARTED, RECIEVING, AWAITING_STOP, VALID)
    signal state_crrt : state_types := AWAITING_START;
begin

    process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                state_crrt <= AWAITING_START;
            else
                case state is
                    when AWAITING_START =>
                        if DIN = '0' then 
                            state_crrt <= STARTED;
                        end if;
                    
                    when STARTED =>

                        if CNT = "1000" then -- na osmym cyklu
                            --Zkontroluj start bit
                            if DIN = '1' then
                                state_crrt => AWAITING_START;
                            end if;
                        end if;

                        if CNT = "11000" then
                            state_crrt <= RECIEVING;
                        end if;

                    when RECIEVING =>
                            if CNTBIT = "1000" then
                                state_crrt <= AWAITING_STOP;
                            end if;

                    when AWAITING_STOP =>
                            if CNT = "10000"


                        
                                


            


end architecture;
