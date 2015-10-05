////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 3.5
//  \   \         Application : 7 Series FPGAs Transceivers Wizard 
//  /   /         Filename : gtwizard_0_tx_manual_phase_align.v
// /___/   /\     
// \   \  /  \ 
//  \___\/\___\ 
//
//
//  Description :     This module performs TX Buffer Phase Alignment in Manual Mode.
//                     
//
//
// Module gtwizard_0_tx_manual_phase_align
// Generated by Xilinx 7 Series FPGAs Transceivers Wizard
// 
// 
// (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


//*****************************************************************************

`timescale 1ns / 1ps
`define DLY #1

module gtwizard_0_TX_MANUAL_PHASE_ALIGN  #
(
          parameter NUMBER_OF_LANES         = 4,  // Number of lanes that are controlled using this FSM.
          parameter MASTER_LANE_ID          = 0   // Number of the lane which is considered the master in manual phase-alignment
)
(
          input     wire                        STABLE_CLOCK,              //Stable Clock, either a stable clock from the PCB
                                                                            //or reference-clock present at startup.
          input     wire                        RESET_PHALIGNMENT,
          input     wire                        RUN_PHALIGNMENT,
          output    reg                         PHASE_ALIGNMENT_DONE = 1'b0,       // Manual phase-alignment performed sucessfully  
          output    reg  [NUMBER_OF_LANES-1:0]  TXDLYSRESET = {NUMBER_OF_LANES{1'b0}},
          input     wire [NUMBER_OF_LANES-1:0]  TXDLYSRESETDONE,
          output    reg  [NUMBER_OF_LANES-1:0]  TXPHINIT = {NUMBER_OF_LANES{1'b0}},
          input     wire [NUMBER_OF_LANES-1:0]  TXPHINITDONE,
          output    reg  [NUMBER_OF_LANES-1:0]  TXPHALIGN = {NUMBER_OF_LANES{1'b0}},
          input     wire [NUMBER_OF_LANES-1:0]  TXPHALIGNDONE,
          output    reg  [NUMBER_OF_LANES-1:0]  TXDLYEN = {NUMBER_OF_LANES{1'b0}}
);


  genvar j;
  wire [NUMBER_OF_LANES-1:0] VCC_VEC = {NUMBER_OF_LANES{1'b1}};
  wire [NUMBER_OF_LANES-1:0] GND_VEC = {NUMBER_OF_LANES{1'b0}};

  reg  [NUMBER_OF_LANES-1:0] txphaligndone_prev = {NUMBER_OF_LANES{1'b0}}; 
  wire [NUMBER_OF_LANES-1:0] txphaligndone_sync; 
  wire [NUMBER_OF_LANES-1:0] txphinitdone_sync; 
  wire [NUMBER_OF_LANES-1:0] txdlysresetdone_sync; 
  wire [NUMBER_OF_LANES-1:0] txphaligndone_ris_edge;
  reg  [NUMBER_OF_LANES-1:0] txphinitdone_prev = {NUMBER_OF_LANES{1'b0}};
  wire [NUMBER_OF_LANES-1:0] txphinitdone_ris_edge;
  reg  [NUMBER_OF_LANES-1:0] txphinitdone_store_edge= {NUMBER_OF_LANES{1'b0}};
  reg  [NUMBER_OF_LANES-1:0] txdlysresetdone_store= {NUMBER_OF_LANES{1'b0}};
  reg  [NUMBER_OF_LANES-1:0] txphaligndone_store = {NUMBER_OF_LANES{1'b0}};
  reg                        txdone_clear = 1'b0;
  reg                        txphinitdone_clear_slave = 1'b0;

  integer i;

  localparam [3:0] 
        INIT            = 4'b0000,
        WAIT_PHRST_DONE = 4'b0001,
        M_PHINIT        = 4'b0010,
        M_PHALIGN       = 4'b0011,
        M_DLYEN         = 4'b0100,
        S_PHINIT        = 4'b0101,
        S_PHALIGN       = 4'b0110,
        M_DLYEN2        = 4'b0111,
        PHALIGN_DONE    = 4'b1000;
    
  reg [3:0] tx_phalign_manual_state = INIT;


  //Clock Domain Crossing

 generate
  for (j = 0;j <= NUMBER_OF_LANES-1;j = j+1) 
 begin : cdc

 gtwizard_0_sync_block sync_TXPHALIGNDONE
        (
           .clk             (STABLE_CLOCK),
           .data_in         (TXPHALIGNDONE[j]),
           .data_out        (txphaligndone_sync[j])
        );

 gtwizard_0_sync_block sync_TXDLYSRESETDONE
        (
           .clk             (STABLE_CLOCK),
           .data_in         (TXDLYSRESETDONE[j]),
           .data_out        (txdlysresetdone_sync[j])
        );

 gtwizard_0_sync_pulse sync_TXPHINITDONE
       (
           .CLK             (STABLE_CLOCK),
           .GT_DONE         (TXPHINITDONE[j]),
           .USER_DONE       (txphinitdone_sync[j])
        );

  end //cdc 
 endgenerate

  always @(posedge STABLE_CLOCK)
  begin
      txphaligndone_prev  <= `DLY  txphaligndone_sync;    
      txphinitdone_prev   <= `DLY  txphinitdone_sync;
  end
  
 generate
  for (j = 0;j <= NUMBER_OF_LANES-1;j = j+1) 
 begin : rising_edge_detect
  assign txphaligndone_ris_edge[j] = ((txphaligndone_prev[j] == 0) && (txphaligndone_sync[j] == 1))  ? 1'b1 : 1'b0;
  assign txphinitdone_ris_edge[j]  = ((txphinitdone_prev[j] == 0) && (txphinitdone_sync[j] == 1))  ? 1'b1 : 1'b0;
  end //rising_edge_detect 
 endgenerate

  always @(posedge STABLE_CLOCK)
  begin
      if (txdone_clear) 
      begin
        txdlysresetdone_store <= `DLY  GND_VEC;
        txphaligndone_store   <= `DLY  GND_VEC;
      end

      else
      begin
        for (i = 0; i <= NUMBER_OF_LANES-1; i = i+1) 
        begin
          if (txdlysresetdone_sync[i] == 1'b1)
            txdlysresetdone_store[i] <= `DLY  1'b1;

          if (txphaligndone_ris_edge[i] == 1'b1)
             txphaligndone_store[i]  <= `DLY  1'b1;
        end 
      end
  end


  always @(posedge STABLE_CLOCK)
  begin
      if (txphinitdone_clear_slave == 1'b1) 
      begin
        //Only clear the TXPHINITDONE-storage from the slaves.
        txphinitdone_store_edge                 <= `DLY  GND_VEC;
        //The information stored on the MASTER_LANE_ID is used differently. The way txphinitdone_store_edge
        //is coded, it will be optimised away afterwards. It is only for simplicity of the code on the checks
        //that the master-lane is "recorded" too.
        txphinitdone_store_edge[MASTER_LANE_ID] <= `DLY  1'b1;
      end

      else
      begin
        for (i = 0; i <= NUMBER_OF_LANES-1; i = i+1) 
        begin
          if (txphinitdone_ris_edge[i] == 1'b1)
            txphinitdone_store_edge[i] <= `DLY  1'b1;
        end
      end
  end 


  always @(posedge STABLE_CLOCK)
  begin
      if (RESET_PHALIGNMENT)
      begin
        PHASE_ALIGNMENT_DONE    <= `DLY  0;
        TXDLYSRESET             <= `DLY  {NUMBER_OF_LANES{1'b0}};
        TXPHINIT                <= `DLY  {NUMBER_OF_LANES{1'b0}};
        TXPHALIGN               <= `DLY  {NUMBER_OF_LANES{1'b0}};
        TXDLYEN                 <= `DLY  {NUMBER_OF_LANES{1'b0}};
        tx_phalign_manual_state <= `DLY  INIT;
        txphinitdone_clear_slave  <= `DLY  1'b1;
        txdone_clear              <= `DLY  1'b1;

      end
      else
      begin    
        case (tx_phalign_manual_state)
           INIT :
          begin 
            PHASE_ALIGNMENT_DONE      <= `DLY  1'b0;
            txphinitdone_clear_slave  <= `DLY  1'b1;
            txdone_clear              <= `DLY  1'b1;
            if (RUN_PHALIGNMENT)
            begin 
              //TXDLYSRESET is toggled to '1'
              TXDLYSRESET               <= `DLY  {NUMBER_OF_LANES{1'b1}};
              txphinitdone_clear_slave  <= `DLY  1'b0;
              txdone_clear              <= `DLY  1'b0;
              tx_phalign_manual_state   <= `DLY  WAIT_PHRST_DONE;
            end       
          end 
           WAIT_PHRST_DONE : 
          begin
            //Assert TXDLYSRESET for all lanes, hold high until 
            //TXDLYSRESETDONE of the respective lane is asserted.
            for (i = 0; i <= NUMBER_OF_LANES-1; i = i+1) 
            begin
              if (txdlysresetdone_store[i]) 
                //Deassert TXDLYSRESET for the lane in which 
                //the TXDLYSRESETDONE is asserted:
                TXDLYSRESET[i] <= `DLY  1'b0;
            end 
            if (txdlysresetdone_store == VCC_VEC) begin
              //When all TXDLYSRESETDONE-signals are asserted, move 
              //to the next state.
              tx_phalign_manual_state   <= `DLY  M_PHINIT;
          end
          end
           M_PHINIT :
           begin 
            //Assert TXPHINIT on the master and hold high until a
            //rising edge on TXPHINITDONE is detected:
            TXPHINIT[MASTER_LANE_ID] <= `DLY  1'b1;
            if (txphinitdone_ris_edge[MASTER_LANE_ID])
            begin
              //Then deassert TXPHINIT and move to the next state.
              TXPHINIT[MASTER_LANE_ID]  <= `DLY  1'b0;
              tx_phalign_manual_state   <= `DLY  M_PHALIGN;
            end 
           end
           M_PHALIGN :
           begin 
            //Assert TXPHALIGN on the master and hold high until a 
            //rising edge on TXPHALIGNDONE is detected:
            TXPHALIGN[MASTER_LANE_ID] <= `DLY  1'b1;
            if (txphaligndone_ris_edge[MASTER_LANE_ID])
            begin 
              //Then dassert TXPHALIGN and move to the next state.
              TXPHALIGN[MASTER_LANE_ID] <= `DLY  1'b0;
              tx_phalign_manual_state   <= `DLY  M_DLYEN;
            end
           end
           M_DLYEN : 
           begin
            //Assert TXDLYEN on the master and hold high until a
            //rising edge on TXPHALIGNDONE is detected.
            TXDLYEN[MASTER_LANE_ID] <= `DLY  1'b1;
            if (txphaligndone_ris_edge[MASTER_LANE_ID])
            begin
              if(NUMBER_OF_LANES >1)
              begin
                //Then deassert TXDLYEN and move to the next state.
                TXDLYEN[MASTER_LANE_ID]   <= `DLY  1'b0;
                tx_phalign_manual_state   <= `DLY S_PHINIT;
              end
              else
                tx_phalign_manual_state   <= `DLY PHALIGN_DONE;
            end
           end
           S_PHINIT :
           begin 
            //Assert TXPHINIT for all slave lane(s). Hold this 
            //signal High until TXPHINITDONE of the respective 
            //slave lane is asserted.
            TXPHINIT       <= `DLY  {NUMBER_OF_LANES{1'b1}}; //--\Assert only the PHINIT-signal
            TXPHINIT[MASTER_LANE_ID] <= `DLY  1'b0;          //--/the slaves.

            for (i = 0;i <= NUMBER_OF_LANES-1;i = i+1)
            begin
              if (txphinitdone_store_edge[i])
                //Deassert TXPHINIT for the slave lane in which 
                //the TXPHINITDONE is asserted.
                TXPHINIT[i] <= `DLY  1'b0;
            end
            if (txphinitdone_store_edge == VCC_VEC)
            begin
              //When all TXPHINITDONE-signals are high and at least one rising edge
              //has been detected, move to the next state.
              //The reason for checking of the occurance of at least one rising edge
              //is to avoid the potential direct move where TXPHINITDONE might not 
              //be going low fast enough. 
              tx_phalign_manual_state   <= `DLY  S_PHALIGN;
                            
            end
           end
           S_PHALIGN :
           begin
            //Assert TXPHALIGN for all slave lane(s). Hold this signal High 
            //until TXPHALIGNDONE of the respective slave lane is asserted.
               TXPHALIGN                 <= `DLY  {NUMBER_OF_LANES{1'b1}};//again only assertion for slave
               TXPHALIGN[MASTER_LANE_ID] <= `DLY  1'b0;                   //but not for master

            for (i = 0;i <= NUMBER_OF_LANES-1;i = i+1)
            begin
              if (txphaligndone_store[i])
                //Deassert TXPHALIGN for the slave lane in which the 
                //TXPHALIGNDONE is asserted.
                TXPHALIGN[i] <= `DLY  1'b0;
            end
            if (txphaligndone_store == VCC_VEC)
              //When all TXPHALIGNDONE-signals are asserted high, move to the next
              //state.
              tx_phalign_manual_state   <= `DLY  M_DLYEN2;
            end
           M_DLYEN2 :
           begin 
            //Assert TXDLYEN for the master lane. This causes TXPHALIGNDONE of 
            //the master lane to be deasserted.
            TXDLYEN[MASTER_LANE_ID] <= `DLY  1'b1;
            if (txphaligndone_ris_edge[MASTER_LANE_ID]) 
              //Wait until TXPHALIGNDONE of the master lane reasserts. Phase 
              //and delay alignment for the multilane interface is complete. 
              tx_phalign_manual_state   <= `DLY  PHALIGN_DONE;
           end
           PHALIGN_DONE :
           begin 
            //Continue to hold TXDLYEN for the master lane High to adjust 
            //TXUSRCLK to compensate for temperature and voltage variations.
            TXDLYEN[MASTER_LANE_ID] <= `DLY  1'b1;
            PHASE_ALIGNMENT_DONE    <= `DLY  1'b1;
           end

           default:
             tx_phalign_manual_state <= `DLY  INIT;

        endcase      
      end
    end 

endmodule

