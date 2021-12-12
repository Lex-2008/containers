#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// based on https://stackoverflow.com/questions/5770940/how-repeat-a-string-in-language-c
char *str_repeat(char str[], unsigned int count)
{
        if (count < 1) return NULL;

        size_t str_len = strlen(str);
        size_t str_len1 = str_len + 1;

        char *result = malloc(str_len1 * count);
        if (result == NULL) return NULL;
        char *p = result;

        while (count--) {
                memcpy(p, str, str_len);
                p += str_len1;
                p[-1]='\n';
        }
        return result;
}

int main(int argc, char *argv[])
{
        if( argc != 2 ){
                printf("Usage: %s <string>\n", argv[0]);
                return 1;
        }

        char *str=argv[1];
        size_t str_len = strlen(str);
        size_t str_len1 = str_len + 1;

        char *base=str_repeat(str, 9);
        if (base == NULL){
                printf("malloc failed");
                return 3;
        }

        char replacements[10][9] = {
                {'1', '2', '3', '4', '5', '6', '7', '8', '9'}, //0
                {'0', '2', '3', '4', '5', '6', '7', '8', '9'}, //1
                {'0', '1', '3', '4', '5', '6', '7', '8', '9'}, //2
                {'0', '1', '2', '4', '5', '6', '7', '8', '9'}, //3
                {'0', '1', '2', '3', '5', '6', '7', '8', '9'}, //4
                {'0', '1', '2', '3', '4', '6', '7', '8', '9'}, //5
                {'0', '1', '2', '3', '4', '5', '7', '8', '9'}, //6
                {'0', '1', '2', '3', '4', '5', '6', '8', '9'}, //7
                {'0', '1', '2', '3', '4', '5', '6', '7', '9'}, //8
                {'0', '1', '2', '3', '4', '5', '6', '7', '8'}};//9

        for( size_t i=0; i<str_len; i++ ) {
                char base_char = str[i];
                unsigned short r = base_char - '0';
                if( r >= 10 ){
                        printf("got bad r=%d on char [%c] (number %ld)\n", r, base_char, i);
                        return 2;
                }
                // Dear Compiler, please optimise this
                base[0*str_len1 + i] = replacements[r][0];
                base[1*str_len1 + i] = replacements[r][1];
                base[2*str_len1 + i] = replacements[r][2];
                base[3*str_len1 + i] = replacements[r][3];
                base[4*str_len1 + i] = replacements[r][4];
                base[5*str_len1 + i] = replacements[r][5];
                base[6*str_len1 + i] = replacements[r][6];
                base[7*str_len1 + i] = replacements[r][7];
                base[8*str_len1 + i] = replacements[r][8];
                fwrite(base,str_len+1,9,stdout);
                base[0*str_len1 + i] = base_char;
                base[1*str_len1 + i] = base_char;
                base[2*str_len1 + i] = base_char;
                base[3*str_len1 + i] = base_char;
                base[4*str_len1 + i] = base_char;
                base[5*str_len1 + i] = base_char;
                base[6*str_len1 + i] = base_char;
                base[7*str_len1 + i] = base_char;
                base[8*str_len1 + i] = base_char;
        }

}
