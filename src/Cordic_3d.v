// Copyright (c) 2026 Sin-Yuan Chao and Min-Lun Tsou.
// SPDX-License-Identifier: MIT

module Cordic_3d (
    input clk,
    input rst_n,

    input iStart,
    output oDone,

    input signed [15:0] iAlpha,
    input signed [15:0] iBeta,
    input signed [15:0] iGamma,

    input signed [15:0] iX,
    input signed [15:0] iY,
    input signed [15:0] iZ,

    output signed [15:0] oX,
    output signed [15:0] oY,
    output signed [15:0] oZ
);

// Stage 1: rotate the XY plane about Z.
wire alphaDone;
wire [15:0] alphaX, alphaY, alphaZ;
wire [15:0] alphaBeta, alphaGamma;
Cordic_Vec alpha (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(iStart),
    .iAngle(iAlpha),
    .iX(iX),
    .iY(iY),

    .oX(alphaX),
    .oY(alphaY),

    .oDone(alphaDone)
);

PipeLatch #(.size(16+16+16)) alphaLatch (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(iStart),
    .iDone(alphaDone),

    .iData({iBeta, iGamma, iZ}),
    .oData({alphaBeta, alphaGamma, alphaZ})
);

// Stage 2: rotate the YZ plane about X.
wire betaDone;
wire [15:0] betaX, betaY, betaZ;
wire [15:0] betaGamma;
Cordic_Vec beta (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(alphaDone),
    .iAngle(alphaBeta),
    .iX(alphaY),
    .iY(alphaZ),

    .oX(betaY),
    .oY(betaZ),

    .oDone(betaDone)
);

PipeLatch #(.size(16+16)) betaLatch (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(alphaDone),
    .iDone(betaDone),

    .iData({alphaGamma, alphaX}),
    .oData({betaGamma, betaX})
);

// Stage 3: rotate the ZX plane about Y.
wire gammaDone;
wire [15:0] gammaX, gammaY, gammaZ;
Cordic_Vec gamma (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(betaDone),
    .iAngle(betaGamma),
    .iX(betaZ),
    .iY(betaX),

    .oX(gammaZ),
    .oY(gammaX),

    .oDone(gammaDone)
);

PipeLatch #(.size(16)) gammaLatch (
    .clk(clk),
    .rst_n(rst_n),

    .iStart(betaDone),
    .iDone(gammaDone),

    .iData(betaY),
    .oData(gammaY)
);

assign oX = gammaX;
assign oY = gammaY;
assign oZ = gammaZ;
assign oDone = gammaDone;

endmodule
