  .text                                      #// FILE: binary32.j
  .globl binary32                                      #// Description:
  .include "include/stack.s"
                            .include "include/syscalls.s"

                            .macro call( %sub, %arg)
                              save_state()
                              push($a0)
                              move $a0, %arg
                              jal %sub
                              pop($a0)
                              restore_state()
                           .end_macro      
  binary32: nop                                      #//   This file provides the code to convert a binary number presented in 
                                        #//   Scientific Notation into binary32 format.  The binary32 format is as follows:
  #Bookkeeping                                      #//
  #a0: sign                                      #//     binary_32:   |  s  | eeee eeee | mmm mmmm mmmm mmmm mmmm mmmm |
  #a1: coefficient                                      #//                  | <1> | <-  8  -> | <-          23            -> |
  #a2: expon_sign                                      #//
  #a3: exponent                                      #//     the sign bit is placed into position 32
  #v0: encoding                                      #//     the biassed exponent (8 bits) is placed into positions: 31 .. 24
  #t0: encoded_sign                                      #//     the mantissa is left-justified (within it's 23-bit field),
  #t1: encoded_mantissa                                      #//       and is placed in positions: 23 .. 1          
  #t2: encoded_exponent                                      #//
  #t3: position                                      #//  Given a the following binary number (as an example):
  #t4: coefficient_shift                                      #//      2# + 1.1 0100 1110 0001 x 2^ - 101
  #t5: negative_sign                                      #//
  #t6: bias                                      #//  The input for the to sub routine is as follows:
  #t7: sign_shift                                      #//
  #t8: expon_shift                                      #//     sign    coefficient       expon_sign   exponent
  #t9: mantissa_shift                                      #//      '+'    2#11010011100001  '-'          2#101
  #t10: '-'                                      #//
                                        #//  Note: the coefficient is represented in fix-point notation in which the radix
                                        #//        point is always located immediately to the right of the msb.
                                        #
                                        #
                                        #  public static int binary32(int sign, int coefficient, int expon_sign, int exponent){
                                        #            // $a0 : sign
                                        #            // $a1 : coefficient
                                        #            // $a2 : expon_sign
                                        #            // $a3 : exponent
                                        #            int encoding; // : return value
                                        #
                                        #            int encoded_sign;
                                        #            int encoded_mantissa;
                                        #            int encoded_exponent;
                                        #            int position;          // the location of the msb of the coefficient
                                        #            int coefficient_shift;
                                        #            int negative_sign; //don't touch
                                        #
    li $t6, 127                                    #            final int bias           = 127;  // As defined by the spec
    li $t7, 31                                    #            final int sign_shift     =  31;  //   << (8 + 23 )
    li $t8, 23                                    #            final int expon_shift    =  23;  //   << (23)
    li $t9, 9                                    #            final int mantissa_shift =   9;  //  >>> (1 + 8)  // the mantissa is left-justified
                                        #            final int $zero          =   0;  
                                        #
                                        #            /////////////////////////////////////////////////////////
                                        #            // BEGIN CODE of INTEREST
                                        #            /////////////////////////////////////////////////////////
                                        #
  add $t5, $zero, '-'
  #li $t5, '-'
  #add $v0, $t5, $zero                                      #            negative_sign = '-';     // Define the value
  #jr $ra                                      #
                                        #            /////////////////////////////////////////////////////////
                                        #            // 1. Encode each of the three fields of the floating point format:
                                        #
                                        #            // 1.1 Sign Encoding: (encoded_sign = )
                                        #            //     - Based upon the sign, encode the sign as a binary value
decision:  bne $a0, $t5, nequal                                       #            if (sign == negative_sign) {
          add $t0, $zero, 1                                        #            encoded_sign = 1;
          j done                              #            } else{
nequal: nop
        add $t0, $zero, 0                                        #            encoded_sign = 0;
                                        #            }
done: nop
                                        #            //System.out.println(encoded_sign);
#add $v0, $zero, $t0                                        #            // 1.2 Exponent Encoding: (encoded_expon = )
#jr $ra                                        #            //     - Make the exponent a signed quantity
                                        #            //     - Add the bias
decision2: bne $a2, $t5, nequal2                                        #            if (expon_sign == negative_sign) {
                                        #              //encoded_exponent = -exponent + bias;
            nor $t2, $a3, $zero #FIX THIS LATERRRRRRRRRRRRRRRRRRRRRRRRRR                            #              encoded_exponent = ~exponent;
            add $t2, $t2, 1                            #              encoded_exponent = encoded_exponent + 1;
            add $t2, $t2, $t6                            #              encoded_exponent = encoded_exponent + bias;
                                        #              //encoded_exponent = encoded_exponent % 256;
        j done2                                #
nequal2: nop                                        #            } else {
        add $t2, $a3, $t6                                #              encoded_exponent = exponent + bias;
                                        #            }
done2: nop                                        #            
      #add $v0, $t2, $zero                                  #            // 1.3  Mantissa Encoding: (encoded_mantissa = )
      #jr $ra                                  #            //      - Determine the number of bits in the coefficient
                                        #            //        - that is to say, find the position of the most-significant bit
                                        #            //      - Shift the coefficient to the left to obtain the mantissa
                                        #            //        - the whole number is now removed, and
                                        #            //        - the mantissa (which is a fractional value) is left-justified
      call pos_msb $a1                                  #            position = pos_msb(coefficient);
      move $t3, $v0
                                        #            //coefficient_shift = 33 - position;
      nor $t4, $t3                                  #            coefficient_shift = ~position;
                                        #            //System.out.println(coefficient_shift);
      add $t4, $t4, 1                                  #            coefficient_shift = coefficient_shift + 1;
      add $t4, $t4, 33                                  #            coefficient_shift = coefficient_shift + 33;
                                        #            //System.out.println(coefficient_shift);
                                        #            //System.out.println(coefficient_shift);
                                        #            //coefficient_shift = coefficient_shift % 256;
                                        #            //System.out.println(coefficient_shift);
                                        #
      sll $t1, $a1, $t4                                  #            encoded_mantissa = coefficient << coefficient_shift ; 
                                        #
                                        #            
                                        #
                                        #            /////////////////////////////////////////////////////////
                                        #            // 2. Shift the pieces into place: sign, exponent, mantissa
                                        #
      sll $t0, $t0, $t7                                  #            encoded_sign = encoded_sign << sign_shift;
      sll $t2, $t2, $t8                                  #            encoded_exponent = encoded_exponent << expon_shift;
      sra $t1, $t1, $t9                                  #            encoded_mantissa = encoded_mantissa >>> mantissa_shift;
                                        #            
                                        #            /////////////////////////////////////////////////////////
                                        #            // 3. Merge the pieces together
                                        #            //encoding = 0;
                                        #            //System.out.println(encoded_sign);
                                        #            encoding = encoded_sign + encoded_exponent;
                                        #            encoding = encoding + encoded_mantissa;
                                        #
                                        #            return encoding;
                                        #  }
                                        #
                                        #  /////////////////////////////////////////////////////////
                                        #  // END CODE of INTEREST
                                        #  /////////////////////////////////////////////////////////

pos_msb:                                        #static int pos_msb(int number){
#Bookkeeping
#a0: number                                        #        // $a0 : number
#v0: counter                                        #
                                        #        int counter;      // : counter: the return value
                                        #
      li $v0, 0                                        #        counter = 0;
init: nop                                        #init:   ;
loop: beq $a0, $zero, don                                        #loop:   for(; number != 0 ;) {
body: nop                                        #body:     ;
      srl $a0, $a0, 1                                        #          number = number >>> 1;
      addi $v0, $v0, 1                                        #          counter ++;
      j loop                                        #          continue loop;
                                        #        }
don:                                       #done:   ;
      jr $ra                                      #        return counter;
                                        #}
