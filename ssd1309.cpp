#include "pxt.h"
#define mbit_p8                     P0_18       //PIN 18
#define mbit_p12                    P0_20       //PIN 20
#define mbit_p13                    P0_23       //SCK
#define mbit_p14                    P0_22       //MISO
#define mbit_p15                    P0_21       //MOSI
#define mbit_p16                    P0_16       //PIN 16
#define LCD_CMD                         0
#define LCD_DAT                         1
#define LCD_TEMP                        0
#define LCD_BIAS                        3
#define LCD_VOP                         63
#define SCROLL_UP                       0
#define SCROLL_RIGHT                    1
#define SCROLL_DOWN                     2
#define SCROLL_LEFT                     3            

using namespace pxt;

namespace nokialcd {
    const uint8_t CHAR_BYTES[600] = {
        // definition of all characters from 32 to 127, then any extended chars desired
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5f, 0x5f, 0x00, 0x00, // SPACE and pling
        0x00, 0x07, 0x00, 0x07, 0x00, 0x00, 0x14, 0x7f, 0x14, 0x7f, 0x14, 0x00, // "" and #
        0x24, 0x6a, 0x7f, 0x2b, 0x12, 0x00, 0x63, 0x33, 0x18, 0x0c, 0x66, 0x63, // $ and percent
        0x36, 0x7f, 0x49, 0x5e, 0x26, 0x50, 0x00, 0x04, 0x07, 0x03, 0x00, 0x00, // & and '
        0x00, 0x1c, 0x3e, 0x63, 0x41, 0x00, 0x00, 0x41, 0x63, 0x3e, 0x1c, 0x00, // ( and )
        0x14, 0x1c, 0x3e, 0x3e, 0x1c, 0x14, 0x08, 0x08, 0x3e, 0x3e, 0x08, 0x08, // * and +
        0x00, 0x80, 0xe0, 0x60, 0x00, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, // , and -
        0x00, 0x00, 0x60, 0x60, 0x00, 0x00, 0x20, 0x30, 0x18, 0x0c, 0x06, 0x02, // . and /
        0x3e, 0x7f, 0x59, 0x4d, 0x7f, 0x3e, 0x40, 0x42, 0x7f, 0x7f, 0x40, 0x40, // 0 1
        0x42, 0x63, 0x71, 0x59, 0x4f, 0x46, 0x22, 0x63, 0x49, 0x49, 0x7f, 0x36, // 2 3
        0x18, 0x1c, 0x16, 0x7f, 0x7f, 0x10, 0x27, 0x67, 0x45, 0x45, 0x7d, 0x39, // 4 5
        0x3c, 0x7e, 0x4b, 0x49, 0x79, 0x30, 0x01, 0x71, 0x79, 0x0d, 0x07, 0x03, // 6 7
        0x36, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x06, 0x4f, 0x49, 0x69, 0x3f, 0x1e, // 8 9
        0x00, 0x00, 0x6c, 0x6c, 0x00, 0x00, 0x00, 0x80, 0xec, 0x6c, 0x00, 0x00, // : ;
        0x08, 0x1c, 0x36, 0x63, 0x41, 0x00, 0x14, 0x14, 0x14, 0x14, 0x14, 0x14, // < =
        0x00, 0x41, 0x63, 0x36, 0x1c, 0x08, 0x02, 0x03, 0x59, 0x5d, 0x07, 0x02, // > ?
        0x3e, 0x7f, 0x41, 0x5d, 0x57, 0x1e, 0x7e, 0x7f, 0x09, 0x09, 0x7f, 0x7e, // @ A
        0x7f, 0x7f, 0x49, 0x49, 0x7f, 0x36, 0x3e, 0x7f, 0x41, 0x41, 0x63, 0x22, // B C
        0x7f, 0x7f, 0x41, 0x41, 0x7f, 0x3e, 0x7f, 0x7f, 0x49, 0x49, 0x49, 0x41, // D E
        0x7f, 0x7f, 0x09, 0x09, 0x09, 0x01, 0x3e, 0x7f, 0x41, 0x49, 0x7b, 0x3a, // F G
        0x7f, 0x7f, 0x08, 0x08, 0x7f, 0x7f, 0x41, 0x41, 0x7f, 0x7f, 0x41, 0x41, // H I
        0x20, 0x61, 0x41, 0x7f, 0x3f, 0x01, 0x7f, 0x7f, 0x1c, 0x36, 0x63, 0x41, // J K
        0x7f, 0x7f, 0x40, 0x40, 0x40, 0x40, 0x7f, 0x7e, 0x0c, 0x0c, 0x7e, 0x7f, // L M
        0x7f, 0x7e, 0x0c, 0x18, 0x3f, 0x7f, 0x3e, 0x7f, 0x41, 0x41, 0x7f, 0x3e, // N O
        0x7f, 0x7f, 0x09, 0x09, 0x0f, 0x06, 0x3e, 0x7f, 0x41, 0x31, 0x6f, 0x5e, // P Q
        0x7f, 0x7f, 0x09, 0x19, 0x7f, 0x66, 0x26, 0x6f, 0x49, 0x49, 0x7b, 0x32, // R S
        0x01, 0x01, 0x7f, 0x7f, 0x01, 0x01, 0x3f, 0x7f, 0x40, 0x40, 0x7f, 0x3f, // T U
        0x1f, 0x3f, 0x60, 0x60, 0x3f, 0x1f, 0x7f, 0x3f, 0x18, 0x18, 0x3f, 0x7f, // V W
        0x63, 0x77, 0x1c, 0x1c, 0x77, 0x63, 0x07, 0x0f, 0x78, 0x78, 0x0f, 0x07, // X Y
        0x61, 0x71, 0x59, 0x4d, 0x47, 0x43, 0x7f, 0x7f, 0x41, 0x41, 0x41, 0x00, // Z, square bracket
        0x02, 0x06, 0x0c, 0x18, 0x30, 0x20, 0x00, 0x41, 0x41, 0x41, 0x7f, 0x7f, // \ and square bracket
        0x0c, 0x06, 0x03, 0x03, 0x06, 0x0c, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, // ^ and _
        0x00, 0x00, 0x03, 0x07, 0x04, 0x00, 0x20, 0x74, 0x54, 0x54, 0x7c, 0x78, // back quote and a
        0x7f, 0x7f, 0x44, 0x44, 0x7c, 0x38, 0x38, 0x7c, 0x44, 0x44, 0x6c, 0x28, //b c
        0x38, 0x7c, 0x44, 0x44, 0x7f, 0x7f, 0x38, 0x7c, 0x54, 0x54, 0x5c, 0x18, //d e
        0x08, 0x7e, 0x7f, 0x09, 0x09, 0x00, 0x18, 0xbc, 0xa4, 0xa4, 0xfc, 0x7c, //f g
        0x7f, 0x7f, 0x04, 0x04, 0x7c, 0x78, 0x00, 0x44, 0x7d, 0x7d, 0x40, 0x00, //h i
        0x80, 0x84, 0xfd, 0x7d, 0x00, 0x00, 0x7f, 0x7f, 0x10, 0x38, 0x6c, 0x44, //j k
        0x00, 0x41, 0x7f, 0x7f, 0x40, 0x00, 0x7c, 0x7c, 0x18, 0x18, 0x7c, 0x7c, //l m
        0x7c, 0x7c, 0x04, 0x04, 0x7c, 0x78, 0x38, 0x7c, 0x44, 0x44, 0x7c, 0x38, //n o
        0xfc, 0xfc, 0x24, 0x24, 0x3c, 0x18, 0x18, 0x3c, 0x24, 0x24, 0xfc, 0xfc, //p q
        0x7c, 0x7c, 0x08, 0x04, 0x0c, 0x08, 0x48, 0x5c, 0x54, 0x54, 0x74, 0x24, //r s
        0x04, 0x3f, 0x7f, 0x44, 0x44, 0x00, 0x3c, 0x7c, 0x40, 0x40, 0x7c, 0x7c, //t u
        0x1c, 0x3c, 0x60, 0x60, 0x3c, 0x1c, 0x7c, 0x7c, 0x30, 0x70, 0x7c, 0x3c, //v w
        0x44, 0x6c, 0x38, 0x38, 0x6c, 0x44, 0x1c, 0xbc, 0xa0, 0xa0, 0xfc, 0x7c, //x y
        0x44, 0x64, 0x74, 0x5c, 0x4c, 0x44, 0x00, 0x08, 0x3e, 0x77, 0x41, 0x00, //x {
        0x00, 0x00, 0x7f, 0x7f, 0x00, 0x00, 0x00, 0x41, 0x77, 0x3e, 0x08, 0x00, //| }
        0x06, 0x01, 0x02, 0x04, 0x03, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, // ~ and DEL = 127
        0x14, 0x3e, 0x7f, 0x55, 0x41, 0x22, 0x48, 0x5c, 0x55, 0x57, 0x75, 0x24, // Euro 128 and S-hackek 154
        0x48, 0x7e, 0x7f, 0x49, 0x4b, 0x42, 0x08, 0x08, 0x2a, 0x2a, 0x08, 0x08  //  pound 163 divide 247
    };
    
    const int EXT_CHARS[4] = {128, 154, 163, 247};

//    DigitalOut LCD_CE(mbit_p12);
//    DigitalOut LCD_RST(mbit_p8);
//    DigitalOut LCD_DC(mbit_p16);
    static Buffer bytearray = NULL;
    static bool state = true;
    static int lcdDE = 0;

    //%
    int getCEPin() {
        return mbit_p12;
    }
    
    //%
    Buffer getBuffer() {
        return bytearray;
    }
    
    //%
    Buffer initBuffer() {
        bytearray = mkBuffer(NULL,504);
        return bytearray;
    }

    int charMap(int charNum) {
        //any invalid number will return SPACE
        if (charNum < 32) return 0;
        if (charNum <  128)
            return (charNum - 32);
       else {
            int size = sizeof(EXT_CHARS) * 4;
            for (int i = 0; i < size; i++) {
                // return i + 128 - 32 to get the internal char number
                if (EXT_CHARS[i] == charNum) return (i + 96);
            }
            return 0;
        }
    }

    void invertCharBytes(int x, int y) {
        int offset = y * 84 + x * 7;
        for (int i = 0; i < 8; i++) {
            bytearray->data[offset + i] = ~bytearray->data[offset + i];
        }
    }
    
    //%
    void writeCharToBuf(int charNum, int x, int y) {
        int charbase = 6 * charMap(charNum);
        int offset = y * 84 + x * 7;
        for (int i = 0; i < 6; i++) {
            bytearray->data[offset + i] = CHAR_BYTES[charbase + i];
        }
        bytearray->data[offset + 6] = 0;
    }

    //%
    void setState(bool s) {
        state = s;
    }

    //%
    void clear() {
        for (int i = 0; i < 504; i++) {
            bytearray->data[i] = 0;
        }
    }
    


    //%
    void pixel(int x, int y, bool state) {
        if (x > 83)   return;
        if (y > 47)   return;
        if ((x | y) < 0)  return;
        uint8_t qy = 1 << (y & 7);
        int r = x + 84 * (y >> 3);
        if (state) {
        bytearray->data[r] |=  qy;
        } else {
        bytearray->data[r] &=  ~qy;
        }
    }

    //%
    void scrollRow(int row, int direction, int step = 1) {
        if ((row < 0) || (row > 5)) return;
        row *= 84;
        switch (direction) {
            case SCROLL_LEFT: {
                int rowend = row + 84;
                int r1 = rowend - step;
                for (; row < r1; row++)  bytearray->data[row] = bytearray->data[row + step];
                for (; row < rowend; row++)  bytearray->data[row] = 0;
                break; 
            }
            case SCROLL_RIGHT: {
                int r1 = row + 84 - step;
                int rowend = row + step - 1;
                for (; r1 > rowend; r1--)   bytearray->data[r1] = bytearray->data[r1 - step];
                for (; r1 >= row; r1--)  bytearray->data[r1] = 0;
                break;
            }
            case SCROLL_UP: {
                int rowend = row + 84;
                for (; row < rowend; row++) bytearray->data[row] >>= step;
                break;
            }
            case SCROLL_DOWN: {
                int rowend = row + 84;
                for (; row < rowend; row++)  bytearray->data[row] <<= step;
                break;
            }
        }
    }
    
    //%
    void scrollUpRow() {
        int j = 84;
        int i = 0;
        for (; i < 420; i++, j++)   bytearray->data[i] = bytearray->data[j]; 
        for (; i < 504; i++)   bytearray->data[i] = 0;
    }
    
    //%
    void scrollDownRow() {
        int i = 503;
        int j = i - 84;
        for (; i > 83; i--, j--) bytearray->data[i] = bytearray->data[j]; 
        for (; i >= 0; i--)  bytearray->data[i] = 0;
    }

    //%
    void scrollScreen(int direction, int step) {
        switch (direction) {
            case SCROLL_LEFT:
            case SCROLL_RIGHT:
            if (step == 0) return;
                for (int row = 0; row < 6; row++)   scrollRow(row, direction, step);
                break;
            case SCROLL_DOWN: {
                while (step > 8) {
                        scrollScreen(direction, 8);
                        step -= 8;
                }
                if (step == 0) return;
                int shft = 8 - step;
                int maskd = 0xff << shft;
                int i = 503;
                int j = i - 84;
                for (; i > 83; i--,j--)  bytearray->data[i] =  (bytearray->data[i] << step) | ((bytearray->data[j] & maskd) >> shft);
                for (; i >= 0; i--)   bytearray->data[i] <<= step;
                break;
            }
            case SCROLL_UP: {
                while (step > 8) {
                        scrollScreen(direction, 8);
                        step -= 8;
                }
                if (step == 0) return;
                int shft = 8 - step;
                int masku = (1 << step) - 1;
                int j = 84;
                int i = 0;
                for (; i < 420; i++, j++)  bytearray->data[i] =  (bytearray->data[i] >> step) | ((bytearray->data[j] & masku) << shft);
                for (; i < 504; i++)   bytearray->data[i] >>= step;
            }
        }
    }

    //%
   void vLine(int x, int y0, int y1) {
        int y = y0;
        if (y0 > y1) {
            y = y1;
            y1 = y0;
            }
        if (((x | y1) < 0) || (x > 83)) return;
        if (y < 0) y = 0;
        if (y1 > 47) y1 = 47;
        uint8_t bitmask = 0xff << (y & 7);
        int r = x + 84 *(y >> 3);
        if ((y >> 3) == (y1 >> 3)) {
            bitmask ^= 0xfe <<  (y1 & 7);
            if (state) bytearray->data[r] |= bitmask;
            else bytearray->data[r] &= ~bitmask;
        }
        else {
            int j = (y1 >> 3) - (y >> 3) - 1;
            if (state) bytearray->data[r] |= bitmask;
            else bytearray->data[r] &= ~bitmask;
            r = r + 84;
            if (state) {
                while (j > 0) {
                    bytearray->data[r] = 0xff;
                    j -= 1;
                    r = r + 84;
                }
            } else {
                while (j > 0) {
                    bytearray->data[r] = 0;
                    j -= 1;
                    r = r + 84;
                }
            }
            bitmask = (2 << (y1 & 7)) - 1;
            if (state) bytearray->data[r] |= bitmask;
            else bytearray->data[r] &= ~bitmask;
        }
    }
    
    //%
    void hLine(int x0, int x1, int y) {
        int x = x0;
        if (x0 > x1) { x = x1; x1 = x0; }
        if (((x1 | y) < 0) || (y > 47)) return;
        if (x < 0) x = 0;
        if (x1 > 83) x1 = 83;
        uint8_t bitmask = 1 << (y & 7);
        int r = x + 84 * (y >> 3);
        if (state) {
            for (; x <= x1; x++ , r++)  bytearray->data[r] |= bitmask;
        } else {
            bitmask = ~bitmask;
            for (; x <= x1; x++ , r++) bytearray->data[r] &= bitmask;
        }
    }

    //%
    void pLine(int x0, int y0, int x1, int y1) {
        int dx = abs(x1 - x0);
        if (dx == 0) {
            vLine(x0, y0, y1);
            return;
        }
        int dy = abs(y1 - y0);
        if (dy == 0) {
            hLine(x0, x1, y0);
            return;
        }
        int x = x0;
        int y = y0;
        if (dx > dy) {
            if (x0 > x1) { x = x1; y = y1; x1 = x0; y1 = y0; }
            int yc = (y1 > y) ? 1 : -1;
            int mid = (x + x1) >> 1;
            int a = dy << 1;
            int p = a - dx;
            int b = p - dx;
            pixel(x, y, state);
            while (x < x1) {
                if ((p < 0) || ((p == 0) && (x >= mid))) { p += a; }
                else { p = p + b; y += yc; }
                x++;
                pixel(x, y, state);
            }
        } else {
            if (y0 > y1) { x = x1; y = y1; x1 = x0; y1 = y0; }
            int xc = (x1 > x) ? 1 : -1;
            int mid = (y + y1) >> 1;
            int a = dx << 1;
            int p = a - dy;
            int b = p - dy;
            pixel(x, y, state);
            while (y < y1) {
                if ((p < 0) || ((p == 0) && (y >= mid))) { p += a; }
                else { p = p + b; x += xc; }
                y++; pixel(x, y, state);
            }
        }
    }

    //%
    void pBox(int x0, int y0, int x1, int y1) {
        int x = x0;
        int y = y0;
        if (x1 < x0) { x = x1; x1 = x0; }
        if (y1 < y0) { y = y1; y1 = y0; }
        if ((y1 | x1) < 0) return;
        if (y < 0) y = 0;
        if (y1 > 47) y1 = 47;
        if (x1 > 83) x1 = 83; 
        uint8_t bitmask = 0xff << (y & 7);
        y >>= 3;
        if (y == (y1 >> 3)) {
            bitmask ^= 0xfe << (y1 & 7);
            int r = 84 * y + x;
            if (state) {
                for (; x <= x1; x++ , r++) { bytearray->data[r] |= bitmask; }
            } else {
                bitmask = ~bitmask;
                for (; x <= x1; x++ , r++) { bytearray->data[r] &= bitmask; }
            }
        }
        else {
            int j = (y1 >> 3) - y - 1;
            int r = 84 * y;
            if (state) {
                for (int i = x; i <= x1; i++)  { bytearray->data[i + r] |= bitmask; }
                r += 84;
                while (j > 0) {
                    for (int i = x; i <= x1; i++)  { bytearray->data[i + r] = 0xff; }
                    j--;
                    r += 84;
                }
                bitmask = (2 << (y1 & 7)) - 1;
                for (int i = x; i <= x1; i++) { bytearray->data[i + r] |= bitmask; }
            } else {
                bitmask = ~bitmask;
                for (int i = x; i <= x1; i++) { bytearray->data[i + r] &= bitmask; }
                r += 84;
                while (j > 0) {
                    for (int i = x; i <= x1; i++) { bytearray->data[i + r] = 0; }
                    j--;
                    r += 84;
                }
                bitmask = 0xfe << (y1 & 7);
                for (int i = x; i <= x1; i++) { bytearray->data[i + r] &= bitmask; }
            }
        }
    }
}