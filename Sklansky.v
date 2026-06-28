`timescale 1ns / 1ps


module Sklansky #(parameter bits = 64)(
    input [bits-1:0] A,B,
    input Cin,
    output [bits-1:0] SUM ,
    output Cout 
);
wire [bits-1:0] g_internal [0 : $clog2(bits/2)] ;
wire [bits-1:0] p_internal [0 : $clog2(bits/2)] ;
// generate and propagate logic
wire [bits-1:0] g,p;
GP_Logic # (.bits(bits)) GP_block(.X(A) ,.Y(B) ,.g(g) ,.p(p));

//carry network using Brent and kung
Carry_Determination CD_Cin (.g({g[0],Cin}),.p({p[0],1'b1}),.G(g_internal[0][0]),.P(p_internal[0][0]));
Carry_Determination CD_C0 (.g({g[1],g_internal[0][0]}),.p({p[1],p_internal[0][0]}),.G(g_internal[0][1]),.P(p_internal[0][1]));
genvar i , n , z , m;
generate
// make the first row (cin , first row first group)
for(i=3;i<bits;i=i+2)
begin : first
    Carry_Determination CD_1(.g({g[i],g[i-1]}),.p({p[i],p[i-1]}),.G(g_internal[0][i]),.P(p_internal[0][i]));
    assign g_internal[0][i-1] = g[i-1];
    assign p_internal[0][i-1] = p[i-1];
end
for (n=2;n<bits;n=n<<1)
begin : CD_network
 for (z=n;z<bits;z=z+2*n)
       begin
       if(z==n)
       begin
       for (m=z;m<z+n;m=m+1)begin
            Carry_Determination_Gonly  CD_only_G (.g({g_internal[$clog2(n)-1][m],g_internal[$clog2(n)-1][z-1]}),.p(p_internal[$clog2(n)-1][m]),.G(g_internal[$clog2(n)][m]));
       end      
       end
       else
       begin
       for (m=z;m<z+n;m=m+1)begin
            Carry_Determination  CD (.g({g_internal[$clog2(n)-1][m],g_internal[$clog2(n)-1][z-1]}),.p({p_internal[$clog2(n)-1][m],p_internal[$clog2(n)-1][z-1]}),.G(g_internal[$clog2(n)][m]),.P(p_internal[$clog2(n)][m]));
       end
       end
       end
 for (z=0;z<bits;z=z+2*n)
     begin
     for (m=z;m<z+n;m=m+1)begin
         assign g_internal[$clog2(n)][m] = g_internal[$clog2(n) -1][m];
         assign p_internal[$clog2(n)][m] = p_internal[$clog2(n) -1][m];
         end
     end
end
endgenerate
SUM_logic #(.bits(bits)) SUM_block(.C({g_internal[$clog2(bits/2)][bits-2:0],Cin}) , .p(p) ,.SUM(SUM));
assign Cout = g_internal[$clog2(bits/2)][bits-1];
endmodule
