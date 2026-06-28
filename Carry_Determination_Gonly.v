`timescale 1ns / 1ps

module Carry_Determination_Gonly(
    input [1:0] g,
    input p,
    output G
    );
assign G = g[1] | g[0]&p ;
endmodule
