`timescale 1ns / 1ps

module SUM_logic #(parameter bits = 64)(
    input [ bits - 1 : 0 ] C , p ,
    output [ bits - 1 : 0 ] SUM
    );
    
    assign SUM = C ^ p ;
endmodule
