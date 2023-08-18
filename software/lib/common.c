/**
 * @file common.c
 * @author Matthew Gilpin (matt@gilpin.au)
 * @brief This file contains all common utilities
 * @version 0.1
 * @date 2023-08-18
 * 
 * @copyright Copyright (c) 2023
 * 
 */




/**
 * @brief Convert Hex char to int
 * 
 * @param c 
 * @return int 
 */
int hex_char_to_int(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    } else if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    } else if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    } else {
        return 0; // Invalid character, you may want to handle this case differently
    }
}


/**
 * @brief Convert Hex byte to int
 * 
 * @param c 
 * @return int 
 */
int hex_byte_to_int(char c[2]) {
    int value = 0;

    value += hex_char_to_int(c[0]) * 16;
    value += hex_char_to_int(c[1]);

    return value;
}

/**
 * @brief Convert a hex string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int hex_str_to_int(const char *string, int length) {
    int value = 0;

    for (int i = 0; i < length; i++) {
        value = value * 16 + hex_char_to_int(string[i]);
    }

    return value;
}

/**
 * @brief Convert a string to an integer
 * 
 * @param string 
 * @param length 
 * @return int 
 */
int str_to_int(const char *string, int length) {

    int value = 0;

    switch(length) {
        case 4:
            value += (string[0] - '0') * 1000;
            value += (string[1] - '0') * 100;
            value += (string[2] - '0') * 10;
            value += (string[3] - '0');
            break;
        case 3:
            value += (string[0] - '0') * 100;
            value += (string[1] - '0') * 10;
            value += (string[2] - '0');
            break;
        case 2:
            value += (string[0] - '0') * 10;
            value += (string[1] - '0');
            break;
        case 1:
        default:
            value += (string[0] - '0');
            break;
    }

    
    return value;
}
