//----------------------------------------------------------------------------
// Copyright (C) 2015 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: omsp_gfx_reg.v
//
// *Module Description:
//                      Registers for oMSP programming.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev$
// $LastChangedBy$
// $LastChangedDate$
//----------------------------------------------------------------------------
`ifdef OMSP_GFX_CONTROLLER_NO_INCLUDE
`else
`include "omsp_gfx_controller_defines.v"
`endif

module  omsp_gfx_reg (

// OUTPUTs
    irq_gfx_o,                                 // Graphic Controller interrupt

    lt24_reset_n_o,                            // LT24 Reset (Active Low)
    lt24_on_o,                                 // LT24 on/off
    lt24_cfg_clk_o,                            // LT24 Interface clock configuration
    lt24_cfg_refr_o,                           // LT24 Interface refresh configuration
    lt24_cfg_refr_sync_en_o,                   // LT24 Interface refresh sync enable configuration
    lt24_cfg_refr_sync_val_o,                  // LT24 Interface refresh sync value configuration
    lt24_cmd_refr_o,                           // LT24 Interface refresh command
    lt24_cmd_val_o,                            // LT24 Generic command value
    lt24_cmd_has_param_o,                      // LT24 Generic command has parameters
    lt24_cmd_param_o,                          // LT24 Generic command parameter value
    lt24_cmd_param_rdy_o,                      // LT24 Generic command trigger
    lt24_cmd_dfill_o,                          // LT24 Data fill value
    lt24_cmd_dfill_wr_o,                       // LT24 Data fill trigger

    display_width_o,                           // Display width
    display_height_o,                          // Display height
    display_size_o,                            // Display size (number of pixels)
    display_y_swap_o,                          // Display configuration: swap Y axis (horizontal symmetry)
    display_x_swap_o,                          // Display configuration: swap X axis (vertical symmetry)
    display_cl_swap_o,                         // Display configuration: swap column/lines
    gfx_mode_o,                                // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

    per_dout_o,                                // Peripheral data output

    refresh_frame_addr_o,                      // Refresh frame base address
    refresh_lut_select_o,                      // Refresh LUT bank selection

`ifdef WITH_PROGRAMMABLE_LUT
    lut_ram_addr_o,                            // LUT-RAM address
    lut_ram_din_o,                             // LUT-RAM data
    lut_ram_wen_o,                             // LUT-RAM write strobe (active low)
    lut_ram_cen_o,                             // LUT-RAM chip enable (active low)
`endif

    vid_ram_addr_o,                            // Video-RAM address
    vid_ram_din_o,                             // Video-RAM data
    vid_ram_wen_o,                             // Video-RAM write strobe (active low)
    vid_ram_cen_o,                             // Video-RAM chip enable (active low)

// INPUTs
    dbg_freeze_i,                              // Freeze address auto-incr on read
    lt24_status_i,                             // LT24 FSM Status
    lt24_start_evt_i,                          // LT24 FSM is starting
    lt24_done_evt_i,                           // LT24 FSM is done
    mclk,                                      // Main system clock
    per_addr_i,                                // Peripheral address
    per_din_i,                                 // Peripheral data input
    per_en_i,                                  // Peripheral enable (high active)
    per_we_i,                                  // Peripheral write enable (high active)
    puc_rst,                                   // Main system reset
`ifdef WITH_PROGRAMMABLE_LUT
    lut_ram_dout_i,                            // LUT-RAM data input
`endif
    vid_ram_dout_i                             // Video-RAM data input
);

// OUTPUTs
//=========
output               irq_gfx_o;                // Graphic Controller interrupt

output               lt24_reset_n_o;           // LT24 Reset (Active Low)
output               lt24_on_o;                // LT24 on/off
output         [2:0] lt24_cfg_clk_o;           // LT24 Interface clock configuration
output        [11:0] lt24_cfg_refr_o;          // LT24 Interface refresh configuration
output               lt24_cfg_refr_sync_en_o;  // LT24 Interface refresh sync configuration
output         [9:0] lt24_cfg_refr_sync_val_o; // LT24 Interface refresh sync value configuration
output               lt24_cmd_refr_o;          // LT24 Interface refresh command
output         [7:0] lt24_cmd_val_o;           // LT24 Generic command value
output               lt24_cmd_has_param_o;     // LT24 Generic command has parameters
output        [15:0] lt24_cmd_param_o;         // LT24 Generic command parameter value
output               lt24_cmd_param_rdy_o;     // LT24 Generic command trigger
output        [15:0] lt24_cmd_dfill_o;         // LT24 Data fill value
output               lt24_cmd_dfill_wr_o;      // LT24 Data fill trigger

output [`LPIX_MSB:0] display_width_o;          // Display width
output [`LPIX_MSB:0] display_height_o;         // Display height
output [`SPIX_MSB:0] display_size_o;           // Display size (number of pixels)
output               display_y_swap_o;         // Display configuration: swap Y axis (horizontal symmetry)
output               display_x_swap_o;         // Display configuration: swap X axis (vertical symmetry)
output               display_cl_swap_o;        // Display configuration: swap column/lines
output         [2:0] gfx_mode_o;               // Video mode (1xx:16bpp / 011:8bpp / 010:4bpp / 001:2bpp / 000:1bpp)

output        [15:0] per_dout_o;               // Peripheral data output

output [`VRAM_MSB:0] refresh_frame_addr_o;     // Refresh frame base address
output         [1:0] refresh_lut_select_o;     // Refresh LUT bank selection

`ifdef WITH_PROGRAMMABLE_LUT
output [`LRAM_MSB:0] lut_ram_addr_o;           // LUT-RAM address
output        [15:0] lut_ram_din_o;            // LUT-RAM data
output         [1:0] lut_ram_wen_o;            // LUT-RAM write strobe (active low)
output               lut_ram_cen_o;            // LUT-RAM chip enable (active low)
`endif

output [`VRAM_MSB:0] vid_ram_addr_o;           // Video-RAM address
output        [15:0] vid_ram_din_o;            // Video-RAM data
output         [1:0] vid_ram_wen_o;            // Video-RAM write strobe (active low)
output               vid_ram_cen_o;            // Video-RAM chip enable (active low)

// INPUTs
//=========
input                dbg_freeze_i;             // Freeze address auto-incr on read
input          [4:0] lt24_status_i;            // LT24 FSM Status
input                lt24_start_evt_i;         // LT24 FSM is starting
input                lt24_done_evt_i;          // LT24 FSM is done
input                mclk;                     // Main system clock
input         [13:0] per_addr_i;               // Peripheral address
input         [15:0] per_din_i;                // Peripheral data input
input                per_en_i;                 // Peripheral enable (high active)
input          [1:0] per_we_i;                 // Peripheral write enable (high active)
input                puc_rst;                  // Main system reset
`ifdef WITH_PROGRAMMABLE_LUT
input         [15:0] lut_ram_dout_i;           // LUT-RAM data input
`endif
input         [15:0] vid_ram_dout_i;           // Video-RAM data input


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR           = 15'h0200;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD              =  7;

// Register addresses offset
parameter [DEC_WD-1:0] GFX_CTRL            = 'h00,  // General control/status/irq
                       GFX_STATUS          = 'h08,
                       GFX_IRQ             = 'h0A,

                       DISPLAY_WIDTH       = 'h10,  // Display configuration
                       DISPLAY_HEIGHT      = 'h12,
                       DISPLAY_SIZE_HI     = 'h14,
                       DISPLAY_SIZE_LO     = 'h16,
                       DISPLAY_CFG         = 'h18,

                       LT24_CFG            = 'h20,  // LT24 configuration and Generic command sending
                       LT24_REFRESH        = 'h22,
                       LT24_REFRESH_SYNC   = 'h24,
                       LT24_CMD            = 'h26,
                       LT24_CMD_PARAM      = 'h28,
                       LT24_CMD_DFILL      = 'h2A,
                       LT24_STATUS         = 'h2C,

                       LUT_RAM_ADDR        = 'h30,  // LUT Memory Access Gate
                       LUT_RAM_DATA        = 'h32,

                       FRAME_SELECT        = 'h3E,  // Frame pointers and selection
                       FRAME0_PTR_HI       = 'h40,
                       FRAME0_PTR_LO       = 'h42,
                       FRAME1_PTR_HI       = 'h44,
                       FRAME1_PTR_LO       = 'h46,
                       FRAME2_PTR_HI       = 'h48,
                       FRAME2_PTR_LO       = 'h4A,
                       FRAME3_PTR_HI       = 'h4C,
                       FRAME3_PTR_LO       = 'h4E,

                       VID_RAM0_CFG        = 'h50,  // First Video Memory Access Gate
                       VID_RAM0_WIDTH      = 'h52,
                       VID_RAM0_ADDR_HI    = 'h54,
                       VID_RAM0_ADDR_LO    = 'h56,
                       VID_RAM0_DATA       = 'h58,

                       VID_RAM1_CFG        = 'h60,  // Second Video Memory Access Gate
                       VID_RAM1_WIDTH      = 'h62,
                       VID_RAM1_ADDR_HI    = 'h64,
                       VID_RAM1_ADDR_LO    = 'h66,
                       VID_RAM1_DATA       = 'h68,

                       GPU_CMD             = 'h70,  // Graphic Processing Unit
                       GPU_STAT            = 'h72;


// Register one-hot decoder utilities
parameter              DEC_SZ              =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG            =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] GFX_CTRL_D          = (BASE_REG << GFX_CTRL          ),
                       GFX_STATUS_D        = (BASE_REG << GFX_STATUS        ),
                       GFX_IRQ_D           = (BASE_REG << GFX_IRQ           ),

                       DISPLAY_WIDTH_D     = (BASE_REG << DISPLAY_WIDTH     ),
                       DISPLAY_HEIGHT_D    = (BASE_REG << DISPLAY_HEIGHT    ),
                       DISPLAY_SIZE_HI_D   = (BASE_REG << DISPLAY_SIZE_HI   ),
                       DISPLAY_SIZE_LO_D   = (BASE_REG << DISPLAY_SIZE_LO   ),
                       DISPLAY_CFG_D       = (BASE_REG << DISPLAY_CFG       ),

                       LT24_CFG_D          = (BASE_REG << LT24_CFG          ),
                       LT24_REFRESH_D      = (BASE_REG << LT24_REFRESH      ),
                       LT24_REFRESH_SYNC_D = (BASE_REG << LT24_REFRESH_SYNC ),
                       LT24_CMD_D          = (BASE_REG << LT24_CMD          ),
                       LT24_CMD_PARAM_D    = (BASE_REG << LT24_CMD_PARAM    ),
                       LT24_CMD_DFILL_D    = (BASE_REG << LT24_CMD_DFILL    ),
                       LT24_STATUS_D       = (BASE_REG << LT24_STATUS       ),

                       LUT_RAM_ADDR_D      = (BASE_REG << LUT_RAM_ADDR      ),
                       LUT_RAM_DATA_D      = (BASE_REG << LUT_RAM_DATA      ),

                       FRAME_SELECT_D      = (BASE_REG << FRAME_SELECT      ),
                       FRAME0_PTR_HI_D     = (BASE_REG << FRAME0_PTR_HI     ),
                       FRAME0_PTR_LO_D     = (BASE_REG << FRAME0_PTR_LO     ),
                       FRAME1_PTR_HI_D     = (BASE_REG << FRAME1_PTR_HI     ),
                       FRAME1_PTR_LO_D     = (BASE_REG << FRAME1_PTR_LO     ),
                       FRAME2_PTR_HI_D     = (BASE_REG << FRAME2_PTR_HI     ),
                       FRAME2_PTR_LO_D     = (BASE_REG << FRAME2_PTR_LO     ),
                       FRAME3_PTR_HI_D     = (BASE_REG << FRAME3_PTR_HI     ),
                       FRAME3_PTR_LO_D     = (BASE_REG << FRAME3_PTR_LO     ),

                       VID_RAM0_CFG_D      = (BASE_REG << VID_RAM0_CFG      ),
                       VID_RAM0_WIDTH_D    = (BASE_REG << VID_RAM0_WIDTH    ),
                       VID_RAM0_ADDR_HI_D  = (BASE_REG << VID_RAM0_ADDR_HI  ),
                       VID_RAM0_ADDR_LO_D  = (BASE_REG << VID_RAM0_ADDR_LO  ),
                       VID_RAM0_DATA_D     = (BASE_REG << VID_RAM0_DATA     ),

                       VID_RAM1_CFG_D      = (BASE_REG << VID_RAM1_CFG      ),
                       VID_RAM1_WIDTH_D    = (BASE_REG << VID_RAM1_WIDTH    ),
                       VID_RAM1_ADDR_HI_D  = (BASE_REG << VID_RAM1_ADDR_HI  ),
                       VID_RAM1_ADDR_LO_D  = (BASE_REG << VID_RAM1_ADDR_LO  ),
                       VID_RAM1_DATA_D     = (BASE_REG << VID_RAM1_DATA     ),

                       GPU_CMD_D           = (BASE_REG << GPU_CMD           ),
                       GPU_STAT_D          = (BASE_REG << GPU_STAT          );


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire               reg_sel   =  per_en_i & (per_addr_i[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire  [DEC_WD-1:0] reg_addr  =  {per_addr_i[DEC_WD-2:0], 1'b0};

// Register address decode
wire  [DEC_SZ-1:0] reg_dec   =  (GFX_CTRL_D          &  {DEC_SZ{(reg_addr == GFX_CTRL          )}})  |
                                (GFX_STATUS_D        &  {DEC_SZ{(reg_addr == GFX_STATUS        )}})  |
                                (GFX_IRQ_D           &  {DEC_SZ{(reg_addr == GFX_IRQ           )}})  |

                                (DISPLAY_WIDTH_D     &  {DEC_SZ{(reg_addr == DISPLAY_WIDTH     )}})  |
                                (DISPLAY_HEIGHT_D    &  {DEC_SZ{(reg_addr == DISPLAY_HEIGHT    )}})  |
                                (DISPLAY_SIZE_HI_D   &  {DEC_SZ{(reg_addr == DISPLAY_SIZE_HI   )}})  |
                                (DISPLAY_SIZE_LO_D   &  {DEC_SZ{(reg_addr == DISPLAY_SIZE_LO   )}})  |
                                (DISPLAY_CFG_D       &  {DEC_SZ{(reg_addr == DISPLAY_CFG       )}})  |

                                (LT24_CFG_D          &  {DEC_SZ{(reg_addr == LT24_CFG          )}})  |
                                (LT24_REFRESH_D      &  {DEC_SZ{(reg_addr == LT24_REFRESH      )}})  |
                                (LT24_REFRESH_SYNC_D &  {DEC_SZ{(reg_addr == LT24_REFRESH_SYNC )}})  |
                                (LT24_CMD_D          &  {DEC_SZ{(reg_addr == LT24_CMD          )}})  |
                                (LT24_CMD_PARAM_D    &  {DEC_SZ{(reg_addr == LT24_CMD_PARAM    )}})  |
                                (LT24_CMD_DFILL_D    &  {DEC_SZ{(reg_addr == LT24_CMD_DFILL    )}})  |
                                (LT24_STATUS_D       &  {DEC_SZ{(reg_addr == LT24_STATUS       )}})  |

                                (LUT_RAM_ADDR_D      &  {DEC_SZ{(reg_addr == LUT_RAM_ADDR      )}})  |
                                (LUT_RAM_DATA_D      &  {DEC_SZ{(reg_addr == LUT_RAM_DATA      )}})  |

                                (FRAME_SELECT_D      &  {DEC_SZ{(reg_addr == FRAME_SELECT      )}})  |
                                (FRAME0_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME0_PTR_HI     )}})  |
                                (FRAME0_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME0_PTR_LO     )}})  |
                                (FRAME1_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME1_PTR_HI     )}})  |
                                (FRAME1_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME1_PTR_LO     )}})  |
                                (FRAME2_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME2_PTR_HI     )}})  |
                                (FRAME2_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME2_PTR_LO     )}})  |
                                (FRAME3_PTR_HI_D     &  {DEC_SZ{(reg_addr == FRAME3_PTR_HI     )}})  |
                                (FRAME3_PTR_LO_D     &  {DEC_SZ{(reg_addr == FRAME3_PTR_LO     )}})  |

                                (VID_RAM0_CFG_D      &  {DEC_SZ{(reg_addr == VID_RAM0_CFG      )}})  |
                                (VID_RAM0_WIDTH_D    &  {DEC_SZ{(reg_addr == VID_RAM0_WIDTH    )}})  |
                                (VID_RAM0_ADDR_HI_D  &  {DEC_SZ{(reg_addr == VID_RAM0_ADDR_HI  )}})  |
                                (VID_RAM0_ADDR_LO_D  &  {DEC_SZ{(reg_addr == VID_RAM0_ADDR_LO  )}})  |
                                (VID_RAM0_DATA_D     &  {DEC_SZ{(reg_addr == VID_RAM0_DATA     )}})  |

                                (VID_RAM1_CFG_D      &  {DEC_SZ{(reg_addr == VID_RAM1_CFG      )}})  |
                                (VID_RAM1_WIDTH_D    &  {DEC_SZ{(reg_addr == VID_RAM1_WIDTH    )}})  |
                                (VID_RAM1_ADDR_HI_D  &  {DEC_SZ{(reg_addr == VID_RAM1_ADDR_HI  )}})  |
                                (VID_RAM1_ADDR_LO_D  &  {DEC_SZ{(reg_addr == VID_RAM1_ADDR_LO  )}})  |
                                (VID_RAM1_DATA_D     &  {DEC_SZ{(reg_addr == VID_RAM1_DATA     )}})  |

                                (GPU_CMD_D           &  {DEC_SZ{(reg_addr == GPU_CMD           )}})  |
                                (GPU_STAT_D          &  {DEC_SZ{(reg_addr == GPU_STAT          )}});

// Read/Write probes
wire               reg_write =  |per_we_i & reg_sel;
wire               reg_read  = ~|per_we_i & reg_sel;

// Read/Write vectors
wire  [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire  [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};

// Other wire declarations
wire [`VRAM_MSB:0] frame0_ptr;
`ifdef WITH_FRAME1_POINTER
wire [`VRAM_MSB:0] frame1_ptr;
`endif
`ifdef WITH_FRAME2_POINTER
wire [`VRAM_MSB:0] frame2_ptr;
`endif
`ifdef WITH_FRAME3_POINTER
wire [`VRAM_MSB:0] frame3_ptr;
`endif
wire [`VRAM_MSB:0] vid_ram0_base_addr;
wire [`VRAM_MSB:0] vid_ram1_base_addr;
`ifdef WITH_EXTRA_LUT_BANK
reg                lut_bank_select;
`endif
reg                vid_ram0_addr_lo_wr_dly;
reg                vid_ram1_addr_lo_wr_dly;


//============================================================================
// 3) REGISTERS
//============================================================================

//------------------------------------------------
// GFX_CTRL Register
//------------------------------------------------
reg  [15:0] gfx_ctrl;

wire        gfx_ctrl_wr = reg_wr[GFX_CTRL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          gfx_ctrl <=  16'h0000;
  else if (gfx_ctrl_wr) gfx_ctrl <=  per_din_i;

// Bitfield assignments
wire        gfx_irq_done_en  =  gfx_ctrl[0];
wire        gfx_irq_start_en =  gfx_ctrl[0];
assign      gfx_mode_o       =  gfx_ctrl[10:8]; // 1xx: 16 bits-per-pixel
                                                // 011:  8 bits-per-pixel
                                                // 010:  4 bits-per-pixel
                                                // 001:  2 bits-per-pixel
                                                // 000:  1 bits-per-pixel

//------------------------------------------------
// GFX_STATUS Register
//------------------------------------------------
wire  [15:0] gfx_status;

assign       gfx_status[0]    = lt24_status_i[2]; // Screen Refresh is busy
assign       gfx_status[15:1] = 15'h0000;

//------------------------------------------------
// GFX_IRQ Register
//------------------------------------------------
wire [15:0] gfx_irq;

// Clear IRQ when 1 is written. Set IRQ when FSM is done
wire        gfx_irq_screen_done_clr   = per_din_i[0] & reg_wr[GFX_IRQ];
wire        gfx_irq_screen_done_set   = lt24_done_evt_i;

wire        gfx_irq_screen_start_clr  = per_din_i[1] & reg_wr[GFX_IRQ];
wire        gfx_irq_screen_start_set  = lt24_start_evt_i;

reg         gfx_irq_screen_done;
reg         gfx_irq_screen_start;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       gfx_irq_screen_done  <=  1'b0;
       gfx_irq_screen_start <=  1'b0;
    end
  else
    begin
       gfx_irq_screen_done  <=  (gfx_irq_screen_done_set  | (~gfx_irq_screen_done_clr  & gfx_irq_screen_done)) ; // IRQ set has priority over clear
       gfx_irq_screen_start <=  (gfx_irq_screen_start_set | (~gfx_irq_screen_start_clr & gfx_irq_screen_start)); // IRQ set has priority over clear
    end

assign  gfx_irq   = {14'h0000, gfx_irq_screen_start, gfx_irq_screen_done};

assign  irq_gfx_o = (gfx_irq_screen_done  & gfx_irq_done_en) |
                    (gfx_irq_screen_start & gfx_irq_start_en);    // Graphic Controller interrupt

//------------------------------------------------
// DISPLAY_WIDTH Register
//------------------------------------------------
reg  [`LPIX_MSB:0] display_width_o;

wire               display_width_wr = reg_wr[DISPLAY_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               display_width_o <=  {`LPIX_MSB+1{1'b0}};
  else if (display_width_wr) display_width_o <=  per_din_i[`LPIX_MSB:0];

wire [16:0] display_width_tmp = {{16-`LPIX_MSB{1'b0}}, display_width_o};
wire [15:0] display_width_rd  = display_width_tmp[15:0];

//------------------------------------------------
// DISPLAY_HEIGHT Register
//------------------------------------------------
reg  [`LPIX_MSB:0] display_height_o;

wire               display_height_wr = reg_wr[DISPLAY_HEIGHT];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                display_height_o <=  {`LPIX_MSB+1{1'b0}};
  else if (display_height_wr) display_height_o <=  per_din_i[`LPIX_MSB:0];

wire [16:0] display_height_tmp = {{16-`LPIX_MSB{1'b0}}, display_height_o};
wire [15:0] display_height_rd  = display_height_tmp[15:0];

//------------------------------------------------
// DISPLAY_SIZE_HI Register
//------------------------------------------------
`ifdef WITH_DISPLAY_SIZE_HI
reg  [`SPIX_HI_MSB:0] display_size_hi;

wire                  display_size_hi_wr = reg_wr[DISPLAY_SIZE_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 display_size_hi <=  {`SPIX_HI_MSB+1{1'h0}};
  else if (display_size_hi_wr) display_size_hi <=  per_din_i[`SPIX_HI_MSB:0];

wire  [16:0] display_size_hi_tmp = {{16-`SPIX_HI_MSB{1'h0}}, display_size_hi};
wire  [15:0] display_size_hi_rd  = display_size_hi_tmp[15:0];
`endif

//------------------------------------------------
// DISPLAY_SIZE_LO Register
//------------------------------------------------
reg  [`SPIX_LO_MSB:0] display_size_lo;

wire                  display_size_lo_wr = reg_wr[DISPLAY_SIZE_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 display_size_lo <=  {`SPIX_LO_MSB+1{1'h0}};
  else if (display_size_lo_wr) display_size_lo <=  per_din_i[`SPIX_LO_MSB:0];

wire  [16:0] display_size_lo_tmp = {{16-`SPIX_LO_MSB{1'h0}}, display_size_lo};
wire  [15:0] display_size_lo_rd  = display_size_lo_tmp[15:0];

`ifdef WITH_DISPLAY_SIZE_HI
assign display_size_o = {display_size_hi, display_size_lo};
`else
assign display_size_o =  display_size_lo;
`endif

//------------------------------------------------
// DISPLAY_CFG Register
//------------------------------------------------
reg   display_x_swap_o;
reg   display_y_swap_o;
reg   display_cl_swap_o;

wire  display_cfg_wr = reg_wr[DISPLAY_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       display_x_swap_o  <=  1'b0;
       display_y_swap_o  <=  1'b0;
       display_cl_swap_o <=  1'b0;
    end
  else if (display_cfg_wr)
    begin
       display_x_swap_o  <=  per_din_i[0];
       display_y_swap_o  <=  per_din_i[1];
       display_cl_swap_o <=  per_din_i[2];
    end

wire [15:0] display_cfg = {13'h0000,
                           display_cl_swap_o,
                           display_y_swap_o,
                           display_x_swap_o};

//------------------------------------------------
// LT24_CFG Register
//------------------------------------------------
reg  [15:0] lt24_cfg;

wire        lt24_cfg_wr = reg_wr[LT24_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          lt24_cfg <=  16'h0000;
  else if (lt24_cfg_wr) lt24_cfg <=  per_din_i;

// Bitfield assignments
assign     lt24_cfg_clk_o  =  lt24_cfg[6:4];
assign     lt24_reset_n_o  = ~lt24_cfg[1];
assign     lt24_on_o       =  lt24_cfg[0];

//------------------------------------------------
// LT24_REFRESH Register
//------------------------------------------------
reg        lt24_cmd_refr_o;
reg [11:0] lt24_cfg_refr_o;

wire      lt24_refresh_wr   = reg_wr[LT24_REFRESH];
wire      lt24_cmd_refr_clr = lt24_done_evt_i & lt24_status_i[2] & (lt24_cfg_refr_o==8'h00); // Auto-clear in manual refresh mode when done

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cmd_refr_o      <=  1'h0;
  else if (lt24_refresh_wr)   lt24_cmd_refr_o      <=  per_din_i[0];
  else if (lt24_cmd_refr_clr) lt24_cmd_refr_o      <=  1'h0;

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cfg_refr_o      <=  12'h000;
  else if (lt24_refresh_wr)   lt24_cfg_refr_o      <=  per_din_i[15:4];

wire [15:0] lt24_refresh = {lt24_cfg_refr_o, 3'h0, lt24_cmd_refr_o};

//------------------------------------------------
// LT24_REFRESH Register
//------------------------------------------------
reg        lt24_cfg_refr_sync_en_o;
reg  [9:0] lt24_cfg_refr_sync_val_o;

wire       lt24_refresh_sync_wr   = reg_wr[LT24_REFRESH_SYNC];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   lt24_cfg_refr_sync_en_o  <=  1'h0;
  else if (lt24_refresh_sync_wr) lt24_cfg_refr_sync_en_o  <=  per_din_i[15];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   lt24_cfg_refr_sync_val_o <=  10'h000;
  else if (lt24_refresh_sync_wr) lt24_cfg_refr_sync_val_o <=  per_din_i[9:0];

wire [15:0] lt24_refresh_sync = {lt24_cfg_refr_sync_en_o, 5'h00, lt24_cfg_refr_sync_val_o};


//------------------------------------------------
// LT24_CMD Register
//------------------------------------------------
reg  [15:0] lt24_cmd;

wire        lt24_cmd_wr = reg_wr[LT24_CMD];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)          lt24_cmd <=  16'h0000;
  else if (lt24_cmd_wr) lt24_cmd <=  per_din_i;

assign     lt24_cmd_val_o       = lt24_cmd[7:0];
assign     lt24_cmd_has_param_o = lt24_cmd[8];

//------------------------------------------------
// LT24_CMD_PARAM Register
//------------------------------------------------
reg  [15:0] lt24_cmd_param_o;

wire        lt24_cmd_param_wr = reg_wr[LT24_CMD_PARAM];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                lt24_cmd_param_o <=  16'h0000;
  else if (lt24_cmd_param_wr) lt24_cmd_param_o <=  per_din_i;

reg lt24_cmd_param_rdy_o;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lt24_cmd_param_rdy_o <=  1'b0;
  else         lt24_cmd_param_rdy_o <=  lt24_cmd_param_wr;

//------------------------------------------------
// LT24_CMD_DFILL Register
//------------------------------------------------
reg  [15:0] lt24_cmd_dfill_o;

assign      lt24_cmd_dfill_wr_o = reg_wr[LT24_CMD_DFILL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                  lt24_cmd_dfill_o <=  16'h0000;
  else if (lt24_cmd_dfill_wr_o) lt24_cmd_dfill_o <=  per_din_i;

//------------------------------------------------
// LT24_STATUS Register
//------------------------------------------------
wire  [15:0] lt24_status;

assign       lt24_status[0]    = lt24_status_i[0]; // FSM_BUSY
assign       lt24_status[1]    = lt24_status_i[1]; // WAIT_PARAM
assign       lt24_status[2]    = lt24_status_i[2]; // REFRESH_BUSY
assign       lt24_status[3]    = lt24_status_i[3]; // WAIT_FOR_SCANLINE
assign       lt24_status[4]    = lt24_status_i[4]; // DATA_FILL_BUSY
assign       lt24_status[15:5] = 11'h000;


//------------------------------------------------
// LUT_RAM_ADDR Register
//------------------------------------------------
`ifdef WITH_PROGRAMMABLE_LUT

reg  [7:0] lut_ram_addr;
wire [7:0] lut_ram_addr_inc;
wire       lut_ram_addr_inc_wr;

wire       lut_ram_addr_wr = reg_wr[LUT_RAM_ADDR];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                  lut_ram_addr <=  8'h00;
  else if (lut_ram_addr_wr)     lut_ram_addr <=  per_din_i[7:0];
  else if (lut_ram_addr_inc_wr) lut_ram_addr <=  lut_ram_addr_inc;

assign      lut_ram_addr_inc = lut_ram_addr + 8'h01;
wire [15:0] lut_ram_addr_rd  = {8'h00, lut_ram_addr};

 `ifdef WITH_EXTRA_LUT_BANK
   assign lut_ram_addr_o = {lut_bank_select, lut_ram_addr};
 `else
   assign lut_ram_addr_o = lut_ram_addr;
 `endif

`else
wire [15:0] lut_ram_addr_rd  = 16'h0000;
`endif

//------------------------------------------------
// LUT_RAM_DATA Register
//------------------------------------------------
`ifdef WITH_PROGRAMMABLE_LUT

// Update the LUT_RAM_DATA register with regular register write access
wire        lut_ram_data_wr  = reg_wr[LUT_RAM_DATA];
wire        lut_ram_data_rd  = reg_rd[LUT_RAM_DATA];
reg         lut_ram_dout_rdy;

// LUT-RAM data Register
reg  [15:0] lut_ram_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               lut_ram_data <=  16'h0000;
  else if (lut_ram_data_wr)  lut_ram_data <=  per_din_i;
  else if (lut_ram_dout_rdy) lut_ram_data <=  lut_ram_dout_i;

// Increment the address after a write or read access to the LUT_RAM_DATA register
assign lut_ram_addr_inc_wr = lut_ram_data_wr | lut_ram_data_rd;

// Apply peripheral data bus % write strobe during VID_RAMx_DATA write access
assign lut_ram_din_o       =   per_din_i & {16{lut_ram_data_wr}};
assign lut_ram_wen_o       = ~(per_we_i  & { 2{lut_ram_data_wr}});

// Trigger a LUT-RAM read access immediately after:
//   - a LUT-RAM_ADDR register write access
//   - a LUT-RAM_DATA register read access
reg lut_ram_addr_wr_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_addr_wr_dly <= 1'b0;
  else         lut_ram_addr_wr_dly <= lut_ram_addr_wr;

reg  lut_ram_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_data_rd_dly    <= 1'b0;
  else         lut_ram_data_rd_dly    <= lut_ram_data_rd;

// Chip enable.
// Note: we perform a data read access:
//       - one cycle after a VID_RAM_DATA register read access (so that the address has been incremented)
//       - one cycle after a VID_RAM_ADDR register write
assign lut_ram_cen_o = ~(lut_ram_addr_wr_dly | lut_ram_data_rd_dly | // Read access
                         lut_ram_data_wr);                           // Write access

// Update the VRAM_DATA register one cycle after each memory access
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) lut_ram_dout_rdy <= 1'b0;
  else         lut_ram_dout_rdy <= ~lut_ram_cen_o;

`else
wire [15:0] lut_ram_data  = 16'h0000;
`endif

//------------------------------------------------
// FRAME_SELECT Register
//------------------------------------------------

wire  frame_select_wr = reg_wr[FRAME_SELECT];

`ifdef WITH_PROGRAMMABLE_LUT
  reg        refresh_sw_lut_enable;

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)              refresh_sw_lut_enable  <=  1'b0;
    else if (frame_select_wr) refresh_sw_lut_enable  <=  per_din_i[2];
`else
  wire       refresh_sw_lut_enable = 1'b0;
`endif

`ifdef WITH_EXTRA_LUT_BANK
  reg        refresh_sw_lut_select;

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)
      begin
         refresh_sw_lut_select <=  1'b0;
         lut_bank_select       <=  1'b0;
      end
    else if (frame_select_wr)
      begin
         refresh_sw_lut_select <=  per_din_i[3];
         lut_bank_select       <=  per_din_i[15];
      end
`else
  assign refresh_sw_lut_select  =  1'b0;
  wire   lut_bank_select        =  1'b0;
`endif
  wire [1:0] refresh_lut_select_o = {refresh_sw_lut_select, refresh_sw_lut_enable};

`ifdef WITH_FRAME1_POINTER
  `ifdef WITH_FRAME2_POINTER
  reg  [1:0] refresh_frame_select;
  reg  [1:0] vid_ram0_frame_select;
  reg  [1:0] vid_ram1_frame_select;

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)
      begin
         refresh_frame_select  <= 2'h0;
         vid_ram0_frame_select <= 2'h0;
         vid_ram1_frame_select <= 2'h0;
      end
    else if (frame_select_wr)
      begin
         refresh_frame_select  <= per_din_i[1:0];
         vid_ram0_frame_select <= per_din_i[5:4];
         vid_ram1_frame_select <= per_din_i[7:6];
      end

  wire [15:0] frame_select = {lut_bank_select, 7'h00, vid_ram1_frame_select, vid_ram0_frame_select, refresh_lut_select_o, refresh_frame_select};
  `else
  reg        refresh_frame_select;
  reg        vid_ram0_frame_select;
  reg        vid_ram1_frame_select;

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)
      begin
         refresh_frame_select  <= 1'h0;
         vid_ram0_frame_select <= 1'h0;
         vid_ram1_frame_select <= 1'h0;
      end
    else if (frame_select_wr)
      begin
         refresh_frame_select  <= per_din_i[0];
         vid_ram0_frame_select <= per_din_i[4];
         vid_ram1_frame_select <= per_din_i[6];
      end

  wire [15:0] frame_select = {lut_bank_select, 7'h00, 1'h0, vid_ram1_frame_select, 1'h0, vid_ram0_frame_select, refresh_lut_select_o, 1'h0, refresh_frame_select};
  `endif
`else
  wire [15:0] frame_select = {lut_bank_select, 11'h000, refresh_lut_select_o, 2'h0};
`endif

// Frame pointer selections
`ifdef WITH_FRAME1_POINTER
assign refresh_frame_addr_o  = (refresh_frame_select==0)  ? frame0_ptr :
                           `ifdef WITH_FRAME2_POINTER
                               (refresh_frame_select==1)  ? frame1_ptr :
                             `ifdef WITH_FRAME3_POINTER
                               (refresh_frame_select==2)  ? frame2_ptr :
                                                            frame3_ptr ;
                             `else
                                                            frame2_ptr ;
                             `endif
                           `else
                                                            frame1_ptr ;
                           `endif

assign vid_ram0_base_addr    = (vid_ram0_frame_select==0) ? frame0_ptr :
                           `ifdef WITH_FRAME2_POINTER
                               (vid_ram0_frame_select==1) ? frame1_ptr :
                             `ifdef WITH_FRAME3_POINTER
                               (vid_ram0_frame_select==2) ? frame2_ptr :
                                                            frame3_ptr ;
                             `else
                                                            frame2_ptr ;
                             `endif
                           `else
                                                            frame1_ptr ;
                           `endif

assign vid_ram1_base_addr    = (vid_ram1_frame_select==0) ? frame0_ptr :
                           `ifdef WITH_FRAME2_POINTER
                               (vid_ram1_frame_select==1) ? frame1_ptr :
                             `ifdef WITH_FRAME3_POINTER
                               (vid_ram1_frame_select==2) ? frame2_ptr :
                                                            frame3_ptr ;
                             `else
                                                            frame2_ptr ;
                             `endif
                           `else
                                                            frame1_ptr ;
                           `endif

`else
assign refresh_frame_addr_o  = frame0_ptr;
assign vid_ram0_base_addr    = frame0_ptr;
assign vid_ram1_base_addr    = frame0_ptr;
`endif

//------------------------------------------------
// FRAME0_PTR_HI Register
//------------------------------------------------
`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] frame0_ptr_hi;

wire                 frame0_ptr_hi_wr = reg_wr[FRAME0_PTR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame0_ptr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (frame0_ptr_hi_wr) frame0_ptr_hi <=  per_din_i[`VRAM_HI_MSB:0];

wire [16:0] frame0_ptr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}}, frame0_ptr_hi};
wire [15:0] frame0_ptr_hi_rd  = frame0_ptr_hi_tmp[15:0];
`endif

//------------------------------------------------
// FRAME0_PTR_LO Register
//------------------------------------------------
reg  [`VRAM_LO_MSB:0] frame0_ptr_lo;

wire                  frame0_ptr_lo_wr = reg_wr[FRAME0_PTR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)               frame0_ptr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (frame0_ptr_lo_wr) frame0_ptr_lo <=  per_din_i[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      frame0_ptr        = {frame0_ptr_hi[`VRAM_HI_MSB:0], frame0_ptr_lo};
wire [15:0] frame0_ptr_lo_rd  = frame0_ptr_lo;
`else
assign      frame0_ptr        = {frame0_ptr_lo[`VRAM_LO_MSB:0]};
wire [16:0] frame0_ptr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}}, frame0_ptr_lo};
wire [15:0] frame0_ptr_lo_rd  = frame0_ptr_lo_tmp[15:0];
`endif

//------------------------------------------------
// FRAME1_PTR_HI Register
//------------------------------------------------
`ifdef WITH_FRAME1_POINTER
  `ifdef VRAM_BIGGER_64_KW
  reg [`VRAM_HI_MSB:0] frame1_ptr_hi;

  wire                 frame1_ptr_hi_wr = reg_wr[FRAME1_PTR_HI];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame1_ptr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
    else if (frame1_ptr_hi_wr) frame1_ptr_hi <=  per_din_i[`VRAM_HI_MSB:0];

  wire [16:0] frame1_ptr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}}, frame1_ptr_hi};
  wire [15:0] frame1_ptr_hi_rd  = frame1_ptr_hi_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// FRAME1_PTR_LO Register
//------------------------------------------------
`ifdef WITH_FRAME1_POINTER
  reg  [`VRAM_LO_MSB:0] frame1_ptr_lo;

  wire                  frame1_ptr_lo_wr = reg_wr[FRAME1_PTR_LO];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame1_ptr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
    else if (frame1_ptr_lo_wr) frame1_ptr_lo <=  per_din_i[`VRAM_LO_MSB:0];

  `ifdef VRAM_BIGGER_64_KW
  assign      frame1_ptr        = {frame1_ptr_hi[`VRAM_HI_MSB:0], frame1_ptr_lo};
  wire [15:0] frame1_ptr_lo_rd  = frame1_ptr_lo;
  `else
  assign      frame1_ptr        = {frame1_ptr_lo[`VRAM_LO_MSB:0]};
  wire [16:0] frame1_ptr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}}, frame1_ptr_lo};
  wire [15:0] frame1_ptr_lo_rd  = frame1_ptr_lo_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// FRAME2_PTR_HI Register
//------------------------------------------------
`ifdef WITH_FRAME2_POINTER
  `ifdef VRAM_BIGGER_64_KW
  reg [`VRAM_HI_MSB:0] frame2_ptr_hi;

  wire                 frame2_ptr_hi_wr = reg_wr[FRAME2_PTR_HI];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame2_ptr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
    else if (frame2_ptr_hi_wr) frame2_ptr_hi <=  per_din_i[`VRAM_HI_MSB:0];

  wire [16:0] frame2_ptr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}}, frame2_ptr_hi};
  wire [15:0] frame2_ptr_hi_rd  = frame2_ptr_hi_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// FRAME2_PTR_LO Register
//------------------------------------------------
`ifdef WITH_FRAME2_POINTER
  reg  [`VRAM_LO_MSB:0] frame2_ptr_lo;

  wire                  frame2_ptr_lo_wr = reg_wr[FRAME2_PTR_LO];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame2_ptr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
    else if (frame2_ptr_lo_wr) frame2_ptr_lo <=  per_din_i[`VRAM_LO_MSB:0];

  `ifdef VRAM_BIGGER_64_KW
  assign      frame2_ptr        = {frame2_ptr_hi[`VRAM_HI_MSB:0], frame2_ptr_lo};
  wire [15:0] frame2_ptr_lo_rd  = frame2_ptr_lo;
  `else
  assign      frame2_ptr        = {frame2_ptr_lo[`VRAM_LO_MSB:0]};
  wire [16:0] frame2_ptr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}}, frame2_ptr_lo};
  wire [15:0] frame2_ptr_lo_rd  = frame2_ptr_lo_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// FRAME3_PTR_HI Register
//------------------------------------------------
`ifdef WITH_FRAME3_POINTER
  `ifdef VRAM_BIGGER_64_KW
  reg [`VRAM_HI_MSB:0] frame3_ptr_hi;

  wire                 frame3_ptr_hi_wr = reg_wr[FRAME3_PTR_HI];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame3_ptr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
    else if (frame3_ptr_hi_wr) frame3_ptr_hi <=  per_din_i[`VRAM_HI_MSB:0];

  wire [16:0] frame3_ptr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}},frame3_ptr_hi};
  wire [15:0] frame3_ptr_hi_rd  = frame3_ptr_hi_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// FRAME3_PTR_LO Register
//------------------------------------------------
`ifdef WITH_FRAME3_POINTER
  reg  [`VRAM_LO_MSB:0] frame3_ptr_lo;

  wire                  frame3_ptr_lo_wr = reg_wr[FRAME3_PTR_LO];

  always @ (posedge mclk or posedge puc_rst)
    if (puc_rst)               frame3_ptr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
    else if (frame3_ptr_lo_wr) frame3_ptr_lo <=  per_din_i[`VRAM_LO_MSB:0];

  `ifdef VRAM_BIGGER_64_KW
  assign      frame3_ptr        = {frame3_ptr_hi[`VRAM_HI_MSB:0], frame3_ptr_lo};
  wire [15:0] frame3_ptr_lo_rd  = frame3_ptr_lo;
  `else
  assign      frame3_ptr        = {frame3_ptr_lo[`VRAM_LO_MSB:0]};
  wire [16:0] frame3_ptr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}}, frame3_ptr_lo};
  wire [15:0] frame3_ptr_lo_rd  = frame3_ptr_lo_tmp[15:0];
  `endif
`endif

//------------------------------------------------
// VID_RAM0_CFG Register
//------------------------------------------------
reg                vid_ram0_rmw_mode;
reg                vid_ram0_win_mode;
reg                vid_ram0_win_x_swap;
reg                vid_ram0_win_y_swap;
reg                vid_ram0_win_cl_swap;

wire               vid_ram0_cfg_wr = reg_wr[VID_RAM0_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       vid_ram0_rmw_mode     <=  1'b0;
       vid_ram0_win_mode     <=  1'b0;
       vid_ram0_win_x_swap   <=  1'b0;
       vid_ram0_win_y_swap   <=  1'b0;
       vid_ram0_win_cl_swap  <=  1'b0;
    end
  else if (vid_ram0_cfg_wr)
    begin
       vid_ram0_rmw_mode     <=  per_din_i[0];
       vid_ram0_win_mode     <=  per_din_i[1];
       vid_ram0_win_x_swap   <=  per_din_i[4];
       vid_ram0_win_y_swap   <=  per_din_i[5];
       vid_ram0_win_cl_swap  <=  per_din_i[6];
    end

wire [15:0] vid_ram0_cfg  = {8'h00, 1'b0,  vid_ram0_win_cl_swap, vid_ram0_win_y_swap, vid_ram0_win_x_swap,
                                    1'b0,  1'b0,                 vid_ram0_win_mode,   vid_ram0_rmw_mode};

//------------------------------------------------
// VID_RAM0_WIDTH Register
//------------------------------------------------
reg  [`LPIX_MSB:0] vid_ram0_width;

wire               vid_ram0_width_wr = reg_wr[VID_RAM0_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                vid_ram0_width   <=  {`LPIX_MSB+1{1'b0}};
  else if (vid_ram0_width_wr) vid_ram0_width   <=  per_din_i[`LPIX_MSB:0];

wire [16:0] vid_ram0_width_tmp = {{16-`LPIX_MSB{1'b0}}, vid_ram0_width};
wire [15:0] vid_ram0_width_rd  = vid_ram0_width_tmp[15:0];

//------------------------------------------------
// VID_RAM0_ADDR_HI Register
//------------------------------------------------
wire   [`VRAM_MSB:0] vid_ram0_addr;
wire   [`VRAM_MSB:0] vid_ram0_addr_inc;
wire                 vid_ram0_addr_inc_wr;

`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] vid_ram0_addr_hi;

wire                 vid_ram0_addr_hi_wr = reg_wr[VID_RAM0_ADDR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram0_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (vid_ram0_addr_hi_wr)  vid_ram0_addr_hi <=  per_din_i[`VRAM_HI_MSB:0];
  else if (vid_ram0_addr_inc_wr) vid_ram0_addr_hi <=  vid_ram0_addr_inc[`VRAM_MSB:16];

wire [16:0] vid_ram0_addr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}},vid_ram0_addr_hi};
wire [15:0] vid_ram0_addr_hi_rd  = vid_ram0_addr_hi_tmp[15:0];
`endif

//------------------------------------------------
// VID_RAM0_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] vid_ram0_addr_lo;

wire                 vid_ram0_addr_lo_wr = reg_wr[VID_RAM0_ADDR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram0_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (vid_ram0_addr_lo_wr)  vid_ram0_addr_lo <=  per_din_i[`VRAM_LO_MSB:0];
  else if (vid_ram0_addr_inc_wr) vid_ram0_addr_lo <=  vid_ram0_addr_inc[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      vid_ram0_addr        = {vid_ram0_addr_hi[`VRAM_HI_MSB:0], vid_ram0_addr_lo};
wire [15:0] vid_ram0_addr_lo_rd  = vid_ram0_addr_lo;
`else
assign      vid_ram0_addr        = {vid_ram0_addr_lo[`VRAM_LO_MSB:0]};
wire [16:0] vid_ram0_addr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}},vid_ram0_addr_lo};
wire [15:0] vid_ram0_addr_lo_rd  = vid_ram0_addr_lo_tmp[15:0];
`endif

// Compute the next address
omsp_gfx_reg_vram_addr omsp_gfx_reg_vram0_addr_inst (

// OUTPUTs
    .vid_ram_addr_nxt_o      ( vid_ram0_addr_inc       ),   // Next Video-RAM address

// INPUTs
    .mclk                    ( mclk                    ),   // Main system clock
    .puc_rst                 ( puc_rst                 ),   // Main system reset
    .display_width_i         ( display_width_o         ),   // Display width
    .vid_ram_addr_i          ( vid_ram0_addr           ),   // Video-RAM address
    .vid_ram_addr_init_i     ( vid_ram0_addr_lo_wr_dly ),   // Video-RAM address initialization
    .vid_ram_addr_step_i     ( vid_ram0_addr_inc_wr    ),   // Video-RAM address step
    .vid_ram_width_i         ( vid_ram0_width          ),   // Video-RAM width
    .vid_ram_win_mode_i      ( vid_ram0_win_mode       ),   // Video-RAM Windows mode enable
    .vid_ram_win_x_swap_i    ( vid_ram0_win_x_swap     ),   // Video-RAM X-Swap configuration
    .vid_ram_win_y_swap_i    ( vid_ram0_win_y_swap     ),   // Video-RAM Y-Swap configuration
    .vid_ram_win_cl_swap_i   ( vid_ram0_win_cl_swap    )    // Video-RAM CL-Swap configuration
);

//------------------------------------------------
// VID_RAM0_DATA Register
//------------------------------------------------

// Update the VID_RAM0_DATA register with regular register write access
wire        vid_ram0_data_wr     = reg_wr[VID_RAM0_DATA];
wire        vid_ram0_data_rd     = reg_rd[VID_RAM0_DATA];
wire        vid_ram0_dout_rdy;

// VIDEO-RAM data Register
reg  [15:0] vid_ram0_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                vid_ram0_data <=  16'h0000;
  else if (vid_ram0_data_wr)  vid_ram0_data <=  per_din_i;
  else if (vid_ram0_dout_rdy) vid_ram0_data <=  vid_ram_dout_i;

// Make value available in case of early read
wire [15:0] vid_ram0_data_mux = vid_ram0_dout_rdy ? vid_ram_dout_i : vid_ram0_data;


//------------------------------------------------
// VID_RAM1_CFG Register
//------------------------------------------------
reg                vid_ram1_rmw_mode;
reg                vid_ram1_win_mode;
reg                vid_ram1_win_x_swap;
reg                vid_ram1_win_y_swap;
reg                vid_ram1_win_cl_swap;

wire               vid_ram1_cfg_wr = reg_wr[VID_RAM1_CFG];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)
    begin
       vid_ram1_rmw_mode     <=  1'b0;
       vid_ram1_win_mode     <=  1'b0;
       vid_ram1_win_x_swap   <=  1'b0;
       vid_ram1_win_y_swap   <=  1'b0;
       vid_ram1_win_cl_swap  <=  1'b0;
    end
  else if (vid_ram1_cfg_wr)
    begin
       vid_ram1_rmw_mode     <=  per_din_i[0];
       vid_ram1_win_mode     <=  per_din_i[1];
       vid_ram1_win_x_swap   <=  per_din_i[4];
       vid_ram1_win_y_swap   <=  per_din_i[5];
       vid_ram1_win_cl_swap  <=  per_din_i[6];
    end

wire [15:0] vid_ram1_cfg  = {8'h00, 1'b0,  vid_ram1_win_cl_swap, vid_ram1_win_y_swap, vid_ram1_win_x_swap,
                                    1'b0,  1'b0,                 vid_ram1_win_mode,   vid_ram1_rmw_mode};

//------------------------------------------------
// VID_RAM1_WIDTH Register
//------------------------------------------------
reg  [`LPIX_MSB:0] vid_ram1_width;

wire               vid_ram1_width_wr = reg_wr[VID_RAM1_WIDTH];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                vid_ram1_width   <=  {`LPIX_MSB+1{1'b0}};
  else if (vid_ram1_width_wr) vid_ram1_width   <=  per_din_i[`LPIX_MSB:0];

wire [16:0] vid_ram1_width_tmp = {{16-`LPIX_MSB{1'b0}}, vid_ram1_width};
wire [15:0] vid_ram1_width_rd  = vid_ram1_width_tmp[15:0];

//------------------------------------------------
// VID_RAM1_ADDR_HI Register
//------------------------------------------------
wire   [`VRAM_MSB:0] vid_ram1_addr;
wire   [`VRAM_MSB:0] vid_ram1_addr_inc;
wire                 vid_ram1_addr_inc_wr;

`ifdef VRAM_BIGGER_64_KW
reg [`VRAM_HI_MSB:0] vid_ram1_addr_hi;

wire                 vid_ram1_addr_hi_wr = reg_wr[VID_RAM1_ADDR_HI];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram1_addr_hi <=  {`VRAM_HI_MSB+1{1'b0}};
  else if (vid_ram1_addr_hi_wr)  vid_ram1_addr_hi <=  per_din_i[`VRAM_HI_MSB:0];
  else if (vid_ram1_addr_inc_wr) vid_ram1_addr_hi <=  vid_ram1_addr_inc[`VRAM_MSB:16];

wire [16:0] vid_ram1_addr_hi_tmp = {{16-`VRAM_HI_MSB{1'b0}},vid_ram1_addr_hi};
wire [15:0] vid_ram1_addr_hi_rd  = vid_ram1_addr_hi_tmp[15:0];
`endif

//------------------------------------------------
// VID_RAM1_ADDR_LO Register
//------------------------------------------------
reg [`VRAM_LO_MSB:0] vid_ram1_addr_lo;

wire                 vid_ram1_addr_lo_wr = reg_wr[VID_RAM1_ADDR_LO];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                   vid_ram1_addr_lo <=  {`VRAM_LO_MSB+1{1'b0}};
  else if (vid_ram1_addr_lo_wr)  vid_ram1_addr_lo <=  per_din_i[`VRAM_LO_MSB:0];
  else if (vid_ram1_addr_inc_wr) vid_ram1_addr_lo <=  vid_ram1_addr_inc[`VRAM_LO_MSB:0];

`ifdef VRAM_BIGGER_64_KW
assign      vid_ram1_addr        = {vid_ram1_addr_hi[`VRAM_HI_MSB:0], vid_ram1_addr_lo};
wire [15:0] vid_ram1_addr_lo_rd  = vid_ram1_addr_lo;
`else
assign      vid_ram1_addr        = {vid_ram1_addr_lo[`VRAM_LO_MSB:0]};
wire [16:0] vid_ram1_addr_lo_tmp = {{16-`VRAM_LO_MSB{1'b0}},vid_ram1_addr_lo};
wire [15:0] vid_ram1_addr_lo_rd  = vid_ram1_addr_lo_tmp[15:0];
`endif

// Compute the next address
omsp_gfx_reg_vram_addr omsp_gfx_reg_vram1_addr_inst (

// OUTPUTs
    .vid_ram_addr_nxt_o      ( vid_ram1_addr_inc       ),   // Next Video-RAM address

// INPUTs
    .mclk                    ( mclk                    ),   // Main system clock
    .puc_rst                 ( puc_rst                 ),   // Main system reset
    .display_width_i         ( display_width_o         ),   // Display width
    .vid_ram_addr_i          ( vid_ram1_addr           ),   // Video-RAM address
    .vid_ram_addr_init_i     ( vid_ram1_addr_lo_wr_dly ),   // Video-RAM address initialization
    .vid_ram_addr_step_i     ( vid_ram1_addr_inc_wr    ),   // Video-RAM address step
    .vid_ram_width_i         ( vid_ram1_width          ),   // Video-RAM width
    .vid_ram_win_mode_i      ( vid_ram1_win_mode       ),   // Video-RAM Windows mode enable
    .vid_ram_win_x_swap_i    ( vid_ram1_win_x_swap     ),   // Video-RAM X-Swap configuration
    .vid_ram_win_y_swap_i    ( vid_ram1_win_y_swap     ),   // Video-RAM Y-Swap configuration
    .vid_ram_win_cl_swap_i   ( vid_ram1_win_cl_swap    )    // Video-RAM CL-Swap configuration
);

//------------------------------------------------
// VID_RAM1_DATA Register
//------------------------------------------------

// Update the VID_RAM1_DATA register with regular register write access
wire        vid_ram1_data_wr  = reg_wr[VID_RAM1_DATA];
wire        vid_ram1_data_rd  = reg_rd[VID_RAM1_DATA];
wire        vid_ram1_dout_rdy;

// VIDEO-RAM data Register
reg  [15:0] vid_ram1_data;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)                 vid_ram1_data <=  16'h0000;
  else if (vid_ram1_data_wr)   vid_ram1_data <=  per_din_i;
  else if (vid_ram1_dout_rdy)  vid_ram1_data <=  vid_ram_dout_i;

// Make value available in case of early read
wire [15:0] vid_ram1_data_mux = vid_ram1_dout_rdy ? vid_ram_dout_i : vid_ram1_data;


//------------------------------------------------
// GPU Interface (GPU_CMD/GPU_STAT) Registers
//------------------------------------------------

// Write strobe to the GPU fifo
wire  gpu_cmd_wr = reg_wr[GPU_CMD];



wire [15:0] gpu_stat = 16'h0000;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] gfx_ctrl_read          = gfx_ctrl             & {16{reg_rd[GFX_CTRL          ]}};
wire [15:0] gfx_status_read        = gfx_status           & {16{reg_rd[GFX_STATUS        ]}};
wire [15:0] gfx_irq_read           = gfx_irq              & {16{reg_rd[GFX_IRQ           ]}};

wire [15:0] display_width_read     = display_width_rd     & {16{reg_rd[DISPLAY_WIDTH     ]}};
wire [15:0] display_height_read    = display_height_rd    & {16{reg_rd[DISPLAY_HEIGHT    ]}};
`ifdef WITH_DISPLAY_SIZE_HI
wire [15:0] display_size_hi_read   = display_size_hi_rd   & {16{reg_rd[DISPLAY_SIZE_HI   ]}};
`endif
wire [15:0] display_size_lo_read   = display_size_lo_rd   & {16{reg_rd[DISPLAY_SIZE_LO   ]}};
wire [15:0] display_cfg_read       = display_cfg          & {16{reg_rd[DISPLAY_CFG       ]}};

wire [15:0] lt24_cfg_read          = lt24_cfg             & {16{reg_rd[LT24_CFG          ]}};
wire [15:0] lt24_refresh_read      = lt24_refresh         & {16{reg_rd[LT24_REFRESH      ]}};
wire [15:0] lt24_refresh_sync_read = lt24_refresh_sync    & {16{reg_rd[LT24_REFRESH_SYNC ]}};
wire [15:0] lt24_cmd_read          = lt24_cmd             & {16{reg_rd[LT24_CMD          ]}};
wire [15:0] lt24_cmd_param_read    = lt24_cmd_param_o     & {16{reg_rd[LT24_CMD_PARAM    ]}};
wire [15:0] lt24_cmd_dfill_read    = lt24_cmd_dfill_o     & {16{reg_rd[LT24_CMD_DFILL    ]}};
wire [15:0] lt24_status_read       = lt24_status          & {16{reg_rd[LT24_STATUS       ]}};

wire [15:0] lut_ram_addr_read      = lut_ram_addr_rd      & {16{reg_rd[LUT_RAM_ADDR      ]}};
wire [15:0] lut_ram_data_read      = lut_ram_data         & {16{reg_rd[LUT_RAM_DATA      ]}};

wire [15:0] frame_select_read      = frame_select         & {16{reg_rd[FRAME_SELECT      ]}};
`ifdef VRAM_BIGGER_64_KW
wire [15:0] frame0_ptr_hi_read     = frame0_ptr_hi_rd     & {16{reg_rd[FRAME0_PTR_HI     ]}};
`endif
wire [15:0] frame0_ptr_lo_read     = frame0_ptr_lo_rd     & {16{reg_rd[FRAME0_PTR_LO     ]}};
`ifdef WITH_FRAME1_POINTER
  `ifdef VRAM_BIGGER_64_KW
  wire [15:0] frame1_ptr_hi_read   = frame1_ptr_hi_rd     & {16{reg_rd[FRAME1_PTR_HI     ]}};
  `endif
  wire [15:0] frame1_ptr_lo_read   = frame1_ptr_lo_rd     & {16{reg_rd[FRAME1_PTR_LO     ]}};
`endif
`ifdef WITH_FRAME2_POINTER
  `ifdef VRAM_BIGGER_64_KW
  wire [15:0] frame2_ptr_hi_read   = frame2_ptr_hi_rd     & {16{reg_rd[FRAME2_PTR_HI     ]}};
  `endif
  wire [15:0] frame2_ptr_lo_read   = frame2_ptr_lo_rd     & {16{reg_rd[FRAME2_PTR_LO     ]}};
`endif
`ifdef WITH_FRAME3_POINTER
  `ifdef VRAM_BIGGER_64_KW
  wire [15:0] frame3_ptr_hi_read   = frame3_ptr_hi_rd     & {16{reg_rd[FRAME3_PTR_HI     ]}};
  `endif
  wire [15:0] frame3_ptr_lo_read   = frame3_ptr_lo_rd     & {16{reg_rd[FRAME3_PTR_LO     ]}};
`endif
wire [15:0] vid_ram0_cfg_read      = vid_ram0_cfg         & {16{reg_rd[VID_RAM0_CFG      ]}};
wire [15:0] vid_ram0_width_read    = vid_ram0_width_rd    & {16{reg_rd[VID_RAM0_WIDTH    ]}};
`ifdef VRAM_BIGGER_64_KW
wire [15:0] vid_ram0_addr_hi_read  = vid_ram0_addr_hi_rd  & {16{reg_rd[VID_RAM0_ADDR_HI  ]}};
`endif
wire [15:0] vid_ram0_addr_lo_read  = vid_ram0_addr_lo_rd  & {16{reg_rd[VID_RAM0_ADDR_LO  ]}};
wire [15:0] vid_ram0_data_read     = vid_ram0_data_mux    & {16{reg_rd[VID_RAM0_DATA     ]}};

wire [15:0] vid_ram1_cfg_read      = vid_ram1_cfg         & {16{reg_rd[VID_RAM1_CFG      ]}};
wire [15:0] vid_ram1_width_read    = vid_ram1_width_rd    & {16{reg_rd[VID_RAM1_WIDTH    ]}};
`ifdef VRAM_BIGGER_64_KW
wire [15:0] vid_ram1_addr_hi_read  = vid_ram1_addr_hi_rd  & {16{reg_rd[VID_RAM1_ADDR_HI  ]}};
`endif
wire [15:0] vid_ram1_addr_lo_read  = vid_ram1_addr_lo_rd  & {16{reg_rd[VID_RAM1_ADDR_LO  ]}};
wire [15:0] vid_ram1_data_read     = vid_ram1_data_mux    & {16{reg_rd[VID_RAM1_DATA     ]}};
wire [15:0] gpu_cmd_read           = 16'h0000             & {16{reg_rd[GPU_CMD           ]}};
wire [15:0] gpu_stat_read          = gpu_stat             & {16{reg_rd[GPU_STAT          ]}};


wire [15:0] per_dout_o             = gfx_ctrl_read          |
                                     gfx_status_read        |
                                     gfx_irq_read           |

                                     display_width_read     |
                                     display_height_read    |
                                  `ifdef WITH_DISPLAY_SIZE_HI
                                     display_size_hi_read   |
                                  `endif
                                     display_size_lo_read   |
                                     display_cfg_read       |

                                     lt24_cfg_read          |
                                     lt24_refresh_read      |
                                     lt24_refresh_sync_read |
                                     lt24_cmd_read          |
                                     lt24_cmd_param_read    |
                                     lt24_cmd_dfill_read    |
                                     lt24_status_read       |

                                     lut_ram_addr_read      |
                                     lut_ram_data_read      |

                                     frame_select_read      |
                                  `ifdef VRAM_BIGGER_64_KW
                                     frame0_ptr_hi_read     |
                                  `endif
                                     frame0_ptr_lo_read     |
                                `ifdef WITH_FRAME1_POINTER
                                  `ifdef VRAM_BIGGER_64_KW
                                     frame1_ptr_hi_read     |
                                  `endif
                                     frame1_ptr_lo_read     |
                                `endif
                                `ifdef WITH_FRAME2_POINTER
                                  `ifdef VRAM_BIGGER_64_KW
                                     frame2_ptr_hi_read     |
                                  `endif
                                     frame2_ptr_lo_read     |
                                `endif
                                `ifdef WITH_FRAME3_POINTER
                                  `ifdef VRAM_BIGGER_64_KW
                                     frame3_ptr_hi_read     |
                                  `endif
                                     frame3_ptr_lo_read     |
                                `endif
                                     vid_ram0_cfg_read      |
                                     vid_ram0_width_read    |
                                  `ifdef VRAM_BIGGER_64_KW
                                     vid_ram0_addr_hi_read  |
                                  `endif
                                     vid_ram0_addr_lo_read  |
                                     vid_ram0_data_read     |

                                     vid_ram1_cfg_read      |
                                     vid_ram1_width_read    |
                                  `ifdef VRAM_BIGGER_64_KW
                                     vid_ram1_addr_hi_read  |
                                  `endif
                                     vid_ram1_addr_lo_read  |
                                     vid_ram1_data_read     |
                                     gpu_cmd_read           |
                                     gpu_stat_read;


//============================================================================
// 5) VIDEO MEMORY INTERFACE
//============================================================================
//
// Trigger a VIDEO-RAM write access after:
//   - a VID_RAMx_DATA register write access
//
// Trigger a VIDEO-RAM read access immediately after:
//   - a VID_RAMx_ADDR_LO register write access
//   - a VID_RAMx_DATA register read access
//

//--------------------------------------------------
// VID_RAM0: Delay software read and write strobes
//--------------------------------------------------

// Strobe writing to VID_RAMx_ADDR_LO register
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_addr_lo_wr_dly <= 1'b0;
  else         vid_ram0_addr_lo_wr_dly <= vid_ram0_addr_lo_wr;

// Strobe reading from VID_RAMx_DATA register
reg        vid_ram0_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_data_rd_dly    <= 1'b0;
  else         vid_ram0_data_rd_dly    <= vid_ram0_data_rd;

// Strobe writing to VID_RAMx_DATA register
reg  [1:0] vid_ram0_data_wr_dly;
wire [1:0] vid_ram0_data_wr_nodly = per_we_i & {2{vid_ram0_data_wr}};
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_data_wr_dly    <= 2'b00;
  else         vid_ram0_data_wr_dly    <= vid_ram0_data_wr_nodly;

//--------------------------------------------------
// VID_RAM1: Delay software read and write strobes
//--------------------------------------------------

// Strobe writing to VID_RAMx_ADDR_LO register
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_addr_lo_wr_dly <= 1'b0;
  else         vid_ram1_addr_lo_wr_dly <= vid_ram1_addr_lo_wr;

// Strobe reading from VID_RAMx_DATA register
reg        vid_ram1_data_rd_dly;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_data_rd_dly    <= 1'b0;
  else         vid_ram1_data_rd_dly    <= vid_ram1_data_rd;

// Strobe writing to VID_RAMx_DATA register
reg  [1:0] vid_ram1_data_wr_dly;
wire [1:0] vid_ram1_data_wr_nodly = per_we_i & {2{vid_ram1_data_wr}};
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_data_wr_dly    <= 2'b00;
  else         vid_ram1_data_wr_dly    <= vid_ram1_data_wr_nodly;

//------------------------------------------------
// Compute VIDEO-RAM Strobes & Data
//------------------------------------------------

// Write access strobe
//       - one cycle after a VID_RAM_DATA register write access
assign vid_ram_wen_o  = ~(vid_ram0_data_wr_dly | vid_ram1_data_wr_dly);

// Chip enable.
// Note: we perform a data read access:
//       - one cycle after a VID_RAM_DATA register read access (so that the address has been incremented)
//       - one cycle after a VID_RAM_ADDR_LO register write
wire    vid_ram0_ce_early = (vid_ram0_addr_lo_wr | vid_ram0_data_rd_dly | // Read access
                             vid_ram0_data_wr);                           // Write access

wire    vid_ram1_ce_early = (vid_ram1_addr_lo_wr | vid_ram1_data_rd_dly | // Read access
                             vid_ram1_data_wr);                           // Write access

reg [1:0] vid_ram0_ce;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram0_ce <= 2'b00;
  else         vid_ram0_ce <= {vid_ram0_ce[0], vid_ram0_ce_early};

reg [1:0] vid_ram1_ce;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst) vid_ram1_ce <= 2'b00;
  else         vid_ram1_ce <= {vid_ram1_ce[0], vid_ram1_ce_early};

assign vid_ram_cen_o  = ~(vid_ram0_ce[0] | vid_ram1_ce[0]);

// Data to be written
assign vid_ram_din_o  = vid_ram1_ce[0] ? vid_ram1_data : vid_ram0_data;

// Update the VRAM_DATA register one cycle after each memory access
assign vid_ram0_dout_rdy = vid_ram0_ce[1];
assign vid_ram1_dout_rdy = vid_ram1_ce[1];

//------------------------------------------------
// Compute VIDEO-RAM Address
//------------------------------------------------

// Mux ram address for early read access when ADDR_LO is updated
`ifdef VRAM_BIGGER_64_KW
wire [`VRAM_MSB:0] vid_ram0_addr_mux = vid_ram0_addr_lo_wr ? {vid_ram0_addr[`VRAM_MSB:16], per_din_i} : vid_ram0_addr;
wire [`VRAM_MSB:0] vid_ram1_addr_mux = vid_ram1_addr_lo_wr ? {vid_ram1_addr[`VRAM_MSB:16], per_din_i} : vid_ram1_addr;
`else
wire [`VRAM_MSB:0] vid_ram0_addr_mux = vid_ram0_addr_lo_wr ? {per_din_i[`VRAM_LO_MSB:0]}              : vid_ram0_addr;
wire [`VRAM_MSB:0] vid_ram1_addr_mux = vid_ram1_addr_lo_wr ? {per_din_i[`VRAM_LO_MSB:0]}              : vid_ram1_addr;
`endif

// Add frame pointer offset
wire [`VRAM_MSB:0] vid_ram0_addr_offset = vid_ram0_base_addr + vid_ram0_addr_mux;
wire [`VRAM_MSB:0] vid_ram1_addr_offset = vid_ram1_base_addr + vid_ram1_addr_mux;

// Detect memory accesses for ADDR update
wire               vid_ram0_access      = vid_ram0_data_wr | vid_ram0_data_rd_dly | vid_ram0_addr_lo_wr;
wire               vid_ram1_access      = vid_ram1_data_wr | vid_ram1_data_rd_dly | vid_ram1_addr_lo_wr;

// Generate Video RAM address
reg [`VRAM_MSB:0] vid_ram_addr_o;
always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)              vid_ram_addr_o <= {`VRAM_AWIDTH{1'b0}};
  else if (vid_ram0_access) vid_ram_addr_o <= vid_ram0_addr_offset;
  else if (vid_ram1_access) vid_ram_addr_o <= vid_ram1_addr_offset;

// Increment the address when accessing the VID_RAMx_DATA register:
// - one clock cycle after a write access
// - with the read access
assign vid_ram0_addr_inc_wr = vid_ram0_addr_lo_wr_dly | (|vid_ram0_data_wr_dly) | (vid_ram0_data_rd & ~dbg_freeze_i & ~vid_ram0_rmw_mode);
assign vid_ram1_addr_inc_wr = vid_ram1_addr_lo_wr_dly | (|vid_ram1_data_wr_dly) | (vid_ram1_data_rd & ~dbg_freeze_i & ~vid_ram1_rmw_mode);


endmodule // omsp_gfx_reg

`ifdef OMSP_GFX_CONTROLLER_NO_INCLUDE
`else
`include "omsp_gfx_controller_undefines.v"
`endif