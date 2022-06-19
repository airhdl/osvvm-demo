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

    -------------------------------------------------------------------------------
    -- Constants
    -------------------------------------------------------------------------------

    -------------------------------------------------------------------------------
    -- Aliases
    -------------------------------------------------------------------------------


begin

    ------------------------------------------------------------
    -- ControlProc
    --   Set up AlertLog and wait for end of test
    ------------------------------------------------------------
    ControlProc : process
        variable addr  : unsigned(31 downto 0);
        variable wdata : std_logic_vector(31 downto 0);
    begin
        -- Initialization of test
        SetAlertLogName("tb_spi2axi_operation");
        SetLogEnable(INFO, TRUE);
        SetLogEnable(DEBUG, FALSE);
        SetLogEnable(PASSED, FALSE);
        SetLogEnable(FindAlertLogID("Axi4LiteMemory"), INFO, FALSE, TRUE);

        -- Wait for testbench initialization 
        wait for 0 ns;

        -- Wait for Design Reset
        wait until nReset = '1';
        ClearAlerts;

        Log("Write Control register");
        addr  := unsigned(REGS_BASEADDR) + CONTROL_OFFSET;
        wdata := x"00001234";

        Write(Axi4MemRec, std_logic_vector(addr), wdata);
        

        --        SetCPHA(SpiRec, SPI_CPHA);
        --        SetCPOL(SpiRec, SPI_CPOL);
        --
        --        wait for 1 us;
        --
        --        Log("Testing normal SPI write");
        --        addr  := x"76543210";
        --        wdata := x"12345678";
        --        spi_write(addr, wdata, status);
        --        AffirmIfEqual(status(2), '0', "timeout");
        --        AffirmIfEqual(status(1 downto 0), "00", "write response");
        --
        --        Read(Axi4MemRec, std_logic_vector(addr), mem_reg);
        --        AffirmIfEqual(mem_reg, wdata, "memory data word");
        --
        --        Log("Testing SPI write with SLVERR response");
        --        addr  := x"76543210";
        --        wdata := x"12345678";
        --        SetAxi4Options(Axi4MemRec, BRESP, 2); -- SLVERR
        --        spi_write(addr, wdata, status);
        --        AffirmIfEqual(status(2), '0', "Timeout");
        --        AffirmIfEqual(status(1 downto 0), "10", "Write response");
        --        SetAxi4Options(Axi4MemRec, BRESP, 0);
        --
        --        Log("Testing SPI write timeout");
        --        s_axi_awvalid_mask <= force '0';
        --        addr               := x"76543210";
        --        wdata              := x"12345678";
        --        spi_write(addr, wdata, status);
        --        AffirmIfEqual('1', status(2), "timeout");
        --        s_axi_awvalid_mask <= release;
        --
        --        Log("Testing normal SPI read");
        --        addr  := x"12345678";
        --        wdata := x"12345678";
        --        Write(Axi4MemRec, std_logic_vector(addr), wdata);
        --        spi_read(addr, rdata, status);
        --        AffirmIfEqual(rdata, wdata, "read data");
        --        AffirmIfEqual('0', status(2), "timeout");
        --        AffirmIfEqual("00", status(1 downto 0), "read response");
        --
        --        Log("Testing SPI read with DECERR response");
        --        addr  := x"12345678";
        --        wdata := x"12345678";
        --        SetAxi4Options(Axi4MemRec, RRESP, 3); -- DECERR
        --        spi_read(addr, rdata, status);
        --        AffirmIfEqual(rdata, wdata, "read data");
        --        AffirmIfEqual('0', status(2), "timeout");
        --        AffirmIfEqual("11", status(1 downto 0), "read response");
        --        SetAxi4Options(Axi4MemRec, RRESP, 0);
        --
        --        Log("Testing SPI read timeout");
        --        s_axi_arvalid_mask <= force '0';
        --        spi_read(addr, rdata, status);
        --        AffirmIfEqual('1', status(2), "timeout");
        --        s_axi_arvalid_mask <= release;

        wait for 1 us;

        EndOfTestReports;
        std.env.stop;
        wait;
    end process ControlProc;

end architecture operation;

configuration tb_osvvm_regs_operation of tb_osvvm_regs is
    for TestHarness
        for testctrl_inst : tb_osvvm_regs_testctrl
            use entity work.tb_osvvm_regs_testctrl(operation);
        end for;
    end for;
end tb_osvvm_regs_operation;
