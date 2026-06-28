# Sklansky-parameterized-Adder
Parameterized 64-bit Sklansky parallel-prefix adder written in Verilog, with a self-checking testbench validating against random and edge-case inputs. Uses reduced generate-only prefix cells at high-fanout tree nodes to cut gate count versus a full Kogge-Stone-style network, while keeping O(log2 N) carry computation depth.
