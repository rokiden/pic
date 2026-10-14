---
name: verilog-style-guide
description: 'Verilog/SystemVerilog RTL style guide. Use when working with Verilog/SystemVerilog files.'
---

# Header Templates

### General Verilog/SystemVerilog
```verilog
/*
    Name of Module

    Description:
        Paragraph with up to a few sentences. Description of the module's functionality and purpose, summarizing what the module does. What parts it consists of (if applicable). How it is used (if applicable).

    Notes:
        - Any additional notes or comments about the module.

    Parameters:
        - SEQ_NUM: Number of elements in the input sequences (default: 128)
        - DATA_W:  Data width of input samples (default: 16)

    Interfaces:
        - apb_if: APB interface for control and configuration
        - axis_if: AXI-Stream interface for input/output data
        - s_axis_*: AXI-Stream interface for input sequences

    Inputs:
        - clk_i:       Clock signal
        - rst_ni:      Active-low reset
        - a_seq_re_i:  Real part of sequence A
        - a_seq_im_i:  Imaginary part of sequence A
        - b_seq_re_i:  Real part of sequence B
        - b_seq_im_i:  Imaginary part of sequence B

    Outputs:
        - res_re_o:    Real part of correlation result
        - res_im_o:    Imaginary part of correlation result

*/
```
Notes:
- Mention each clock in inputs section
- It is not neccessary to describe each port of common interfaces (e.g., AXI4, APB, AXI-Stream, etc.)
- Pay attention to signal's clock if needed
- Empty header sections should be skipped

### Block Design Wrappers
For the files with name postfix *_bd.v
```verilog
/*
    Block Design wrapper for the name of module
*/
```

### Verilog-Compatible Wrappers
For the files with name postfix *_vc.v
```verilog
/*
    Verilog-compatible wrapper for the name of module
*/
```

# General RTL
- Reset only the control/state, not payload storage (e.g. reset AXI-Stream TVALID, not TDATA and other payload signals).

## Sections formatting
```verilog
    //=========================================================================
    // Section Name
    //=========================================================================

    // Subsection Name --------------------------------------------------------
```
