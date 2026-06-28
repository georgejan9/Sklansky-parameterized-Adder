`timescale 1ns / 1ps

module Sklansky_tb();
    reg clk;
    reg [63 : 0] A , B ;
    reg Cin ;
    wire [64 : 0] result ;
//DUT
Sklansky #(.bits(64)) DUT(.A(A) , .B(B) ,.Cin(Cin) ,.SUM(result[63:0]) ,.Cout(result[64]));

//clk
initial
begin 
clk=0;
forever #5 clk=~clk;
end
//test cases
integer i;
initial
begin
    for(i=0;i<90;i=i+1)
    begin
        A = {$random, $random};
        B = {$random, $random};
        Cin = $random & 1;
        #10;
        if (result !== ({1'b0,A} + {1'b0,B} + Cin))
        begin
            $display("Test Fails");
            $finish;
        end
    end
    A = {$random, $random};
    B = {$random, $random};
    Cin = $random & 1;
    #10;
    if (result !== ({1'b0,A} + {1'b0,B} + Cin))
    begin
        $display("Test Fails");
        $finish;
    end
    
    A = 0;
    B = 0;
    Cin = 0;
    #10;
    if (result !== ({1'b0,A} + {1'b0,B} + Cin))
    begin
        $display("Test Fails");
        $finish;
    end
    
    A = 0;
    B = 0;
    Cin = 1;
    #10;
    if (result !== ({1'b0,A} + {1'b0,B} + Cin))
    begin
        $display("Test Fails");
        $finish;
    end
    
    A = 'hffff_ffff_ffff_ffff;
    B = 'hffff_ffff_ffff_ffff;
    Cin = 1;
    #10;
    if (result !== ({1'b0,A} + {1'b0,B} + Cin))
    begin
        $display("Test Fails");
        $finish;
    end
    
    A = 'hffff_ffff_ffff_ffff;
    B = 'hffff_ffff_ffff_ffff;
    Cin = 0;
    #10;
    if (result !== ({1'b0,A} + {1'b0,B} + Cin))
    begin
        $display("Test Fails");
        $finish;
    end
$display("Test pass");
#10;
$finish;
end

//monitor 
initial 
    $monitor ("A = %d , B = %d , Cin = %d , Actual Result = %d , Correct result = %d",A,B,Cin,result,({1'b0,A} + {1'b0,B} + Cin));

endmodule
