------------------------------------------------------------------------------
-- This file is part of 'LCLS2 BLEN Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'LCLS2 BLEN Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

package Version is

constant FPGA_VERSION_C : std_logic_vector(31 downto 0) := x"00000016"; -- MAKE_VERSION

constant BUILD_STAMP_C : string := "AmcCarrierBlen: Vivado v2016.2 (x86_64) Built Fri Feb  3 17:55:54 PST 2017 by leosap";

end Version;

-------------------------------------------------------------------------------
-- Revision History:
--
-- 07/10/2015 (0x00000001): Initial Build
-- 02/04/2016 (0x00000002): Added ring buffers to Generic ADC/DAC AMC modules
-- 02/05/2016 (0x00000003): Modified AmcGenericAdcDacCtrl registers
-- 02/05/2016 (0x00000004): Fixed bug in AxiLiteRingBuffer Length register
-- 02/19/2016 (0x00000005): Added your synchronous external trigger suppor, added VCO DAC firmware driver
-- 02/25/2016 (0x00000006): Added DAC sequancuing originated by LLRF firmware (uros) for both AMC
-- 02/26/2016 (0x00000007):  fix error in Sync Trig SM (LArry)
-- 03/10/2016 (0x00000008):  refresh contributions
-- 03/17/2016 (0x00000008):  refresh contributions, plus add trigger control stuff, fixed syncShot, fixed interface between timing and common platform
-- 03/31/2016 (0x00000009): Unused (internal testing )
-- 03/31/2016 (0x0000000A): Unused (internal testing )
-- 03/31/2016 (0x0000000B): Unused (internal testing )
-- 03/31/2016 (0x0000000C): First working in new 7 slot crate with new IP addressing mechanism
-- 03/31/2016 (0x0000000D): Using Timing message latching update in timing core
-- 04/20/2016 (0x0000000E): Unused (internal testing )
-- 04/20/2016 (0x0000000F): Unused (internal testing )
-- 04/20/2016 (0x00000010): Debugging timing interfaces
-- 06/xx/2016 (0x00000011): Just interm. version
-- 07/xx/2016 (0x00000012): Addition of DSP core
-- 08/04/2016 (0x00000013): Update to Tag flow and 2016.2
-- 08/04/2016 (0x00000014): Update back to head to try new features
-- 09/02/2016 (0x00000015): Update to newMux and tag1.2
-- 11/15/2016 (0x00000016): Update to new version of 2.0 and 3.0 yaml
------------------------------------------------------------------------------r


