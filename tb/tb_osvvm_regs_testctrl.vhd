-------------------------------------------------------------------------------
--
--  OSVVM Demonstrator / Test controller entity declaration 
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
use ieee.numeric_std_unsigned.all;
use std.textio.all;

library OSVVM;
context OSVVM.OsvvmContext;

library osvvm_axi4;
context osvvm_axi4.Axi4LiteContext;

entity tb_osvvm_regs_testctrl is
    generic(
        REGS_BASEADDR : std_logic_vector(31 downto 0)
    );
    port(
        -- Record Interfaces
        Axi4MemRec : inout AddressBusRecType;
        -- Global Signal Interface
        Clk        : in    std_logic;
        nReset     : in    std_logic
    );
end entity;
