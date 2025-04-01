----------------------------------------------------------------------------------
-- Company: Digilent RO
-- Engineer: Mircea Dabacan
-- 
-- Create Date: 12/04/2014 07:52:33 PM
-- Design Name: Audio Spectral Demo 
-- Module Name: ImgCtrl - Behavioral
-- Project Name: TopNexys4Spectral 
-- Target Devices: Nexys 4, Nexys 4 DDR
-- Tool Versions: Vivado 14.2
-- Description: The module:
--  performs three concurent loops:
--   acquisition  loops:
--     stores 1024 samples at 48KSPS in TimeBlkMemForFft, indexed by intAddraTime 
--     (synchronized with the FftBlock)
--   FFT unload loop:
--     unloads time samples from the fft core
--     (synchronized by the  FftBlock)
--   display loop
--     displays the time samples and the frequency samples on the VGA display 
--     ( synchronized by the VGA ctrl)
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

use work.DisplayDefinition.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ImgCtrl is
    Port ( ck100MHz : in STD_LOGIC;
     -- frequency domain data signals
--            enaFreq : in STD_LOGIC;
           weaFreq : in STD_LOGIC;
           addraFreq : in STD_LOGIC_VECTOR (13 downto 0);  -- LZQ: 9:0 -> 13:0
           dinaFreq : in STD_LOGIC_VECTOR (7 downto 0);
     -- video signals
           ckVideo : in STD_LOGIC;
           flgActiveVideo: in std_logic;  -- active video flag
           adrHor: in integer range 0 to cstHorSize - 1; -- pixel counter
           adrVer: in integer range 0 to cstVerSize - 1; -- lines counter
		   red : out  STD_LOGIC_VECTOR (3 downto 0);
           green : out  STD_LOGIC_VECTOR (3 downto 0);
           blue : out  STD_LOGIC_VECTOR (3 downto 0));
end ImgCtrl;

architecture Behavioral of ImgCtrl is

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0); -- LZQ: 9:0 -> 13:0
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(13 DOWNTO 0); -- LZQ: 9:0 -> 13:0
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

COMPONENT blk_mem_title  -- LZQ
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END COMPONENT;
--ATTRIBUTE SYN_BLACK_BOX : BOOLEAN;
--ATTRIBUTE SYN_BLACK_BOX OF blk_mem_gen_0 : COMPONENT IS TRUE;
--ATTRIBUTE BLACK_BOX_PAD_PIN : STRING;
--ATTRIBUTE BLACK_BOX_PAD_PIN OF blk_mem_gen_0 : COMPONENT IS "clka,ena,wea[0:0],addra[9:0],dina[7:0],clkb,enb,addrb[9:0],doutb[7:0]";

-- COMP_TAG_END ------ End COMPONENT Declaration ------------

  --signal sampleDisplayTime: STD_LOGIC_VECTOR (7 downto 0);  -- time domain sample for display
  signal sampleDisplayFreq: STD_LOGIC_VECTOR (7 downto 0);  -- freq domain sample for display

  signal vecadrHor: std_logic_vector(13 downto 0); -- pixel counter (vector) -- LZQ: 9:0 -> 13:0
  signal vecadrVer: std_logic_vector(13 downto 0); -- lines counter (vector) -- LZQ: 9:0 -> 13:0

  signal intRed: STD_LOGIC_VECTOR (3 downto 0); 
  signal intGreen: STD_LOGIC_VECTOR (3 downto 0); 
  signal intBlue: STD_LOGIC_VECTOR (3 downto 0); 
  
  signal titleRed: STD_LOGIC_VECTOR (3 downto 0); 
  signal titleGreen: STD_LOGIC_VECTOR (3 downto 0); 
  signal titleBlue: STD_LOGIC_VECTOR (3 downto 0); 
  
  signal titleDout: STD_LOGIC_VECTOR (3 downto 0); 
  
  signal noteRed: STD_LOGIC_VECTOR (3 downto 0); 
  signal noteGreen: STD_LOGIC_VECTOR (3 downto 0); 
  signal noteBlue: STD_LOGIC_VECTOR (3 downto 0); 
  
  signal addrbFreq : std_logic_vector(13 downto 0); -- LZQ
  signal addraTitle: std_logic_vector(10 downto 0);  -- LZQ
begin

   vecadrHor <= conv_std_logic_vector(0, 14) when adrHor = cstHorSize - 1 else -- LZQ: 10->14
                conv_std_logic_vector(adrHor + 1, 14);  -- read in advance for compensating the synchronous BRAM delay 
   vecadrVer <= conv_std_logic_vector(adrVer, 14);

   addrbFreq <= "00000" & vecadrHor(10 downto 2)
                when (vecadrHor(10 downto 2) < 128)
                else (others => '1'); -- LZQ -- divide by 8. Display 640/8 = 80 points. Point = 96Khz/512 = 187.5Hz -- LZQ: 10->13 Display 640/4 = 160
------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
FreqBlkMemForDisplay: blk_mem_gen_0
  PORT MAP (
    clka => ck100MHz,
    ena => '1', -- always active 
    wea(0) => weaFreq,  -- wea is std_logic_vector(0 downto 0) ...
    addra => addraFreq,
    dina =>dinaFreq, -- selected byte!!!

    clkb => ckVideo,  -- Video clock 
    enb => '1',
    addrb => addrbFreq,
    --addrb => vecadrHor,
    doutb => sampleDisplayFreq
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------
addraTitle <= vecadrVer(5 downto 2) & vecadrHor(8 downto 2)
         when (vecadrVer < 64 and vecadrHor < 512)
         else (others => '0');         
   
TitleBlkMemForDisplay: blk_mem_title
  PORT MAP (
    clka => ckVideo,
    ena => '1',
    addra => addraTitle,
    douta => titleDout
  );

  intRed <= "0000";
  intGreen <= "1111" when --adrVer >= cstVerAf/2 and 
                         adrVer >= cstVerAf*47/48 - conv_integer("0" & sampleDisplayFreq(7) & sampleDisplayFreq(6 downto 0)) and adrHor < 512 else "0000";
  intBlue <= "1111" when --adrVer >= cstVerAf/2 and 
                -- frequency range (lower half of the VGA display)
                adrVer >= cstVerAf*47/48 - conv_integer("0" & sampleDisplayFreq(7) & sampleDisplayFreq(6 downto 0)) and adrHor < 512 and 
                -- a frequency marker every note from C3 to A4
                (adrHor/4 = 20 or adrHor/4 = 23 or adrHor/4 = 26 or adrHor/4 = 29 or adrHor/4 = 32 or adrHor/4 = 35 or adrHor/4 = 39 or adrHor/4 = 42 or
                adrHor/4 = 47 or adrHor/4 = 51 or adrHor/4 = 55 or adrHor/4 = 60 or adrHor/4 = 65 or adrHor/4 = 71 or adrHor/4 = 76 or adrHor/4 = 82 or
                adrHor/4 =88 or adrHor/4 = 95 or adrHor/4 = 102 or adrHor/4 = 110 or adrHor/4 = 118 or adrHor/4 = 128) else "0000" ;

  titleRed <= titleDout;
  titleGreen <= titleDout;
  titleBlue <= titleDout;
                     
  red   <= "1111" when (intRed = "1111" or titleRed = "1111") and flgActiveVideo = '1' else "0000";
  green <= "1111" when (intGreen = "1111" or titleGreen = "1111") and flgActiveVideo = '1' else "0000";
  blue  <= "1111" when (intBlue = "1111" or titleBlue = "1111") and flgActiveVideo = '1' else "0000";

end Behavioral;