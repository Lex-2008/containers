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

	for( size_t i=0; i<str_len; i++ ) {
		char base_char = str[i];
		unsigned short r = base_char - '0';
		if( r >= 10 ){
			printf("got bad r=%d on char [%c] (number %ld)\n", r, base_char, i);
			return 2;
		}
		char c='0';
		for(unsigned short j=0; j<9; j++ ) {
			// j is index, 0..8 inclusive
			// c is character, '0'..'9' inclusive, excluding base_char
			// base_char is the character we're looking at
			// r is its numberic value
			if(c==base_char)
				// skip this char,
				c++;
			base[j*str_len1 + i] = c;
			c++;
		}
		fwrite(base,str_len1,9,stdout);
		for( unsigned short j=0; j<9; j++ ) {
			base[j*str_len1 + i] = base_char;
		}
	}

}
