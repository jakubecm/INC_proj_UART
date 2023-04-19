-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Milan Jakubec (xjakub41)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
       -----------Inputy-----------
       CLK      : in std_logic; -- hodinovy signal
       RST      : in std_logic; -- reset
       CNTCLK      : in std_logic_vector(4 downto 0); -- na pocitani hodinovych signalu, nejvic potrebuju pocitat do 24, takze 4 downto 0
       CNTBIT   : in std_logic_vector(3 downto 0); -- na pocitani zachycenych bitu, nejvic potrebuju pocitat do 8, takze 3 downto 0
       DIN      : in std_logic; -- datova linka
       -----------Outputy-----------
       DOUT_VLD : out std_logic
       READ_EN  : out std_logic;
       CNT_EN   : out std_logic
       -----------------------------
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_types is (AWAITING_START, STARTED, RECIEVING, AWAITING_STOP, VALID)
    signal state_crrt : state_types := AWAITING_START;
begin
    -----------------Moorovy vystupy-----------------
    READ_EN <= '1' when state_crrt = RECIEVING else '0'; -- pokud je v stavu RECIEVING, povol cteni bitu
    CNT_EN <= '1' when state_crrt = RECIEVING or state_crrt = STARTED else '0'; -- pokud je v stavu RECIEVING nebo STARTED, povol pocitani bitu
    DOUT_VLD <= '1' when state_crrt = VALID else '0'; -- pokud je v stavu VALID, nastav vystup na 1
    --------------------------------------------------
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

                        if CNTCLK = "1000" then -- na osmym clocku hodinoveho signalu
                            --Zkontroluj start bit--
                            if DIN = '1' then
                                state_crrt => AWAITING_START; --start bit je spatne, vrat se do stavu AWAITING_START
                            end if;

                        elsif CNTCLK = "11000" then -- na 24. clocku hodinoveho signalu zacni cist data (je to midbit prvniho cteneho bitu)
                            state_crrt <= RECIEVING;
                        end if;

                    when RECIEVING =>
                            if CNTBIT = "1000" then -- jestli pocitadlo bitu uz je na osmi, ocekavej stop bit
                                state_crrt <= AWAITING_STOP;
                            end if;

                    when AWAITING_STOP =>
                            if DIN = '1' then
                                state_crrt <= VALID; -- stop bit je v poradku, prejdi se do stavu VALID
                            end if;
                    
                    when VALID => state_crrt <= AWAITING_START; -- vrat se do stavu AWAITING_START a cekej na dalsi start bit
                end case;
            end if;
        end if;
    end process


                        
end architecture;
