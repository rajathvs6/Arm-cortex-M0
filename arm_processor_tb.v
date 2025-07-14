 

module arm_processor_tb;

    // Test bench signals
    reg clk;
    reg rst;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;
    wire [31:0] alu_result_out;
    wire [3:0] flags_out;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Instantiate the ARM processor
    arm_processor uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .alu_result_out(alu_result_out),
        .flags_out(flags_out)
    );
    
    // Test variables
    integer cycle_count;
    integer test_passed;
    
    // Task to wait for clock cycles
    task wait_cycles;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask
    
    // Task to display processor state
    task display_state;
        input [31:0] expected_pc;
        input [31:0] expected_instruction;
        input string test_name;
        begin
            $display("=== %s ===", test_name);
            $display("Cycle: %0d", cycle_count);
            $display("PC: 0x%08h (Expected: 0x%08h)", pc_out, expected_pc);
            $display("Instruction: 0x%08h (Expected: 0x%08h)", instruction_out, expected_instruction);
            $display("ALU Result: 0x%08h", alu_result_out);
            $display("Flags: N=%b Z=%b C=%b V=%b", flags_out[0], flags_out[1], flags_out[2], flags_out[3]);
            $display("Register File Contents:");
            for (integer i = 0; i < 16; i = i + 1) begin
                $display("R%0d: 0x%08h", i, uut.reg_file.registers[i]);
            end
            $display("----------------------------------------");
        end
    endtask
    
    // Task to check register value
    task check_register;
        input [3:0] reg_addr;
        input [31:0] expected_value;
        input string test_name;
        begin
            if (uut.reg_file.registers[reg_addr] == expected_value) begin
                $display("✓ %s: R%0d = 0x%08h (PASS)", test_name, reg_addr, expected_value);
                test_passed = test_passed + 1;
            end else begin
                $display("✗ %s: R%0d = 0x%08h, Expected: 0x%08h (FAIL)", 
                        test_name, reg_addr, uut.reg_file.registers[reg_addr], expected_value);
            end
        end
    endtask
    
    // Task to check flags
    task check_flags;
        input [3:0] expected_flags;
        input string test_name;
        begin
            if (flags_out == expected_flags) begin
                $display("✓ %s: Flags = N%bZ%bC%bV%b (PASS)", test_name, 
                        expected_flags[0], expected_flags[1], expected_flags[2], expected_flags[3]);
                test_passed = test_passed + 1;
            end else begin
                $display("✗ %s: Flags = N%bZ%bC%bV%b, Expected: N%bZ%bC%bV%b (FAIL)", 
                        test_name, flags_out[0], flags_out[1], flags_out[2], flags_out[3],
                        expected_flags[0], expected_flags[1], expected_flags[2], expected_flags[3]);
            end
        end
    endtask
    
    // Main test sequence
    initial begin
        // Initialize signals
        rst = 1;
        cycle_count = 0;
        test_passed = 0;
        
        $display("=== ARM Processor Test Bench ===");
        $display("Starting simulation...");
        
        // Reset sequence
        wait_cycles(5);
        rst = 0;
        $display("Reset released at time %0t", $time);
        
        // Wait for pipeline to fill
        wait_cycles(5);
        
        // Test 1: MOV R1, #5 (Load immediate)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h0000000C, 32'hE3A01005, "MOV R1, #5");
        check_register(1, 32'h00000005, "MOV R1, #5");
        
        // Test 2: MOV R2, #3 (Load immediate)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000010, 32'hE3A02003, "MOV R2, #3");
        check_register(2, 32'h00000003, "MOV R2, #3");
        
        // Test 3: ADD R3, R1, R2 (Register addition)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000014, 32'hE0813002, "ADD R3, R1, R2");
        check_register(3, 32'h00000008, "ADD R3, R1, R2");
        
        // Test 4: SUB R4, R3, R1 (Register subtraction)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000018, 32'hE0434001, "SUB R4, R3, R1");
        check_register(4, 32'h00000003, "SUB R4, R3, R1");
        
        // Test 5: AND R5, R1, R2 (Bitwise AND)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h0000001C, 32'hE0015002, "AND R5, R1, R2");
        check_register(5, 32'h00000001, "AND R5, R1, R2");
        
        // Test 6: ORR R6, R1, R2 (Bitwise OR)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000020, 32'hE1816002, "ORR R6, R1, R2");
        check_register(6, 32'h00000007, "ORR R6, R1, R2");
        
        // Test 7: EOR R7, R1, R2 (Bitwise XOR)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000024, 32'hE0217002, "EOR R7, R1, R2");
        check_register(7, 32'h00000006, "EOR R7, R1, R2");
        
        // Test 8: CMP R3, R1 (Compare - should set flags)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000028, 32'hE1530001, "CMP R3, R1");
        check_flags(4'b0000, "CMP R3, R1 (positive result)");
        
        // Test 9: CMP R1, R3 (Compare - should set negative flag)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h0000002C, 32'hE1510003, "CMP R1, R3");
        check_flags(4'b1000, "CMP R1, R3 (negative result)");
        
        // Test 10: MOV R8, #0 (Zero for comparison)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000030, 32'hE3A08000, "MOV R8, #0");
        check_register(8, 32'h00000000, "MOV R8, #0");
        
        // Test 11: CMP R8, #0 (Should set zero flag)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000034, 32'hE3580000, "CMP R8, #0");
        check_flags(4'b0100, "CMP R8, #0 (zero result)");
        
        // Test 12: LSL R9, R1, #2 (Logical shift left)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000038, 32'hE1A09101, "LSL R9, R1, #2");
        check_register(9, 32'h00000014, "LSL R9, R1, #2");
        
        // Test 13: LSR R10, R9, #1 (Logical shift right)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h0000003C, 32'hE1A0A0A9, "LSR R10, R9, #1");
        check_register(10, 32'h0000000A, "LSR R10, R9, #1");
        
        // Test 14: MVN R11, R1 (Move NOT)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000040, 32'hE1E0B001, "MVN R11, R1");
        check_register(11, 32'hFFFFFFFA, "MVN R11, R1");
        
        // Test 15: BIC R12, R1, R2 (Bit clear)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000044, 32'hE1C1C002, "BIC R12, R1, R2");
        check_register(12, 32'h00000004, "BIC R12, R1, R2");
        
        // Test 16: Memory operations - STR R1, [R8] (Store word)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000048, 32'hE5881000, "STR R1, [R8]");
        
        // Test 17: LDR R13, [R8] (Load word)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h0000004C, 32'hE598D000, "LDR R13, [R8]");
        check_register(13, 32'h00000005, "LDR R13, [R8]");
        
        // Test 18: Conditional branch test - BEQ (should not branch)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000050, 32'h0A000001, "BEQ +4");
        
        // Test 19: Another instruction after conditional branch
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000054, 32'hE3A0E00A, "MOV R14, #10");
        check_register(14, 32'h0000000A, "MOV R14, #10");
        
        // Test 20: Unconditional branch test - B (infinite loop)
        wait_cycles(3);
        cycle_count = cycle_count + 3;
        display_state(32'h00000058, 32'hEAFFFFFE, "B (infinite loop)");
        
        // Run a few more cycles to see the loop
        wait_cycles(10);
        
        // Final summary
        $display("\n=== TEST SUMMARY ===");
        $display("Total tests passed: %0d", test_passed);
        $display("Simulation completed at time %0t", $time);
        
        // Finish simulation
        $finish;
    end
    
    // Monitor for debugging
    initial begin
        $monitor("Time=%0t PC=0x%08h Inst=0x%08h ALU=0x%08h Flags=%b", 
                $time, pc_out, instruction_out, alu_result_out, flags_out);
    end
    
    // Waveform dump
    initial begin
        $dumpfile("arm_processor.vcd");
        $dumpvars(0, arm_processor_tb);
    end

endmodule
