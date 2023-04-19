-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Milan Jakubec (xjakub41)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;



-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic; 
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal cntclk       : std_logic_vector(4 downto 0) := "00000";
    signal cntbit       : std_logic_vector(3 downto 0) := "0000";
    signal vld          : std_logic;
    signal read_en      : std_logic;
    signal cnt_en       : std_logic;
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK => CLK,
        RST => RST,
        DIN => DIN,
        CNTCLK => cntclk,
        CNTBIT => cntbit(0011), -- jenom LSB me zajima, jestli je tam 1000 nebo ne
        ------------
        DOUT_VLD => vld,
        READ_EN => read_en,
        CNT_EN => cnt_en
    );

    DOUT <= (others => '0');
    DOUT_VLD <= vld;


    process(CLK) begin
        if rising_edge(CLK) then
            if RST = '1' then
                cntclk <= "00000";
                cntbit <= "0000";
            else
                if cnt_en = '1' then
                    cntclk <= cntclk + 1;
                elsif cnt_en = '0' then
                    cntclk <= "00000";
                end if;

                if read_en = '1' and (cntclk(4) = '1') then

                    cntclk <= "00001";
                    case cntbit is
                        when "0000" => DOUT(0) <= DIN;
                        when "0001" => DOUT(1) <= DIN;
                        when "0010" => DOUT(2) <= DIN;
                        when "0011" => DOUT(3) <= DIN;
                        when "0100" => DOUT(4) <= DIN;
                        when "0101" => DOUT(5) <= DIN;
                        when "0110" => DOUT(6) <= DIN;
                        when "0111" => DOUT(7) <= DIN;
                        when others => null;
                    end case;
                    cntbit <= cntbit + 1;

                elsif read_en = '0' then
                    cntbit <= "0000";
                end if;

            end if;
        end if;
    end process;

end architecture;
