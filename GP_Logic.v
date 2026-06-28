`timescale 1ns / 1ps

module  GP_Logic # (parameter bits = 64)(
    input [bits - 1:0] X , Y ,
    output[bits - 1:0] g , p
    );
    assign g = X & Y ;
    assign p = X ^ Y ;
endmodule
