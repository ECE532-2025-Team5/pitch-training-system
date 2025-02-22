import csv
from collections import Counter

def check_break_overlap(csv_filename):
    kb_dict = {}
    
    with open(csv_filename, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            # Split BREAK codes (some may have multiple values separated by ';')
            key = 'kb_' + row['KEY'].replace(' ','_')
            keycode = row['MAKE'].split(';')[-1]
            print(f"`define {key} 8'h{keycode}")
            if keycode in kb_dict:
                # print(f"{keycode}, skipping {key} kb_dict[{keycode}] = {kb_dict[keycode]}")
                print("    dup ^")
                continue
            kb_dict[keycode] = key
            
    print(kb_dict)

# # Example usage
# csv_filename = "ps2_to_ascii.csv"  # Change this to your actual file path
# check_break_overlap(csv_filename)

ascii = r'''`define ascii_SPACE 8'h20
`define ascii_EXCL 8'h21
`define ascii_DQT 8'h22
`define ascii_HASH 8'h23
`define ascii_DLLR 8'h24
`define ascii_PRCNT 8'h25
`define ascii_AMPS 8'h26
`define ascii_SQT 8'h27
`define ascii_LPAR 8'h28
`define ascii_RPAR 8'h29
`define ascii_MULTIPLY 8'h2A
`define ascii_PLUS 8'h2B
`define ascii_COMMA 8'h2C
`define ascii_MINUS 8'h2D
`define ascii_DOT 8'h2E
`define ascii_FSLH 8'h2F
`define ascii_0 8'h30
`define ascii_1 8'h31
`define ascii_2 8'h32
`define ascii_3 8'h33
`define ascii_4 8'h34
`define ascii_5 8'h35
`define ascii_6 8'h36
`define ascii_7 8'h37
`define ascii_8 8'h38
`define ascii_9 8'h39
`define ascii_COLON 8'h3A
`define ascii_SEMI 8'h3B
`define ascii_LT 8'h3C
`define ascii_EQUAL 8'h3D
`define ascii_GT 8'h3E
`define ascii_QMARK 8'h3F
`define ascii_AT 8'h40
`define ascii_A 8'h41
`define ascii_B 8'h42
`define ascii_C 8'h43
`define ascii_D 8'h44
`define ascii_E 8'h45
`define ascii_F 8'h46
`define ascii_G 8'h47
`define ascii_H 8'h48
`define ascii_I 8'h49
`define ascii_J 8'h4A
`define ascii_K 8'h4B
`define ascii_L 8'h4C
`define ascii_M 8'h4D
`define ascii_N 8'h4E
`define ascii_O 8'h4F
`define ascii_P 8'h50
`define ascii_Q 8'h51
`define ascii_R 8'h52
`define ascii_S 8'h53
`define ascii_T 8'h54
`define ascii_U 8'h55
`define ascii_V 8'h56
`define ascii_W 8'h57
`define ascii_X 8'h58
`define ascii_Y 8'h59
`define ascii_Z 8'h5A
`define ascii_LBKT 8'h5B
`define ascii_BSLH 8'h5C
`define ascii_RCKT 8'h5D
`define ascii_CARET 8'h5E
`define ascii_UNDER 8'h5F
`define ascii_GRAVE 8'h60
`define ascii_a 8'h61
`define ascii_b 8'h62
`define ascii_c 8'h63
`define ascii_d 8'h64
`define ascii_e 8'h65
`define ascii_f 8'h66
`define ascii_g 8'h67
`define ascii_h 8'h68
`define ascii_i 8'h69
`define ascii_j 8'h6A
`define ascii_k 8'h6B
`define ascii_l 8'h6C
`define ascii_m 8'h6D
`define ascii_n 8'h6E
`define ascii_o 8'h6F
`define ascii_p 8'h70
`define ascii_q 8'h71
`define ascii_r 8'h72
`define ascii_s 8'h73
`define ascii_t 8'h74
`define ascii_u 8'h75
`define ascii_v 8'h76
`define ascii_w 8'h77
`define ascii_x 8'h78
`define ascii_y 8'h79
`define ascii_z 8'h7A
`define ascii_LBRC 8'h7B
`define ascii_PIPE 8'h7C
`define ascii_RBRC 8'h7D
`define ascii_TILDE 8'h7E
`define ascii_DEL 8'h7F'''

kb = r'''
`define kb_A 8'h1C
`define kb_B 8'h32
`define kb_C 8'h21
`define kb_D 8'h23
`define kb_E 8'h24
`define kb_F 8'h2B
`define kb_G 8'h34
`define kb_H 8'h33
`define kb_I 8'h43
`define kb_J 8'h3B
`define kb_K 8'h42
`define kb_L 8'h4B
`define kb_M 8'h3A
`define kb_N 8'h31
`define kb_O 8'h44
`define kb_P 8'h4D
`define kb_Q 8'h15
`define kb_R 8'h2D
`define kb_S 8'h1B
`define kb_T 8'h2C
`define kb_U 8'h3C
`define kb_V 8'h2A
`define kb_W 8'h1D
`define kb_X 8'h22
`define kb_Y 8'h35
`define kb_Z 8'h1A
`define kb_0 8'h45
`define kb_1 8'h16
`define kb_2 8'h1E
`define kb_3 8'h26
`define kb_4 8'h25
`define kb_5 8'h2E
`define kb_6 8'h36
`define kb_7 8'h3D
`define kb_8 8'h3E
`define kb_9 8'h46
`define kb_GRAVE 8'h0E
`define kb_MINUS 8'h4E
`define kb_EQUAL 8'h55
`define kb_BSLH 8'h5D
`define kb_BKSP 8'h66
`define kb_SPACE 8'h29
`define kb_TAB 8'h0D
`define kb_CAPS 8'h58
`define kb_LSHFT 8'h12
`define kb_LRCTRL 8'h14
`define kb_LGUI 8'h1F
`define kb_LRALT 8'h11
`define kb_RSHFT 8'h59
`define kb_RGUI 8'h27
`define kb_APPS 8'h2F
`define kb_ENTER 8'h5A
`define kb_ESC 8'h76
`define kb_F1 8'h05
`define kb_F2 8'h06
`define kb_F3 8'h04
`define kb_F4 8'h0C
`define kb_F5 8'h03
`define kb_F6 8'h0B
`define kb_F7 8'h83
`define kb_F8 8'h0A
`define kb_F9 8'h01
`define kb_F10 8'h09
`define kb_F11 8'h78
`define kb_F12 8'h07
`define kb_SCROLL 8'h7E
`define kb_LBKT 8'h54
// `define kb_INSERT 8'h70
// `define kb_HOME 8'h6C
// `define kb_PG_UP 8'h7D
// `define kb_DELETE 8'h71
// `define kb_END 8'h69
// `define kb_PG_DN 8'h7A
// `define kb_UP 8'h75
// `define kb_LEFT 8'h6B
// `define kb_DOWN 8'h72
// `define kb_RIGHT 8'h74
`define kb_NUM 8'h77
// `define kb_KP_DIVIDE 8'h4A
`define kb_KP_MULTIPLY 8'h7C
`define kb_KP_MINUS 8'h7B
`define kb_KP_PLUS 8'h79
// `define kb_KP_EN 8'h5A
`define kb_KP_DOT 8'h71
`define kb_KP_0 8'h70
`define kb_KP_1 8'h69
`define kb_KP_2 8'h72
`define kb_KP_3 8'h7A
`define kb_KP_4 8'h6B
`define kb_KP_5 8'h73
`define kb_KP_6 8'h74
`define kb_KP_7 8'h6C
`define kb_KP_8 8'h75
`define kb_KP_9 8'h7D
`define kb_RBKT 8'h5B
`define kb_SEMI 8'h4C
`define kb_SQT 8'h52
`define kb_COMMA 8'h41
`define kb_DOT 8'h49
`define kb_FSLH 8'h4A'''

import re

def get_corresponding(kb_str: str, ascii_str: str):
    # Extract keys from ascii and kb definitions
    ascii_keys = set(re.findall(r'`define ascii_([A-Za-z0-9_]+)', ascii))
    kb_keys = set(re.findall(r'`define kb_([A-Za-z0-9_]+)', kb))

    # Find matches and non-matches
    matching_keys = kb_keys & ascii_keys
    non_matching_keys = kb_keys - ascii_keys

    # Print matching keys
    for key in sorted(matching_keys):
        print(f'`kb_{key}: ascii <= `ascii_{key};')

    # Print non-matching keys with a comment
    for key in sorted(non_matching_keys):
        print(f'`kb_{key}: // No matching ascii key')
        
        
get_corresponding(kb, ascii)