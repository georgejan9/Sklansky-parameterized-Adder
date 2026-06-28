# 64-bit Sklansky Adder (Verilog)

A parameterized, fully synthesizable **Sklansky parallel prefix adder** implemented in Verilog, with a self-checking testbench that verifies correctness against random and edge-case inputs.

The Sklansky adder is a parallel prefix adder that computes carries in **O(log₂N)** logic depth, just like Kogge-Stone, but uses far fewer prefix-combine cells by trading off fanout — some cells drive an increasing number of downstream bits as the tree grows. To keep the critical path fast despite this high fanout, the design uses **generate-only (G-only)** prefix cells at the most fanout-heavy points in the tree, where the propagate signal isn't actually needed downstream.

## Architecture

| Module | File | Description |
|---|---|---|
| `GP_Logic` | `GP_Logic.v` | Computes bitwise **generate** (`g = A & B`) and **propagate** (`p = A ^ B`) signals for each bit position. |
| `Carry_Determination` | `Carry_Determination.v` | The standard prefix-combine cell: merges two (G, P) pairs into one using `G = g1 \| (g0 & p1)` and `P = p1 & p0`. Used wherever both an updated generate *and* propagate signal are needed for later stages. |
| `Carry_Determination_Gonly` | `Carry_Determination_Gonly.v` | A reduced prefix-combine cell that only computes `G = g1 \| (g0 & p1)`, dropping the propagate output. Used at the root of each fanout group in the Sklansky tree, where the propagate signal is never consumed again — saving logic compared to using the full `Carry_Determination` cell everywhere. |
| `SUM_logic` | `SUM_logic.v` | Final sum computation: `SUM = C ^ p`, where `C` is the carry-into-each-bit vector produced by the prefix tree. |
| `Sklansky` | `Sklansky.v` | Top-level module. Wires together the GP stage, the log₂(N)-depth Sklansky carry network (built with `generate`/`for` loops, mixing `Carry_Determination` and `Carry_Determination_Gonly` cells), and the final sum stage. Parameterized by `bits` (default 64). |
| `Sklansky_tb` | `Sklansky_tb.v` | Self-checking testbench: drives 90+ random 64-bit operand pairs plus carry-in, plus directed edge cases (all-zero, all-ones, with/without carry-in), and compares the DUT output against `A + B + Cin` computed behaviorally. |

### How the prefix network works

For an N-bit adder, the Sklansky network computes carries in `⌈log₂N⌉` stages, organized into doubling-size groups:

1. **Stage 0:** Adjacent-bit generate/propagate pairs are formed (with the initial carry-in folded into bit 0), producing pairwise (G, P) values across the whole word.
2. **Stages 1..log₂(N):** At stage `k`, the bit-range is split into blocks of size `2n` (where `n = 2^(k-1)`). Within each block, every bit in the *second half* combines its own (G, P) with the (G, P) of the **last bit of the first half** of that block — meaning the last bit of each lower block fans out to drive every bit above it in the same block.
3. Because the "root" signal of each block only ever needs to contribute a generate term going forward (its propagate term has already done its job), those root combines use the cheaper `Carry_Determination_Gonly` cell instead of the full `Carry_Determination` cell — reducing the gate count of the design relative to a tree that used full (G, P) cells uniformly (such as Kogge-Stone).
4. After `⌈log₂N⌉` stages, every bit position holds the full carry-in for that position, and the final sum is `SUM[i] = C[i] ^ p[i]`, with carry-out taken from the generate signal of the most significant bit.

This trades the larger fanout (and therefore higher per-stage buffering/drive requirements) of Sklansky's structure for a roughly halved cell count compared to Kogge-Stone, since each stage only updates half of the bit positions plus the reduced-cost group roots.

## Repository structure

```
.
├── GP_Logic.v                     # Bitwise generate/propagate logic
├── Carry_Determination.v          # Full prefix-combine cell (G and P)
├── Carry_Determination_Gonly.v    # Reduced prefix-combine cell (G only)
├── SUM_logic.v                     # Final XOR sum stage
├── Sklansky.v                     # Top-level 64-bit Sklansky adder
└── Sklansky_tb.v                  # Self-checking testbench
```

## Parameters

`Sklansky` is parameterized by `bits` (default `64`). The carry network generation logic relies on `bits` being a power of two for the block-doubling loop structure (`n = n << 1`) to tile correctly across the prefix tree.

```verilog
Sklansky #(.bits(64)) DUT (
    .A    (A),
    .B    (B),
    .Cin  (Cin),
    .SUM  (SUM),
    .Cout (Cout)
);
```

## Simulating the design

The testbench is self-checking — it will print `Test pass` or `Test Fails` depending on the result. Any Verilog simulator (Icarus Verilog, Vivado, ModelSim, etc.) can be used.

### Using Icarus Verilog

```bash
iverilog -o sklansky_tb.vvp GP_Logic.v Carry_Determination.v Carry_Determination_Gonly.v SUM_logic.v Sklansky.v Sklansky_tb.v
vvp sklansky_tb.vvp
```

### Expected output

```
A = ... , B = ... , Cin = ... , Actual Result = ... , Correct result = ...
...
Test pass
```

If a mismatch is found, the simulation halts immediately and prints `Test Fails` with the corresponding monitor line showing the failing inputs/outputs.

### Test coverage

- 91 randomized 64-bit operand pairs with random carry-in
- All-zero operands (`Cin = 0` and `Cin = 1`)
- All-ones operands (`Cin = 0` and `Cin = 1`, exercising full carry propagation/overflow)

## Notes

- This is a combinational adder; the `clk` signal in the testbench is only used as a simulation time reference and does not drive any sequential logic in the DUT.
- The design can be retargeted to other power-of-two bit widths by changing the `bits` parameter at instantiation.
- Compared to a [Kogge-Stone adder](https://en.wikipedia.org/wiki/Kogge%E2%80%93Stone_adder) of the same width, Sklansky uses fewer prefix cells (lower area) but has higher fanout per cell as the tree progresses, which can become the limiting factor on cycle time in real silicon despite the same asymptotic logic depth.
