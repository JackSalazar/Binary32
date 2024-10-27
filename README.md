# Binary32: The Encoding of the Java float type

## Overview:

In this assignment, you are to develop three versions of a method/subroutine that encodes a real binary number into binary32 format.  This real number can be represented in scientific notation.  For example:

   ```
   + 1.1 0100 1110 0001  x2^  - 10 1001
   ```

Your method/subroutine is provided with four arguments that correspond to the four fields in the numbers scientific notation representation.  These four fields are:
   1. the sign of the real number: '+'
   1. the coefficient: "2#1 1 0100 1110 0001"
      - the coefficient represents both the whole number and the mantissa.
      - the coefficient is an integer value provided in fix point.
      - the radix point is set after the first digit from the left. 
   1. the sign of the exponent: '-'
   1. the exponent: 41

Review the file `./encode_float.md` that provides the algorithm to convert a binary number, expressed in scientific notation, into binary32. 

## Objectives
   1. To obtain a better understanding of the use of various shift operators to manipulate values at the bit level.

   1. To gain a better understanding of the various encoding formations for numbers.

   1. To further develop our software development skills.

## Specifications and Limitations
   1. You must use the development process defined by the Professor. See [Programming Workflow](./programming_workflow.md) for more details.

   1. Your java_tac code may use operations with immediate values.
      - but such immediate values can only be the second operand
      - for example,  `var = var {op} imm;` is permissible.
      - for example,  `var = imm {op} var;` is *not* permissible.

   1. Refer to comp122/reference/TAC_transformation to aid you in transforming java to java_tac

   1. You many only use native MIPS instructions.

   1. Refer to comp122/referenceTAC2mips.md to aid you in transliterating java_tac to MIPS.


## Tasks
Note that these instructions presume that the current working directory is: `~/classes/comp122/deliverables/43-binary32-{account}`.

### Test_cases:
  1. Create at least one test cases within the file `test_cases/{account}.sth_case`. 
     * See the file `test_cases/{smf-steve}.sth_case` as an example.

  1. Trade your test cases with at least two other students. Place these files into your `test_cases` directory.  E.g., 
     - `test_cases/{student_1}.sth_case`
     - `test_cases/{student_2}.sth_case`

  1. Add and commit these test cases to your local repository:
     ```bash
     git add test_cases/{account}.sth_case
     git add test_cases/{student_1}.sth_case
     git add test_cases/{student_2}.sth_case
     git commit -m 'adding shared test_cases'
     ```
  1. Note that all of the above work is performed on the `main` branch.

#### Additional Testing Information:

Do NOT rely solely on the automated testing. You need to develop simple test cases to aid you in the proper development of your methods/subroutine.

Here are some example calls to `java_subroutine` that will help you test your code during the development cycle.

   1. The output from the `encode_float.md`
      ```bash
      $ java_subroutine -R binary32 \
          java/binary32 '-'  2#101011010101 + 2#101
      | 1 | 10000100 | 01011010101000000000000 |
      ```

   1. The output resembling the preamble of an Ethernet frame.
      ```bash
      $ java_subroutine -R binary32 \
         java/binary32 '-'  11184810 - 42
      | 1 | 01010101 | 01010101010101010101010 |
      ```

   1. Nothing but zeros for the output.
      ```bash
      $ java_subroutine -R binary32 \
          java/binary32 '-' 1 '-' 127
      | 0 | 00000000 | 00000000000000000000000 |
      ```

   1. Nothing but ones for the output.
      ```bash
      $java_subroutine -R binary32 \
          java/binary32 '-' 0XFFFFFF '+' 128
      | 1 | 11111111 | 11111111111111111111111 |
      ```

You can transform the above into sth test-case.  The first example above has been provided to you in `test_cases/{smf-steve}.sth_case`. 

For example, 

   ```bash
   $ java_subroutine -R binary32 \
       java/binary32 '-'  2#101011010101 + 2#101
   | 1 | 10000100 | 01011010101000000000000 |
   ```

is transformed into 

  ```sth
  [case]
  ARGS="'-' 2#101011010101 '+' 2#101"
  OUTPUT="| 1 | 10000100 | 01011010101000000000000 |"
  ```

An interested student could look at `test_cases/00-floating-point` to see the other values provided to the sth system to make everything work.

Once you are ready, you can test your implementations via the automated process.  Use the following command to test--in turn--your java, java_tac, and the mips code.

  ```bash
  make test_java
  make test_java_tac
  make test_mips
  make test
  ```

### Starter Code:

To help you get kick-started the following java starter code has been provided to you. See [binary32_starter.j](./binary32_starter.j)
 

### Java: `binary32.j`

  1. Start the `java` Task with the file `java/binary32.j`
     (see [Programming Workflow](./programming_flow.md))
  1. Copy the contents of the starter code into java/binary32.j
  1. Incrementally Work on the `java` Task  
  1. Perform manual testing as you develop your solution
  1. Continue working on your solution until you have a working solution.
  1. Run `make test_java` to invoke the automated testing.
  1. Finish your Java Task   


### Java_tac: `binary32.j`  
  1. Start the `java_tac` Task
  1. Incrementally Work on your `java_task` task
  1. Finish the `java_tac` task.


### MIPS: `binary32.s`
  1. Start the `mips` Task with the file `mips/binary32.s`

  1. Copy your java_tac.j code into `mips/binary32.s`
  1. Edit your code by commenting out, etc., your java code
  1. Include the following code into `mips/binary32.s`
       ```mips
                            .text
                            .globl binary32
                            .include "include/stack.s"
                            .include "include/syscalls.s"
			    .include "incluse/subroutine.s"

                            .macro call( %sub, %arg)
                              save_state()
                              push($a0)
                              move $a0, %arg
                              jal %sub
                              pop($a0)
                              restore_state()
                           .end_macro                            
       ```
  1. Incrementally Work on your `mips` task to transliterate each of your java_tac statements.


  1. Finish the `mips` task.


#### MIPS: Additional Information

 1. Notice that the Java code provide uses the `final` keyword. This the preferred way to define a constant variable.  To convert these variables into MIPS, you can use the `.eqv` (equivalence) directive. For example,
     
    ```java
    final int bias           = 127;
    ```
 
    is converted to

    ```mips
          .eqv bias 127
    ```

    and then you can use the "bias" as in MIPS instruction as a   literal.  For example, 

    ```mips
         addi $t1, $t1, bias   # Add the bias to $t1
    ```

    Hence, there is no need to allocate registers to hold these values.

 1. To facilitate the call to the pos_msb subroutine, the `call` macro has been created for you (see above). The purpose of this macro will be more fully explained in upcoming lectures
    ```mips
    .macro call(%sub, %arg)
       # See definition above
    .end_macro
    ```

    For now, simply use the following TAC -> MIPS mapping.

      | Java TAC                | MIPS Macro                |
      |-------------------------|---------------------------|
      | a = pos_msb(b);         | call pos_msb b            |
      |                         | move a, $v0               |

 
### Finish the assignment: 
At this point, you have completed the assignment and you have submitted it. But now you have a chance to "confirm" that when the Professor grades the assignment, it is based upon what you believe you submitted.

In short, perform one more test to make sure everything is as it should be.

  ```bash
  git switch main
  make confirm
  ```

Make any alterations to your previous work to ensure you maximize your score.  Note you must remember to reset and to republish your "submission" tags correctly.  The tags are what the Professor uses to determine *what* to grade.



