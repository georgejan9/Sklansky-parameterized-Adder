`timescale 1ns / 1ps

module Carry_Determination(
    input [1:0] g,p,
    output G,P
    );
assign G = g[1] | g[0]&p[1] ;
assign P = &p;
endmodule
