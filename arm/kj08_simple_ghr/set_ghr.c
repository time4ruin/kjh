#include "common.h"

void set_ghr(int set_ghr){
    /* set_ghr */
    if ((set_ghr>>15)&1){NOP_REPEAT(10);}
    if ((set_ghr>>14)&1){NOP_REPEAT(10);}
    if ((set_ghr>>13)&1){NOP_REPEAT(10);}
    if ((set_ghr>>12)&1){NOP_REPEAT(10);}
    if ((set_ghr>>11)&1){NOP_REPEAT(10);}
    if ((set_ghr>>10)&1){NOP_REPEAT(10);}
    if ((set_ghr>>9)&1){NOP_REPEAT(10);}
    if ((set_ghr>>8)&1){NOP_REPEAT(10);}
    if ((set_ghr>>7)&1){NOP_REPEAT(10);}
    if ((set_ghr>>6)&1){NOP_REPEAT(10);}
    if ((set_ghr>>5)&1){NOP_REPEAT(10);}
    if ((set_ghr>>4)&1){NOP_REPEAT(10);}
    if ((set_ghr>>3)&1){NOP_REPEAT(10);}
    if ((set_ghr>>2)&1){NOP_REPEAT(10);}
    if ((set_ghr>>1)&1){NOP_REPEAT(10);}
    if ((set_ghr>>0)&1){NOP_REPEAT(10);}
    /**/
}
