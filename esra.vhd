-- 365273 Esra Alkasan 
-- Donanim Tanimlama Dilleri Proje Odevi
-- Islemci Tasarimi

library ieee;
use ieee.std_logic_1164.all;
use IEEE.Numeric_Std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity eIslemci is
generic(n:natural:=8);
port( s, r,secme,oku : in std_logic;  --Reset
         adr: in std_logic_vector (3 downto 0);
         kmt: in std_logic_vector(2*n-1 downto 0) ;-- 16 bit giris secme
         F: out std_logic_vector(7 downto 0)
      ); --cikis 
end entity;

Architecture struct of eIslemci is

TYPE tMEM IS ARRAY(0 TO 63) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Ram : tMEM;  -- RAM

TYPE tREG IS ARRAY(0 TO 15) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Reg : tREG;

TYPE tROM IS ARRAY(0 TO 31) OF std_logic_vector(n-1 DOWNTO 0);
SIGNAL Rom : tROM;
Constant ROMbellek: tROM :=(
      0 => "01000001",	
	    1 => "01000010",
      2 =>	"01000011"	,
      3	=> "01000100"	,
      4	=> "01000101"	,
      5	=> "01000110"	,
      6	=> "01000111"	,
      7	=> "01001000"	,
      8	=> "01001001"	,
      9	=> "01001010"	,
      10 => "01001011"	,
      11 => "01001100",
      12 => "01001101"	,
      13 => "01001110"	,
      14 => "01001111"	,
      15 => "01010000",
      16 => "01010001"	,
      17 => "01010010"	,
      18 => "01010011"	,
      19 => "01010100"	,
      20 => "01010101"	,
      21 => "01010110"	,
      22 => "01010111"	,
      23 => "01011000"	,
      24 => "01011001"	,
      25 => "01011010",
      OTHERS => "11111111" );

Begin -- mimari
 
Komut:
process(s, r)
Begin
     
  If( Rising_edge(s) ) then 
    If(r='1') then
      If(secme='1')then
       F <= ROMbellek(to_integer(unsigned(adr)));
       -- Ram(to_integer(unsigned(Kmt(7 downto 0)))) <= "ZZZZZZZZ";
      Else 
        Reg(to_integer(unsigned(Kmt(11 downto 0)))) <= "ZZZZZZZZ";
      End if;
    End if;
  Else
     Case Kmt(15 downto 12) is -- en anlamli 4 bit
     
	When "0000" =>
	    null;   -- islem yok... 

	-- loadx     0001  4bitREGadresi   8bit sabit sayi
	When "0001" =>
		Reg(to_integer(unsigned(Kmt(11 downto 8)))) <= Kmt(7 downto 0);  

	-- loadr     0010  4bitREGadresi   4bitREGadresiKaynak         Loadr  ax, bx    -- ax<=bx
	When "0010" =>  
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= Reg(  to_integer(unsigned(Kmt(7 downto 4)) ))  ;

	When "0011" =>  -- loadm     0001  REGadresi   8bitRamAdresi 
		Ram(  to_integer(unsigned(Kmt(7 downto 0))))  <= Reg(  to_integer(unsigned(Kmt(11 downto 8)) ))  ;

	
	When "0100" =>  -- loadmr     0101  REGadresi   RegAdresi 
		Reg(  to_integer(unsigned(Kmt(11 downto 8))))  <= 
			Ram( to_integer(unsigned( Reg( to_integer(unsigned(Kmt(7 downto 4)))  ))))  ;

	-- Storer    0101  REGadresi   8bitRamAdresi
	-- Registerda olan bilgi BEllege yazilir
 	When "0101" =>  
           Ram( to_integer(unsigned(Kmt(7 downto 0))) ) <= 
			Reg( to_integer(unsigned(Kmt(11 downto 8))));
	
	-- ADDx    0110  4bitRegAdresi     8bit sabit Sayi 	
	-- add  ax,  x     x sabit sayi ile ax toplanir sonuc ax'e yazilir
 	When "0110" =>  
           Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <= 
				std_logic_vector( 
					unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))
					 + unsigned(Kmt (7 downto 0)));
	
	-- ADDr:    0111  4bitRegAdresi     4bitRegAdresi   	
	-- addr     ax,  bx , cx      Romdaki cx  ve  bx toplanir sonuc ax'e yaz?l?r
 	When "0111" =>  
           Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			+ unsigned(ROMbellek( to_integer(unsigned(Kmt(3 downto 0)))))  );
 
	-- Diger islemler buraya eklenecek...
	-- aritmetik ve mantiksal islemler...

 
  --SUBx      1000  4bitRegAdresi     8bitSabitSayi
  --sub ax, x      ax 'den x sabit sayisi çikartilir ve sonuc ax'e yazilir.
  When "1000" =>
        Reg(  to_integer(unsigned(Kmt(11 downto 8))) )   <= 
				std_logic_vector(unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8)))))
					 - unsigned(Kmt (7 downto 0)));
   
  --SUBr :   1001     4bitRegAdresi     4bitRegAdresi 
  -- subr ax,bx,cx  bx yazmacindaki deger ROMdaki cx degeri kadar eksilir sonuc ax'e yaz?l?r
  When "1001" =>
         Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			- unsigned(ROMbellek( to_integer(unsigned(Kmt(3 downto 0)))))  );
			
	--DIV ax x        ax x'e bölünür. sonuc ax'e yazilir.
  When "1010" =>
    Ram( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4))))) 
			/ unsigned(Kmt(7 downto 0)));  		
			
	--MUL ax,bx,cx    bx ve cx carpilir sonuc ax'e yazilir
  When "1011" =>
    Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			* unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0)))))  );	
			
  --MOD ax x    ax in x e göre modu alinir sonuc ax e yazilir.
  When "1100" =>
    Ram( to_integer(unsigned(Kmt(7 downto 0)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(11 downto 8))))) 
			mod unsigned(Kmt(3 downto 0))); 
			
			
	-- OR ax,x         ax ile x OR'lanir sonuc ax'e yazilir.
  When "1101" =>
         Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4))))) 
			OR unsigned(ROMbellek( to_integer(unsigned(Kmt(3 downto 0)))))  );
			
			
		-- XOR ax,bx,cx    cx ve bx xor'lanir sonuc ax'e yazilir.		  
  When "1110" =>
    Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			XOR unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0)))))  );		
			
						
	 -- AND ax,bx,cx     cx ve bx and'lenir sonuc ax'e yazilir  
  When "1111" => 
        Reg( to_integer(unsigned(Kmt(11 downto 8)) ))   <= 
			std_logic_vector( unsigned(Reg( to_integer(unsigned(Kmt(7 downto 4)))))   
			AND unsigned(Reg( to_integer(unsigned(Kmt(3 downto 0)))))  );			
			

 	When others => 
	    null;
      end case; 
   end if;
end Process;

end struct;
