----------------------------------------------------------------------------------------------------
--
--  OSVVM Demonstrator / Test harness
--
--  Author(s):
--    Guy Eschemann, guy@airhdl.com
--
----------------------------------------------------------------------------------------------------
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
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library OSVVM;
context OSVVM.OsvvmContext;

library osvvm_axi4;
context osvvm_axi4.Axi4LiteContext;

use work.osvvm_regs_pkg.all;

entity tb_regs_osvvm is
end entity tb_regs_osvvm;

architecture TestHarness of tb_regs_osvvm is

    ------------------------------------------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------------------------------------------

    constant REGS_BASEADDR  : std_logic_vector(31 downto 0) := std_logic_vector(OSVVM_DEFAULT_BASEADDR);
    constant AXI_ADDR_WIDTH : natural                       := 32;
    constant AXI_DATA_WIDTH : natural                       := 32;
    constant AXI_STRB_WIDTH : integer                       := AXI_DATA_WIDTH / 8;
    constant AXI_CLK_PERIOD : time                          := 10 ns;
    constant TPD            : time                          := 1 ns;

    ------------------------------------------------------------------------------------------------
    -- Components
    ------------------------------------------------------------------------------------------------

    component tb_osvvm_regs_testctrl is
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
    end component;

    ------------------------------------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------------------------------------

    signal axi_aclk      : std_logic := '0';
    signal axi_aresetn   : std_logic;
    signal control_value : std_logic_vector(15 downto 0);
    signal status_value  : std_logic_vector(15 downto 0);
    signal Axi4LiteBus   : Axi4LiteRecType(
        WriteAddress(Addr(AXI_ADDR_WIDTH - 1 downto 0)),
        WriteData(Data(AXI_DATA_WIDTH - 1 downto 0), Strb(AXI_STRB_WIDTH - 1 downto 0)),
        ReadAddress(Addr(AXI_ADDR_WIDTH - 1 downto 0)),
        ReadData(Data(AXI_DATA_WIDTH - 1 downto 0))
    );
    signal Axi4MemRec    : AddressBusRecType(
        Address(AXI_ADDR_WIDTH - 1 downto 0),
        DataToModel(AXI_DATA_WIDTH - 1 downto 0),
        DataFromModel(AXI_DATA_WIDTH - 1 downto 0)
    );

begin

    ------------------------------------------------------------------------------------------------
    -- Clock generator
    ------------------------------------------------------------------------------------------------

    Osvvm.TbUtilPkg.CreateClock(
        Clk    => axi_aclk,
        Period => AXI_CLK_PERIOD
    );

    ------------------------------------------------------------------------------------------------
    -- Reset generator
    ------------------------------------------------------------------------------------------------

    Osvvm.TbUtilPkg.CreateReset(
        Reset       => axi_aresetn,
        ResetActive => '0',
        Clk         => axi_aclk,
        Period      => 7 * AXI_CLK_PERIOD,
        tpd         => TPD
    );

    ------------------------------------------------------------------------------------------------
    -- Test controller
    ------------------------------------------------------------------------------------------------

    testctrl_inst : tb_osvvm_regs_testctrl
        generic map(
            REGS_BASEADDR => REGS_BASEADDR
        )
        port map(
            Axi4MemRec => Axi4MemRec,
            Clk        => axi_aclk,
            nReset     => axi_aresetn
        );

    ------------------------------------------------------------------------------------------------
    -- Axi4LiteManager
    ------------------------------------------------------------------------------------------------

    axi4lite_manager_inst : entity osvvm_axi4.Axi4LiteManager -- @suppress "Generic map uses default values. Missing optional actuals: MODEL_ID_NAME, tperiod_Clk, DEFAULT_DELAY, tpd_Clk_AWAddr, tpd_Clk_AWProt, tpd_Clk_AWValid, tpd_Clk_WValid, tpd_Clk_WData, tpd_Clk_WStrb, tpd_Clk_BReady, tpd_Clk_ARValid, tpd_Clk_ARProt, tpd_Clk_ARAddr, tpd_Clk_RReady"
        generic map(
            MODEL_ID_NAME => "Axi4LiteManager"
        )
        port map(
            Clk      => axi_aclk,
            nReset   => axi_aresetn,
            AxiBus   => Axi4LiteBus,
            TransRec => Axi4MemRec
        );

    ------------------------------------------------------------------------------------------------
    -- Unit under test
    ------------------------------------------------------------------------------------------------

    uut : entity work.osvvm_regs
        generic map(
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH,
            BASEADDR       => REGS_BASEADDR
        )
        port map(
            axi_aclk       => axi_aclk,
            axi_aresetn    => axi_aresetn,
            s_axi_awaddr   => Axi4LiteBus.WriteAddress.Addr,
            s_axi_awprot   => Axi4LiteBus.WriteAddress.Prot,
            s_axi_awvalid  => Axi4LiteBus.WriteAddress.Valid,
            s_axi_awready  => Axi4LiteBus.WriteAddress.Ready,
            s_axi_wdata    => Axi4LiteBus.WriteData.Data,
            s_axi_wstrb    => Axi4LiteBus.WriteData.Strb,
            s_axi_wvalid   => Axi4LiteBus.WriteData.Valid,
            s_axi_wready   => Axi4LiteBus.WriteData.Ready,
            s_axi_araddr   => Axi4LiteBus.ReadAddress.Addr,
            s_axi_arprot   => Axi4LiteBus.ReadAddress.Prot,
            s_axi_arvalid  => Axi4LiteBus.ReadAddress.Valid,
            s_axi_arready  => Axi4LiteBus.ReadAddress.Ready,
            s_axi_rdata    => Axi4LiteBus.ReadData.Data,
            s_axi_rresp    => Axi4LiteBus.ReadData.Resp,
            s_axi_rvalid   => Axi4LiteBus.ReadData.Valid,
            s_axi_rready   => Axi4LiteBus.ReadData.Ready,
            s_axi_bresp    => Axi4LiteBus.WriteResponse.Resp,
            s_axi_bvalid   => Axi4LiteBus.WriteResponse.Valid,
            s_axi_bready   => Axi4LiteBus.WriteResponse.Ready,
            control_strobe => open,
            control_value  => control_value,
            status_strobe  => open,
            status_value   => status_value
        );

    -- Control.value to Status.value loopback
    status_value <= control_value;

end architecture TestHarness;
