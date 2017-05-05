-- author: R.D. Beyers
-- updated on 19/04/2017
-- STELLENBOSCH UNIVERSITY

-- TODO: COMPLETE THE ARCHITECTURE OF THIS ENTITY

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY CONTROLLER_FSM IS
	PORT
		(
			JUMP_COND			:	IN STD_LOGIC; -- attached to LSB of D_BUS and used as condition for coniditional jump
			COMP_EN				:	OUT STD_LOGIC; -- enable/disable comparator component
			COMP_OE				:	OUT STD_LOGIC; -- enable/disable outputs of comparator on the shared data bus
			COMP_SEL			:	OUT STD_LOGIC; -- select which byte will be loaded into the comparator 
			SPEC_REG_WR_N		:	OUT STD_LOGIC; -- special register not write enable
			SPEC_REG_RE_N		:	OUT STD_LOGIC; -- special register not read enable
			ARITH_EN			:	OUT STD_LOGIC; -- enable/disable adder component
			ARITH_OE			:	OUT STD_LOGIC; -- enable/disable outputs of the adder on the shared data bus
			ARITH_SEL			:	OUT STD_LOGIC; -- select which byte will be loaded into the adder 
			RESET_N				:	IN STD_LOGIC; -- reset input (connected to button(0))
			RESET_INSTR_NUMBER	:	OUT STD_LOGIC; -- reset instruction number to "00000000"
			SET_INSTR_NUMBER	:	OUT STD_LOGIC; -- set instruction number to whatever is on the data bus
			INSTR				:	IN 	STD_LOGIC_VECTOR(3 DOWNTO 0); -- the current instruction
			INSTR_EN			:	OUT STD_LOGIC; -- enable/disable the instruction reader component
			INSTR_OE			:	OUT STD_LOGIC; -- enable/disable the outputs (instruction byte 2) on the shared data bus
			SEL_ADDR			:	OUT STD_LOGIC; -- select the address source for WR_ADDR of the register bank
			REG_CPY_N			:	OUT STD_LOGIC; -- select copy/output mode of the register
			REG_WR_N			:	OUT	STD_LOGIC; -- enable/disable register writing
			REG_RE_N			:	OUT	STD_LOGIC; -- enable/disable register reading
			REG_PR_N			:	OUT	STD_LOGIC; -- preset all register bits to '1'
			REG_CL_N			:	OUT STD_LOGIC; -- clear all register bits to '0'
			DISP_EN				:	OUT STD_LOGIC; -- enable/disable the 7-segment display unit
			DISP_BYTE_SELECT	:	OUT	STD_LOGIC; -- select which 7-segment pair to display on
			DISP_PWR			:	OUT	STD_LOGIC; -- power the display unit on/off			
			INCR_INSTR_NUMBER_NE:	OUT	STD_LOGIC; -- increment the current instruction number (active on negative edge)			
			CLK_IN				:	IN STD_LOGIC -- clock input (use cpu clock)
		);
END CONTROLLER_FSM;

ARCHITECTURE STRUCTURE OF CONTROLLER_FSM IS
-- YOUR CODE GOES HERE
TYPE state IS (RS, RD, WR, CP, DE, NO, JU);
SIGNAL currstate : state := RS;
BEGIN
-- AND HERE
-- The CONTROLLER_FSM receives the op code in INSTR(3 DOWNTO <= '0';), which is the upper nibble of INSTR_BYTE1.
-- By setting REG_WR_N = ‘0’, the REGISTER_BANK will write the data from D_BUS (xxxx xxxx) into the register at REG_WR_ADDR (aaaa).

-- STATE UPDATE
PROCESS (RESET_N, CLK_IN)
BEGIN
IF RESET_N = '0' THEN
	-- RESET and DO NOTHING values
	currstate <= RS;
ELSIF CLK_IN'EVENT AND CLK_IN = '1' THEN
	-- DO NOTHING VALUES
	COMP_SEL <= '0';
	RESET_INSTR_NUMBER <= '0';
	REG_RE_N <= '1';
	COMP_EN <= '0';
	SET_INSTR_NUMBER <= '0';
	REG_PR_N <= '1';
	COMP_OE <= '0';
	INCR_INSTR_NUMBER_NE <= '0';
	REG_CL_N <= '1';
	SPEC_REG_WR_N <= '1';
	INSTR_EN <= '0';
	DISP_EN <= '0';
	SPEC_REG_RE_N <= '1';
	INSTR_OE <= '0';
	DISP_BYTE_SELECT <= '0';
	ARITH_SEL <= '0';
	SEL_ADDR <= '1';
	DISP_PWR <= '0';
	ARITH_EN <= '0';
	REG_CPY_N <= '1';
	ARITH_OE <= '0';
	REG_WR_N <= '1';
	-- STATE SELECTION
	CASE currstate IS
	WHEN RS =>
		RESET_INSTR_NUMBER <= '1'; --
		REG_CL_N <= '0'; --
		INSTR_EN <= '1';
		currstate <= RD;
	WHEN RD =>
		CASE INSTR(3 DOWNTO 0) IS
		WHEN "0000" => -- WR
			INSTR_OE <= '1'; -- LOAD DATA FROM BYTE2 ON D_BUS -- ADDRESS TO BE WRITTEN ON IS AUTOMATICALLY ON REG_WR_ADDRESS
			REG_WR_N <= '0'; -- ENABLE WRITING (ACTIVE LOW)
			INCR_INSTR_NUMBER_NE <= '1';
			currstate <= WR;
		WHEN "0001" => -- CP
			INSTR_OE <= '1';
			REG_WR_N <= '0';
			REG_RE_N <= '0';
			REG_CPY_N <= '0';
			SEL_ADDR <= '0';
			INCR_INSTR_NUMBER_NE <= '1';
			currstate <= CP;
		WHEN "0010" | "0011"  => -- DE0x1
			REG_RE_N <= '0'; -- READ FROM ADDRESS --> COMPONENT SEG DISPLAY WILL READ FROM THE TWO DBUS NIBBLES
			SEL_ADDR <= '0';
			DISP_BYTE_SELECT <= INSTR(0);
			DISP_EN <= '1'; -- ENABLE DISP COMPONENT
			DISP_PWR <= '1'; -- POWER O
			INCR_INSTR_NUMBER_NE <= '1';
			currstate <= DE;
		WHEN "0110" => -- JU
			INSTR_OE <= '1';
			SET_INSTR_NUMBER <= '1';
			INCR_INSTR_NUMBER_NE <= '1';
			currstate <= JU;
		WHEN "1111" => -- NO
			INCR_INSTR_NUMBER_NE <= '1';
			currstate <= NO;
		WHEN OTHERS => -- RD
			currstate <= RD;
		END CASE;
	WHEN OTHERS => -- WR, DE, NO, JU
		INSTR_EN <= '1';
		currstate <= RD;
	END CASE;
END IF;
END PROCESS;
END STRUCTURE;
