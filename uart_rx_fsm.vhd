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
       DIN      : in std_logic; -- datova linka
       CNTCLK   : in std_logic_vector(4 downto 0); -- na pocitani hodinovych signalu, nejvic potrebuju pocitat do 24, takze 4 downto 0
       CNTBIT   : in std_logic_vector(3 downto 0); -- na pocitani zachycenych bitu, nejvic potrebuju pocitat do 8, takze 3 downto 0
       -----------Outputy-----------
       OUT_VLD : out std_logic; -- validacni signal
       READ_EN  : out std_logic; -- povoleni cteni bitu
       CNT_EN   : out std_logic -- povoleni pocitani hodinovych signalu
       -----------------------------
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type state_types is (AWAITING_START, STARTED, RECIEVING, AWAITING_STOP, VALID);
    signal state_crrt : state_types := AWAITING_START;
begin
    -----------------Moorovy vystupy-----------------
    READ_EN <= '1' when state_crrt = RECIEVING else '0'; -- pokud je v stavu RECIEVING, povol cteni bitu
    CNT_EN <= '1' when state_crrt = RECIEVING or state_crrt = STARTED or state_crrt = AWAITING_STOP else '0'; -- pokud je v stavu RECIEVING/STARTED/AWAITING_STOP, povol pocitani hodinovych signalu
    OUT_VLD <= '1' when state_crrt = VALID else '0'; -- pokud je v stavu VALID, nastav vystup na 1
    --------------------------------------------------
    process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                state_crrt <= AWAITING_START;
            else
                case state_crrt is
                    when AWAITING_START =>
                        if DIN = '0' then 
                            state_crrt <= STARTED;
                        end if;
                    
                    when STARTED =>

                        if CNTCLK = "01000" then -- na osmym clocku hodinoveho signalu
                            --Zkontroluj start bit--
                            if DIN = '1' then
                                state_crrt <= AWAITING_START; --start bit je spatne, vrat se do stavu AWAITING_START
                            end if;

                        elsif CNTCLK = "10110" then -- na 22. clocku hodinoveho signalu zacni cist data (je to midbit prvniho cteneho bitu)
                            state_crrt <= RECIEVING; -- spravne bych mel cist na 24. ale zohlednuji zpozdeni
                        end if;

                    when RECIEVING =>
                            if CNTBIT = "1000" then -- jestli pocitadlo bitu uz je na osmi, ocekavej stop bit
                                state_crrt <= AWAITING_STOP;
                            end if;

                    when AWAITING_STOP =>
                            if DIN = '1' and CNTCLK = "10000" then
                                state_crrt <= VALID; -- stop bit je v poradku, prejdi do stavu VALID
                            end if;
                    
                    when VALID => state_crrt <= AWAITING_START; -- vrat se do stavu AWAITING_START a cekej na dalsi start bit
                end case;
            end if;
        end if;
    end process;


                        
end architecture;
