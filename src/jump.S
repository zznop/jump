/**
 * jump.S
 *
 * This project is released under a [MIT](https://github.com/zznop/jump/LICENSE.md) license.
 */

.section .text
.globl _start

/******************************************************************************
 *                              VECTOR TABLE
 *****************************************************************************/

    .long 0x00FFFE00         /* Initial stack pointer value */
    .long _start             /* Start of program */
    .long exception_trap     /* Bus error */
    .long exception_trap     /* Address error (4) */
    .long exception_trap     /* Illegal instruction */
    .long exception_trap     /* Division by zero */
    .long exception_trap     /* CHK exception */
    .long exception_trap     /* TRAPV exception (8) */
    .long exception_trap     /* Privilege violation */
    .long exception_trap     /* TRACE exception */
    .long exception_trap     /* Line-A emulator */
    .long exception_trap     /* Line-F emulator (12) */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused (16) */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused (20) */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused (24) */
    .long exception_trap     /* Spurious exception */
    .long exception_trap     /* IRQ level 1 */
    .long extint             /* IRQ level 2 (external interrupt) */
    .long exception_trap     /* IRQ level 3 (28) */
    .long hblank             /* IRQ level 4 (VDP interrupt / horizontal retrace interrupt) */
    .long exception_trap     /* IRQ level 5 */
    .long vblank             /* IRQ level 6 (VDP interrupt / vertical retrace interrupt) */
    .long exception_trap     /* IRQ level 7 (32) */
    .long exception_trap     /* TRAP #00 exception */
    .long exception_trap     /* TRAP #01 exception */
    .long exception_trap     /* TRAP #02 exception */
    .long exception_trap     /* TRAP #03 exception (36) */
    .long exception_trap     /* TRAP #04 exception */
    .long exception_trap     /* TRAP #05 exception */
    .long exception_trap     /* TRAP #06 exception */
    .long exception_trap     /* TRAP #07 exception (40) */
    .long exception_trap     /* TRAP #08 exception */
    .long exception_trap     /* TRAP #09 exception */
    .long exception_trap     /* TRAP #10 exception */
    .long exception_trap     /* TRAP #11 exception (44) */
    .long exception_trap     /* TRAP #12 exception */
    .long exception_trap     /* TRAP #13 exception */
    .long exception_trap     /* TRAP #14 exception */
    .long exception_trap     /* TRAP #15 exception (48) */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */
    .long exception_trap     /* Unused */

/******************************************************************************
 *                              ROM HEADER
 *****************************************************************************/

    .ascii "SEGA GENESIS    "                                      /* Console name */
    .ascii "(c) zznop 2019  "                                      /* Copyright */
    .ascii "JUMP                                            "      /* Domestic name */
    .ascii "JUMP                                            "      /* International name */
    .ascii "13371337133713"                                        /* Serial-Revision */
    .word 0x0000                                                   /* Checksum */
    .ascii "J               "                                      /* I/O support */
    .long 0                                                        /* ROM start address */
    .long rom_end                                                  /* ROM end address */
    .long 0xFF0000                                                 /* RAM start address */
    .long 0xFFFFFF                                                 /* RAM end address */
    .ascii "            "                                          /* SRAM info */
    .ascii "Hack the Planet.                                    "  /* Notes (anything) */
    .ascii "JUE             "                                      /* Region */

/******************************************************************************
 *                              CONSTANTS
 *****************************************************************************/

/** 68k Memory Map **/
MEM_START      = 0x00FF0000
MEM_END        = 0x00FFFFFF
CTRL_1_DATA    = 0x00A10003
CTRL_1_CONTROL = 0x00A10009
VDP_CONTROL    = 0x00C00004
VDP_DATA       = 0x00C00000

/** VDP Access Modes **/
VDP_VRAM_WRITE = 0x40000000
VDP_CRAM_WRITE = 0xC0000000

/** Game State **/
MEM_GAME_STATE = 0x00FF0026

/** Game State Flags **/
STATE_FLAG_VBLANK    = 0x00000000

/** Counters **/
MEM_VBLANK_COUNTER = 0x00FF0002
MEM_FRAME_COUNTER  = 0x00FF0004

/* Controller Input **/
MEM_CONTROL_HELD    = 0x00FF0006
MEM_CONTROL_PRESSED = 0x00FF0008

/** Sprite Info **/
SPRITE_TABLE_BASE = 0x70000003
MEM_SPRITE_X      = 0x00FF000A
MEM_SPRITE_Y      = 0x00FF000C
MEM_SPRITE_STEP_COUNTER = 0x00FF000E

/** Button selection */
TEXT_RENDER_OFFSET = 0x00FF0010
TEXT_RENDER_COUNT = 0x00FF0014
JUMP_TARGET = 0x00FF0018

/** Flag Keys **/
FLAG_KEY1 = 0x00FF0020

/** Button Press Masks **/
BUTTON_UP_PRESSED = 0x1
BUTTON_DOWN_PRESSED = 0x2
BUTTON_LEFT_PRESSED = 0x4
BUTTON_RIGHT_PRESSED = 0x8
BUTTON_B_PRESSED = 0x10
BUTTON_C_PRESSED = 0x20
BUTTON_A_PRESSED = 0x40
BUTTON_START_PRESSED = 0x80

/** Letter Tile IDS **/
TID_0                = 0x0202
TID_1                = 0x0203
TID_2                = 0x0204
TID_3                = 0x0205
TID_4                = 0x0206
TID_5                = 0x0207
TID_6                = 0x0208
TID_7                = 0x0209
TID_8                = 0x020A
TID_9                = 0x020B
TID_DOLLAR           = 0x020C
TID_MINUS            = 0x020D
TID_EQUALS           = 0x020E
TID_RIGHT_ARROW      = 0x020F
TID_RIGHT_ARROW_BOLD = 0x0210
TID_Y                = 0x0211
TID_Z                = 0x0212
TID_A                = 0x0213
TID_B                = 0x0214
TID_C                = 0x0215
TID_D                = 0x0216
TID_E                = 0x0217
TID_F                = 0x0218
TID_G                = 0x0219
TID_H                = 0x021A
TID_I                = 0x021B
TID_J                = 0x021C
TID_K                = 0x021D
TID_L                = 0x021E
TID_M                = 0x021F
TID_N                = 0x0220
TID_O                = 0x0221
TID_P                = 0x0222
TID_Q                = 0x0223
TID_R                = 0x0224
TID_S                = 0x0225
TID_T                = 0x0226
TID_U                = 0x0227
TID_V                = 0x0228
TID_W                = 0x0229
TID_X                = 0x022A
TID_UNDERSCORE       = 0x022B
TID_OPEN_BRACKET     = 0x022B
TID_CLOSED_BRACKET   = 0x022B

/******************************************************************************
 *                              GAME INITIALIZATION
 *****************************************************************************/

_start:
    move.w #0x2700, %sr                      /* Disable interrupts */
    move.b #0x40, (CTRL_1_CONTROL)           /* Init the controller */
    move.b #0x40, (CTRL_1_DATA)
    lea vdp_registers, %a0                   /* Init the VDP regs */
    move.w #0x18-1, %d0
    move.w #0x8000, %d1
1:
    move.b (%a0)+, %d1
    move.w %d1, (VDP_CONTROL)
    addi.w #0x0100, %d1
    dbra %d0, 1b
    move.l #VDP_CRAM_WRITE, (VDP_CONTROL)    /* Clear the CRAM */
    move.w #0x003f, %d1                      /* 0x3F = 63 (64 palettes in CRAM - 1) */
1:
    move.w #0x0000, (VDP_DATA)
    dbf %d1, 1b
    move.l #VDP_VRAM_WRITE,(VDP_CONTROL)     /* Clear the VRAM */
    move.w #0x7fff, %d1
1:
    move.w #0x0000, (VDP_DATA)
    dbra %d1, 1b
    move.l MEM_START, %a0                    /* Clear the RAM */
    move.w #(MEM_END-MEM_START), %d1
1:
    move.w #0x0000, (%a0)+
    dbf %d1, 1b
    move.w #0x2000, %sr                      /* Enable interrupts */

/******************************************************************************
 *                              GAME START
 *****************************************************************************/

game_start:
    bsr.w wait_for_vblank    /* Wait to load palettes until VBlank */
    move.w #0x2700, %sr      /* Disable interrupts */
    bsr.w load_palettes      /* Load the palette into CRAM */
    bsr.w load_tiles         /* Render the background image */
    bsr.w draw_hex_keyboard  /* Draw the keyboard */
    bsr.w draw_background    /* Draw the background */
    bsr.w init_sprite        /* Draw the initial sprite */
    move.w #0x2000, %sr      /* re-enable interrupts */

main_game_loop:
    bsr.w wait_for_vblank
    move.b (MEM_CONTROL_HELD), %d7               /* Check the direction buttons .. */
    eor.w #0x0000, %d7                           /* Test if any direction buttons have been held */
    beq.s 1f                                     /* Branch if no direction buttons are held */
    bsr.w move_sprite                            /* Move the sprite */
1:                                               /* Check button press */
    move.b (MEM_CONTROL_PRESSED), %d7
    andi.w #0x00F0, %d7                          /* Mask off the button bits */
    beq.s main_game_loop                         /* No buttons pressed, enter main game loop again */
    move.b (MEM_CONTROL_PRESSED), %d7
    andi.w #0x00F0, %d7                          /* Mask off the button bits */
    beq.s main_game_loop                         /* No buttons pressed, enter main game loop again */
    andi.w #BUTTON_B_PRESSED, %d7                /* Was B pressed? */
    beq.s 2f                                     /* Nope, check if A was pressed */
    bsr.w execute_jump                           /* B was pressed, take the jump */
2:
    move.b (MEM_CONTROL_PRESSED), %d7
    andi.w #0x00F0, %d7                          /* Mask off the button bits */
    andi.w #BUTTON_A_PRESSED, %d7                /* Was button A pressed? */
    beq.s main_game_loop                         /* Nope, loop again */
    bsr.w handle_keyboard_press                  /* Handle button selection */
    bsr.w update_jmp_target                      /* Update the jump target from the button press */
    bra.s main_game_loop

wait_for_vblank:
    btst #STATE_FLAG_VBLANK, (MEM_GAME_STATE)    /* Test vblank flag */
    beq.s wait_for_vblank                        /* Loop until the flag changes */
    bclr #STATE_FLAG_VBLANK, (MEM_GAME_STATE)    /* Clear the vblank flag */
    rts

/**
 * Get input from controller 1 (on every vblank)
 */
get_controller_input:
    move.w #0x2700, %sr
    lea CTRL_1_DATA, %a0                 /* Load adddress to read controller 1 data */
    bsr.s 1f                             /* Read the joypad */
    move.w #0x2000, %sr
    rts
1:                                       /* Read the joypad */
    move.b #0, (%a0)                     /* Read joypad data port */
    nop                                  /* Bus sync */
    nop
    move.b (%a0), %d1                    /* Get Start/A */
    lsl.w #2, %d1                        /* Shift them to the high 2 bits */
    move.b #0x40, (%a0)                  /* Read the port again */
    nop                                  /* Bus sync */
    nop                                  /* Bus sync */
    move.b (%a0), %d0                    /* Get C/B/DPad */
    andi.b #0x3f, %d0                    /* Mask off high 2 bits in C/B/DPad read */
    andi.b #0xc0, %d1                    /* Mask off low 6 bits in Start/A read */
    or.b %d1, %d0                        /* Slam them together */
    not.b %d0                            /* Flip bits so 0 means not pressed, and 1 means pressed */
    move.b %d0, %d1                      /* Get previous joypad state */
    move.b (MEM_CONTROL_HELD), %d2
    eor.b %d2, %d0                       /* Flip buttons being pressed now */
    move.b %d1, (MEM_CONTROL_HELD)       /* Store held buttons */
    and.b %d1, %d0                       /* And with current buttons (to get held buttons) */
    move.b %d0, (MEM_CONTROL_PRESSED)    /* Store Pressed buttons */
    rts

/**
 * Attempt to deobfuscate the flag
 *
 * %d1 = the second XOR key
 */
check_solution:
    move.w (FLAG_KEY1), %d0                               /* Get first flag key */
    lea flag_tilemap, %a0                                 /* Pointer to flag tilemap into a0 */
    move.w (%a0)+, %d2                                    /* Get first word */
    eor.w %d0, %d2                                        /* Deobfuscate it */
    eor.w %d1, %d2                                        /* ... */
    cmpi.w #0x5a5a, %d2                                   /* Does it equal 'ZZ'? */
    bne.w 2f                                              /* Nope */
    move.w (%a0)+, %d2                                    /* Get second word */
    eor.w %d0, %d2                                        /* Deobfuscate it */
    eor.w %d1, %d2                                        /* ... */
    cmpi.w #0x4E50, %d2                                   /* Does it equal 'NP'? */
    bne.w 2f
    move.l #0x4C060003, (VDP_CONTROL)                     /* Plane A (1, 18) */
    move.w #((flag_tilemap_end-flag_tilemap-4)/2), %d3    /* Counter for the rest of the tilemap */
1:                                                        /* Render the flag */
    move.w (%a0)+, %d2                                    /* Get next tile id */
    eor.w %d0, %d2                                        /* Deobfuscate it */
    eor.w %d1, %d2                                        /* ... */
    move.w %d2, %a1
    move.w %a1, VDP_DATA                                  /* Write tile ID to Plane A */
    dbra %d3, 1b
2:
    rts

/**
 * Update the jump target based on the hex value selected by the user
 */
button_nibbles:
    .byte 0x0 ,0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7
    .byte 0x8, 0x9, 0xA, 0xB, 0xC, 0xD, 0xE, 0xF
update_jmp_target:
    move.w (MEM_SPRITE_Y), %d0   /* Get sprite's Y coord */
    and.l #0x0000ffff, %d0       /* Mask off low word */
    divu.w  #0x0010, %d0         /* Divide by 16 (tile coord) */
    sub.w #0x0011, %d0           /* Subtract 17 (tile base ycoord for keyboard) */
    move.w (MEM_SPRITE_X), %d1   /* Get sprite's X coord */
    and.l #0x0000ffff, %d1       /* Mask off low word */
    divu.w #0x0010, %d1          /* Divide by 16 (tile coord) */
    sub.w #0x000D, %d1           /* Subtract 13 (tile base xcoord for keyboard) */
    move.w #0x0000, %d2          /* Initialize the index */
    cmpi.w #0x0001, %d0          /* Is sprite in second row of keyboard? */
    bne.w 1f
    add.w #0x0008, %d2           /* Increment base index */
1:
    add.w %d1, %d2               /* Add the X offset to the index */
    lea button_nibbles, %a0      /* Get pointer to button nibbles array */
    add.w %d2, %a0               /* Get the nibble belonging to the button selected */
    move.w (JUMP_TARGET), %d3
    lsl.w #0x4, %d3              /* Shift jump target 4 bits */
    or.b (%a0), %d3              /* Merge in the nibble */  
    move.w %d3, (JUMP_TARGET)
    rts

/**
 * Handle button press/hex letter selection
 * y-110 x-d0
 */
hex_tile_ids:
    .word 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009
    .word 0x000A, 0x000B, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017, 0x0018
handle_keyboard_press:
    move.w (MEM_SPRITE_Y), %d0   /* Get sprite's Y coord */
    and.l #0x0000ffff, %d0       /* Mask off low word */
    divu.w  #0x0010, %d0         /* Divide by 16 (tile coord) */
    sub.w #0x0011, %d0           /* Subtract 17 (tile base ycoord for keyboard) */
    move.w (MEM_SPRITE_X), %d1   /* Get sprite's X coord */
    and.l #0x0000ffff, %d1       /* Mask off low word */
    divu.w #0x0010, %d1          /* Divice by 16 (tile coord) */
    sub.w #0x000D, %d1           /* Subtract 13 (tile base xcoord for keyboard) */
    move.w #0x0000, %d2          /* Base tile */
    cmpi.w #0x0001, %d0          /* Is sprite in second row of keyboard? */
    bne.w 1f
    add.w #0x0010, %d2           /* Increment base tile ID index to second row */
1:
    mulu.w #0x0002, %d1
    add.w %d1, %d2               /* Add the X offset to the tile index */
    lea hex_tile_ids, %a0        /* Get pointer to hex tile ID array */
    add.w %d2, %a0
    bsr.w render_button_select   /* Display the selected character */
    rts

/**
 * Display the button selected by the user
 *
 * #0x2000 apart
 */
render_button_select:
    move.l #0x4B1E2003, %d0
    cmpi.b #0x4, (TEXT_RENDER_COUNT)
    bne.w 1f
    move.l %d0, (VDP_CONTROL)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.l #0x00000000, (TEXT_RENDER_OFFSET)
    move.b #0x0, (TEXT_RENDER_COUNT)
1:
    add.l (TEXT_RENDER_OFFSET), %d0
    move.l %d0, (VDP_CONTROL)
    move.w (%a0), (VDP_DATA)
    add.l #0x22000, (TEXT_RENDER_OFFSET)
    add.b #0x1, (TEXT_RENDER_COUNT)
    cmpi.b #0x4, (TEXT_RENDER_COUNT)
    rts

/**
 * Handle controller input
 *
 * Credit: big evil corporation
 */
move_sprite:
    move.b (MEM_CONTROL_HELD), %d3               /* copy value of button held to d3 */
    move.b %d3, %d7                              /* copy button held value to d7 for eor */
    eor.w #0x0000, %d7                           /* test if it is zero */
    bne.w 1f                                     /* branch if a direction is being held */
    move.w #0x0000, (MEM_SPRITE_STEP_COUNTER)    /* nothing pressed, reset counter */
    bsr.w 5f                                     /* exit */
1:                                               /* Test direction */
    add.w  #0x0001, (MEM_SPRITE_STEP_COUNTER)    /* increment counter */
    move.w (MEM_SPRITE_STEP_COUNTER), %d7        /* copy counter to d7 */
    cmpi.w #0x0001, %d7                          /* move once every vsync */
    bls.w 5f                                     /* exit if it's not time to move */
    move.w #0x0000, (MEM_SPRITE_STEP_COUNTER)    /* reset the step counter */
    move.b %d3, %d7                              /* Test up */
    andi.w #BUTTON_UP_PRESSED, %d7               /* test if the right button is held */
    beq.s 2f                                     /* branch if not */
    move.w (MEM_SPRITE_Y), %d6                   /* move up ..; current y position to d6 */
    cmpi.w #0x0110, %d6                          /* is the sprite at the top edge? */
    ble.w 3f                                     /* if at the top edge don't move */
    sub.w #0x0010, %d6                           /* decrement */
    move.w %d6, (MEM_SPRITE_Y)                   /* save it back */
    move.w #0x00, %d5                            /* copy sprite id to d5 */
    move.w %d5, %d4                              /* copy sprite ID to d4 */
    mulu.w #0x08, %d4                            /* mult by 8 to get sprite array offset */
    swap %d4                                     /* move to upper word */
    add.l #SPRITE_TABLE_BASE, %d4                /* add to sprite table address */
    move.l %d4, (VDP_CONTROL)                    /* set write location in VDP */
    move.w %d6, (VDP_DATA)                       /* copy the new y-coordinate */
    beq.s 3f                                     /* up & down can't be pressed together */
2:                                               /* Test down */
    move.b %d3, %d7                              /* copy button held value to d7 for andi */
    andi.w #BUTTON_DOWN_PRESSED, %d7             /* test if the right button is held */
    beq.s 3f                                     /* branch if not */
    move.w (MEM_SPRITE_Y), %d6                   /* Move down; move current y position to d6 */
    cmpi.w #0x0120, %d6                          /* is the sprite at the bottom edge? */
    bge.w 3f                                     /* if at the bottom edge don't move */
    add.w #0x0010, %d6                           /* increment */
    move.w %d6, (MEM_SPRITE_Y)                   /* save it back */
    move.w #0x00, %d5                            /* copy sprite id to d5 */
    move.w %d5, %d4                              /* copy sprite ID to d4 */
    mulu.w #0x08, %d4                            /* mult by 8 to get sprite array offset */
    swap %d4                                     /* move to upper word */
    add.l #SPRITE_TABLE_BASE, %d4                /* add to sprite table address */
    move.l %d4, (VDP_CONTROL)                    /* set write location in VDP */
    move.w %d6, (VDP_DATA)                       /* copy the new y-coordinate */
3:                                               /* Test right */
    move.b %d3, %d7                              /* copy button held value to d7 for andi */
    andi.w #BUTTON_RIGHT_PRESSED, %d7            /* test if the right button is held */
    beq.s 4f                                     /* branch if not */
    move.w (MEM_SPRITE_X), %d6                   /* Move right, move current x position to d6 */
    cmpi.w #0x0140, %d6                          /* is the sprite at the right edge? */
    bge.w 5f                                     /* if at the right edge don't move */
    add.w #0x0010, %d6                           /* increment */
    move.w %d6, (MEM_SPRITE_X)                   /* save it back */
    move.w #0x00,%d5                             /* copy sprite id to d5 */
    move.w %d5, %d4                              /* copy sprite ID to d4 */
    mulu.w #0x08, %d4                            /* mult by 8 to get sprite array offset */
    add.b #0x06, %d4                             /* x-coordinate is at index 6 */
    swap %d4                                     /* move to upper word */
    add.l #SPRITE_TABLE_BASE, %d4                /* add to sprite table address */
    move.l %d4, (VDP_CONTROL)                    /* set write location in VDP */
    move.w %d6, (VDP_DATA)                       /* copy the new x-coordinate */
    beq.s 3b                                     /* up & down can't be pressed together */
4:
    move.b %d3, %d7                              /* copy button held value to d7 for andi */
    andi.w #BUTTON_LEFT_PRESSED, %d7             /* test if the right button is held */
    beq.s 5f                                     /* branch if not */
    move.w (MEM_SPRITE_X), %d6                   /* Move left; move current x position to d6 */
    cmpi.w #0x00d0, %d6                          /* is the sprite at the left edge? */
    ble.w 5f                                     /* if at the left edge don't move */
    sub.w #0x0010, %d6                           /* decrement */
    move.w %d6,(MEM_SPRITE_X)                    /* save it back */
    move.w #0x00, %d5                            /* copy sprite id to d5 */
    move.w %d5, %d4                              /* copy sprite ID to d4 */
    mulu.w #0x08, %d4                            /* mult by 8 to get sprite array offset */
    add.b #0x06, %d4                             /* x-coordinate is at index 6 */
    swap %d4                                     /* move to upper word */
    add.l #SPRITE_TABLE_BASE, %d4                /* add to sprite table address */
    move.l %d4, (VDP_CONTROL)                    /* set write location in VDP */
    move.w %d6, (VDP_DATA)                       /* copy the new x-coordinate */
5:                                               /* Exit */
    rts

/**
 * Load two palettes
 */
load_palettes:
    move.l #0xC0000003, (VDP_CONTROL)
    move.w #0x0000, (VDP_DATA)
    move.w #0x024a, (VDP_DATA)
    move.w #0x04ac, (VDP_DATA)
    move.w #0x08ee, (VDP_DATA)
    move.w #0x0104, (VDP_DATA)
    move.w #0x0a60, (VDP_DATA)
    move.w #0x00ce, (VDP_DATA)
    move.w #0x0fff, (VDP_DATA)
    move.w #0x0800, (VDP_DATA)
    move.w #0x04e0, (VDP_DATA)
    move.w #0x00ea, (VDP_DATA)
    move.w #0x0888, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x048e, (VDP_DATA)
    move.w #0x0200, (VDP_DATA)
    move.w #0x08c0, (VDP_DATA)

    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0cc0, (VDP_DATA) /* So the keyboard can be blue :) */
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    move.w #0x0000, (VDP_DATA)
    rts

/**
 * Load the tiles into VRAM
 */
load_tiles:
    move.l #0x40000000, (VDP_CONTROL)                                 /* Destination */
    move.l #0x00000000, VDP_DATA                                      /* Make first tile all transparent */
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA

    move.l #0x77000077, VDP_DATA                                      /* Load sprite */
    move.l #0x70000007, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x70000007, VDP_DATA
    move.l #0x77000077, VDP_DATA

    lea alphanum_tiles, %a0                                           /* Load the text */
    move.w #(((alphanum_tiles_end-alphanum_tiles) / 4) - 1), %d0
1:
    move.l (%a0)+, VDP_DATA
    dbra %d0, 1b
    move.l #0x00000000, VDP_DATA                                      /* Load the underscore */
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x00000000, VDP_DATA
    move.l #0x06666660, VDP_DATA
    move.l #0x00000000, VDP_DATA                                      /* Load the open bracket */
    move.l #0x00006600, VDP_DATA
    move.l #0x00006000, VDP_DATA
    move.l #0x00066000, VDP_DATA
    move.l #0x00660000, VDP_DATA
    move.l #0x00066000, VDP_DATA
    move.l #0x00006000, VDP_DATA
    move.l #0x00006600, VDP_DATA
    move.l #0x00000000, VDP_DATA                                      /* Load the closed bracket */
    move.l #0x00660000, VDP_DATA
    move.l #0x00060000, VDP_DATA
    move.l #0x00066000, VDP_DATA
    move.l #0x00006600, VDP_DATA
    move.l #0x00066000, VDP_DATA
    move.l #0x00060000, VDP_DATA
    move.l #0x00660000, VDP_DATA

    lea background, %a0
    move.w #(((background_end-background)/4)-1), %d0
2:
    move.l (%a0)+, VDP_DATA
    dbra %d0, 2b
    rts

/**
 * Populate Plane B with the background art
 */
draw_background:
    move.l #0x60820003, %d0             /* Plane B start */
    move.l #0x002e, %d1                 /* Base tile ID */
    move.l #15, %d2                     /* Width in tiles - 1 */
    move.l #15, %d3                     /* Height in tiles - 1 */
    bsr.w draw_tileset

    move.l #0x60a40003, (VDP_CONTROL)   /* Draw the lyrics */
    move.w #0x0026, VDP_DATA
    move.w #0x001a, VDP_DATA
    move.w #0x0017, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x0015, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x0016, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x0016, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x0029, VDP_DATA
    move.w #0x001b, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x001d, VDP_DATA
    move.w #0x0017, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.l #0x61240003, (VDP_CONTROL)
    move.w #0x0011, VDP_DATA
    move.w #0x0021, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    move.l #0x62a40003, (VDP_CONTROL)
    move.w #0x0016, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x0016, VDP_DATA
    move.w #0x0016, VDP_DATA
    move.w #0x0011, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x0015, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x0029, VDP_DATA
    move.w #0x001b, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x001d, VDP_DATA
    move.w #0x0017, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.l #0x63240003, (VDP_CONTROL)
    move.w #0x0011, VDP_DATA
    move.w #0x0021, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    move.l #0x64a40003, (VDP_CONTROL)
    move.w #0x001d, VDP_DATA
    move.w #0x0024, VDP_DATA
    move.w #0x001b, VDP_DATA
    move.w #0x0025, VDP_DATA
    move.w #0x0025, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001d, VDP_DATA
    move.w #0x0024, VDP_DATA
    move.w #0x0021, VDP_DATA
    move.w #0x0025, VDP_DATA
    move.w #0x0025, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x0029, VDP_DATA
    move.w #0x001b, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x001e, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0013, VDP_DATA
    move.w #0x001d, VDP_DATA
    move.w #0x0017, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.l #0x65240003, (VDP_CONTROL)
    move.w #0x0011, VDP_DATA
    move.w #0x0021, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    move.w #0x0000, VDP_DATA
    move.w #0x001c, VDP_DATA
    move.w #0x0027, VDP_DATA
    move.w #0x001f, VDP_DATA
    move.w #0x0022, VDP_DATA
    rts

/**
 * Draw the hex keyboard in plane A
 */
draw_hex_keyboard:
    move.l #0x0002, %d1                /* Base tile ID (hex letters) */
    move.l #0x7, %d2                   /* Width in tiles - 1 */
    move.l #0x49140003, (VDP_CONTROL)  /* Setup VDP to write to Plane B (10, 18) */
1:                                     /* Next cell */
    move.w %d1, %d3
    or.w #0x2000, %d3                  /* Use second palette */
    move.w %d3, VDP_DATA
    move.w #0x0000, VDP_DATA
    add.w #0x1, %d1                    /* Next tile id */
    dbra %d2, 1b
    move.l #0x4A140003, (VDP_CONTROL)  /* Setup VDP to write to Plane B (10, 19) */
    move.w %d1, %d3
    or.w #0x2000, %d3                  /* Use second palette */
    move.w %d3, VDP_DATA               /* Write the 8 */
    move.w #0x0000, VDP_DATA
    add.w #0x1, %d1                    /* inc tile id */
    move.w %d1, %d3
    or.w #0x2000, %d3                  /* Use second palette */
    move.w %d3, VDP_DATA               /* Write the 9 */
    move.w #0x0000, VDP_DATA

    move.l #0x0013, %d1                /* Set tile ID for hex letters */
    move.l #0x5, %d2                   /* Width in tiles - 1 */
2:                                     /* Next cell */
    move.w %d1, %d3
    or.w #0x2000, %d3                  /* Use second palette */
    move.w %d3, VDP_DATA
    move.w #0x0000, VDP_DATA
    add.w #0x1, %d1                    /* Next tile id */
    dbra %d2, 2b
    rts

/**
 * Load the sprite attributes into VRAM
 */
init_sprite:
    move.l #SPRITE_TABLE_BASE, (VDP_CONTROL)
    lea sprite_table, %a0
    move.l (%a0)+, VDP_DATA
    move.l (%a0)+, VDP_DATA
    move.w #0x00d0, (MEM_SPRITE_X)
    move.w #0x0110, (MEM_SPRITE_Y)
    rts

/**
 * Draw a set of tiles
 *
 * d0 - Base addr of destination cell map
 * d1 - Base tile ID of tileset
 * d2 - Tile width counter (num tiles - 1)
 * d3 - Tile height counter (num tiles - 1)
 */
draw_tileset:
1:                               /* New row */
    move.l %d2, %d4
    move.l %d0, (VDP_CONTROL)    /* Setup VDP to write to Plane A */
2:                               /* New cell */
    move.w %d1, VDP_DATA
    add.w #0x1, %d1              /* Next tile */
    dbra %d4, 2b
    add.l #0x800000, %d0         /* Next row */
    dbra %d3, 1b
    rts

/**
 * This is a psuedo-jump routine that overwrites the return addr on the stack
 * with the jump target specified by the user (and then returns to it)
 */
execute_jump:
    move.w (JUMP_TARGET), %d0    /* Get the jump target word */
    and.l #0x0000ffff, %d0       /* Mask off hi word 8 */
    bsr.w 1f                     /* Make a call so we can overrwrite the return addr on the stack */
1:
    move.l %d0, (%sp)            /* Overwrite ret addr */
    rts                          /* Return (psuedo jump) */

/**
 * Gadget for populating FLAG_KEY1
 */
gadget1:
    move.w #0x4553, (FLAG_KEY1) /* SE */
    rts

/******************************************************************************
 *                                  TRAPS
 *****************************************************************************/

extint:
    rte

hblank:
    rte

vblank:
    bset #STATE_FLAG_VBLANK, (MEM_GAME_STATE)    /* Set VBlank flag */
    addq #0x1, (MEM_VBLANK_COUNTER)              /* Increment debug counter */
    addq #0x1, (MEM_FRAME_COUNTER)               /* Increment frame counter */
    bsr.w get_controller_input
    rte

/**
 * Freeze the 68000
 */
exception_trap:
    nop
    nop
    move.w #1337, %d0
    bra.s exception_trap

/******************************************************************************
 *                            VDP REGISTERS
 *****************************************************************************/

vdp_registers:
    .byte 0x14    /* 0x00:  H interrupt on, palettes on */
    .byte 0x74    /* 0x01:  V interrupt on, display on, DMA on, Genesis mode on */
    .byte 0x30    /* 0x02:  Pattern table for Scroll Plane A at VRAM 0xC000 (bits 3-5 = bits 13-15) */
    .byte 0x00    /* 0x03:  Pattern table for Window Plane at VRAM 0x0000 (disabled) (bits 1-5 = bits 11-15) */
    .byte 0x07    /* 0x04:  Pattern table for Scroll Plane B at VRAM 0xE000 (bits 0-2 = bits 11-15) */
    .byte 0x78    /* 0x05:  Sprite table at VRAM 0xF000 (bits 0-6 = bits 9-15) */
    .byte 0x00    /* 0x06:  Unused */
    .byte 0x00    /* 0x07:  Background colour: bits 0-3 = colour, bits 4-5 = palette */
    .byte 0x00    /* 0x08:  Unused */
    .byte 0x00    /* 0x09:  Unused */
    .byte 0x08    /* 0x0A: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam) */
    .byte 0x00    /* 0x0B: External interrupts off, V scroll fullscreen, H scroll fullscreen */
    .byte 0x81    /* 0x0C: Shadows and highlights off, interlace off, H40 mode (320 x 224 screen res) */
    .byte 0x3F    /* 0x0D: Horiz. scroll table at VRAM 0xFC00 (bits 0-5) */
    .byte 0x00    /* 0x0E: Unused */
    .byte 0x02    /* 0x0F: Autoincrement 2 bytes */
    .byte 0x01    /* 0x10: Scroll plane size: 64x32 tiles */
    .byte 0x00    /* 0x11: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7) */
    .byte 0x00    /* 0x12: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7) */
    .byte 0xFF    /* 0x13: DMA length lo byte */
    .byte 0xFF    /* 0x14: DMA length hi byte */
    .byte 0x00    /* 0x15: DMA source address lo byte */
    .byte 0x00    /* 0x16: DMA source address mid byte */
    .byte 0x80    /* 0x17: DMA source address hi byte, memory-to-VRAM mode (bits 6-7) */
vdp_registers_end:

/******************************************************************************
 *                           ARTWORK AND GADGET1
 *****************************************************************************/

background:
    .incbin "artwork/kriss-kross.bin"
background_end:

/**
 * Populates key1 for flag deobfuscation - placed conveniently
 * between two bitmaps =)
 */
gadget2:
    move.w #0x4147, %d1 /* "GA" */
    bsr.w check_solution
    rts

flag_tilemap:
    .incbin "artwork/flag.bin"
flag_tilemap_end:

alphanum_tiles:
    .incbin "artwork/text.bin"
alphanum_tiles_end:

sprite_table:
    .word 0x0110    /* Y coordinate */
    .byte 0x00      /* 1x1 */
    .byte 0x00      /* Index of next sprite (linked list) */
    .byte 0x00      /* Hi tile id */
    .byte 0x01      /* Lo tile id */
    .word 0x00d0    /* X coordinate */
rom_end:
