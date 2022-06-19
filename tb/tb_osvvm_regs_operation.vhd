-------------------------------------------------------------------------------
--
--  OSVVM Demonstrator / Normal operation testcase 
--
--  Author(s):
--    Guy Eschemann, guy@airhdl.com
--
-------------------------------------------------------------------------------
--
-- Copyright (c) 2022 Guy Eschemann
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library OSVVM;
context OSVVM.OsvvmContext;
use osvvm.ScoreboardPkg_slv.all;

library osvvm_axi4;
use osvvm_axi4.Axi4OptionsPkg.all;

use work.osvvm_regs_pkg.all;            -- contains the register bank address definitions

architecture operation of tb_osvvm_regs_testctrl is

begin

    ------------------------------------------------------------
    -- ControlProc
    --   Set up AlertLog and wait for end of test
    ------------------------------------------------------------
    ControlProc : process
        variable addr           : unsigned(31 downto 0);
        variable wdata          : std_logic_vector(31 downto 0);
        variable rdata          : std_logic_vector(31 downto 0);
        variable actual_value   : std_logic_vector(STATUS_VALUE_BIT_WIDTH - 1 downto 0);
        variable expected_value : std_logic_vector(CONTROL_VALUE_BIT_WIDTH - 1 downto 0);
    begin
        -- Initialization of test
        SetAlertLogName("tb_osvvm_regs_operation");
        SetLogEnable(INFO, TRUE);
        SetLogEnable(DEBUG, FALSE);
        SetLogEnable(PASSED, FALSE);

        -- Wait for testbench initialization 
        wait for 0 ns;

        -- Wait for Design Reset
        wait until nReset = '1';
        ClearAlerts;

        Log("Write Control register");
        addr  := unsigned(REGS_BASEADDR) + CONTROL_OFFSET;
        wdata := x"00001234";
        Write(Axi4MemRec, std_logic_vector(addr), wdata);

        Log("Read Status register");
        Read(Axi4MemRec, std_logic_vector(addr), rdata);

        -- Extract field value from register value
        actual_value   := rdata(STATUS_VALUE_BIT_WIDTH + STATUS_VALUE_BIT_OFFSET - 1 downto STATUS_VALUE_BIT_OFFSET);
        expected_value := wdata(CONTROL_VALUE_BIT_OFFSET + CONTROL_VALUE_BIT_WIDTH - 1 downto CONTROL_VALUE_BIT_OFFSET);

        -- Compare write and read field values
        AffirmIfEqual(expected_value, actual_value, "read data");

        EndOfTestReports;
        std.env.stop;
        wait;
    end process ControlProc;

end architecture operation;

configuration tb_osvvm_regs_operation of tb_regs_osvvm is
    for TestHarness
        for testctrl_inst : tb_osvvm_regs_testctrl
            use entity work.tb_osvvm_regs_testctrl(operation);
        end for;
    end for;
end tb_osvvm_regs_operation;
