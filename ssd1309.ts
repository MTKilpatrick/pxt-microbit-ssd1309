enum Plots {
    //% block="line"
    Line = 0,
    //% block="box"
    Box = 1,
    //% block="rectangle"
    Rect = 2
}
enum Scrolls {
    //% block="Up"
    Up = 0,
    //% block="Right"
    Right = 1,
    //% block="Down"
    Down = 2,
    //% block="Left"
    Left = 3
}

//% weight=100 color=#0fbc11
namespace ssd1309 {
    const LCD_CE: DigitalPin = DigitalPin.P12
    const LCD_RST: DigitalPin = DigitalPin.P8
    const LCD_DC: DigitalPin = DigitalPin.P16
    const LCD_CLK: DigitalPin = DigitalPin.P13
    const LCD_MOSI: DigitalPin = DigitalPin.P15
    const LCD_CMD = 0
    const LCD_DAT = 1
    let lcdDE: number = 0


    // shim for mapping the assembler buffer code to the TS function
    //% shim=sendSPIBufferAsm
    function sendSPIBuffer() {
        return
    }

    // shim for the assember code - this calls from the assembler from TS
    // I use this for sending the control bytes to configure the LCD display
    // and it works correctly when called from Typescript like this
    //% shim=sendSPIByteAsm
    export function sendSPIByte(dat: number) {
        return
    }

    //% shim=writePixelAsm
    export function writePixelAsm(x: number, y: number, state: boolean) {
        
    }

    // Send the buffer to the display (get the buffer first from the C++ realm)
    // To call the assembler code directy from Typescrip, use writeSPIBufferTS()
    // To call the assembler from C++, call the C++ fuction writeSPIBufferC
    //% block="update LCD display"
    //% blocId=ssd1309_show
    export function show(): void {
        sendSPIBuffer()
    }


    const FILL_X = hex`fffefcf8f0e0c08000`
    const FILL_B = hex`0103070f1f3f7fffff`
    const TWOS = hex`0102040810204080`
    let bytearray: Buffer = initBuffer()
    let cursorx = 0
    let cursory = 0


    export class Cursor {
        private _x: number
        private _y: number
        private _char: number
        private _invert: boolean

        constructor() {
            this._x = 0
            this._y = 0
            this._invert = false
        }
        public getX(): number {
            return this._x
        }
        public getY(): number {
            return this._y
        }
        public getChar(): number {
            return this._char
        }
        public setChar(c: number) {
            return
        }
    }

    export function fill(b: number) {
        bytearray.fill(b)
        show()
    }


    //% shim=ssd1309::initBuffer
    function initBuffer(): Buffer {
        return pins.createBuffer(1024)
    }

    //% shim=ssd1309::writeCharToBuf
    function writeCharToBuf(char: number, x: number, y: number) {
        return
    }

    //% block="show char %char at x% %y"
    //% blockId=ssd1309_show_char
    export function showChar(charNum: number) {
        if (cursorx > 11) {
            cursorx = 0
            cursory++
        }
        writeCharToBuf(charNum, cursorx, cursory)
        cursorx += 1
    }


    function cmdSPI(b: number): void {
        pins.digitalWritePin(LCD_DC, LCD_CMD)
        sendSPIByte(b)
        pins.digitalWritePin(LCD_DC, LCD_DAT)
    }



    //% block="reset LCD display"
    //% blockId=ssd1309_init
    export function init(): void {
        pins.digitalWritePin(LCD_CLK, 0)
        pins.digitalWritePin(LCD_MOSI, 0)
        pins.digitalWritePin(LCD_RST, 1)
        pins.digitalWritePin(LCD_CE, 1)
        pins.digitalWritePin(LCD_DC, LCD_DAT)
        lcdDE = 0
        basic.pause(100)
        pins.digitalWritePin(LCD_RST, 0)
        basic.pause(100)
        pins.digitalWritePin(LCD_RST, 1)
        basic.pause(100)
        cmdSPI(0xAE)    // display off
        cmdSPI(0xA4)    // not entire display on
        cmdSPI(0x81); cmdSPI(0x80) // contrast
        cmdSPI(0xD5); cmdSPI(0x10) // contrast
        cmdSPI(0x20); cmdSPI(0x00) // horizontal mode
        cmdSPI(0x21); cmdSPI(0x00); cmdSPI(0x7f)  // column address
        cmdSPI(0x22); cmdSPI(0x00); cmdSPI(0x3f)  // page address
        cmdSPI(0xAF)    // display on
        setState(true)
        clear()
    }



    //% shim=TD_ID
    //% blockId="dir_conv" block="%dir"
    //% blockHidden=true
    export function dirs(dir: Scrolls): number {
        return (dir || 0)
    }

    //% shim=TD_ID
    //% blockId="displaymode_conv" block="%displaymode"
    //% blockHidden=true
    export function lcddm(displaymode: number): number {
        return (displaymode || 0)
    }

    //% shim=TD_ID
    //% blockId="plot_conv" block="%plot"
    //% blockHidden=true
    export function pl(plot: Plots): number {
        return (plot || 0)
    }

    //% blockId=ssd1309_pixel
    //% block="pixel at x %x y %y %state"
    //% state.shadow="toggleOnOff" state.defl=true
    //% inlineInputMode=inline
    //% shim=ssd1309::pixel
    export function pixel(x: number, y: number, state: boolean): void {
        return
    }

    //% shim=ssd1309::scrollRow
    //% block="scroll screen direction %direction=dir_conv || step %step"
    //% expandableArgumentMode="toggle"
    //% step.min=0 step.defl=1
    export function scrollRow(row: number, direction: number, step: number = 1): void {
        return
    }

    //% shim=ssd1309::scrollUpRow
    export function scrollUpRow() {
        return
    }
    //% shim=ssd1309::scrollDownRow
    export function scrollDownRow() {
        return
    }

    //% shim=ssd1309::scrollScreen
    //% block="scroll direction %direction=dir_conv || step %step"
    //% expandableArgumentMode="toggle"
    //% step.min=0 step.defl=1
    export function scrollScreen(direction: number, step: number = 1): void {
        return
    }

    //% blockId=ssd1309_display_row
    //% block="display row %row"
    export function displayRow(row: number): void {
    }

    //% shim=ssd1309::setState
    function setState(s: boolean) {
        return
    }

    //% shim=ssd1309::pLine
    function pLine(x0: number, y0: number, x1: number, y1: number): void {
        return
    }
    //% shim=ssd1309::pBox
    function pBox(x0: number, y0: number, x1: number, y1: number): void {
        return
    }
    //% shim=ssd1309::vLine
    function vLine(x: number, y0: number, y1: number): void {
        return
    }

    //% shim=ssd1309::hLine
    function hLine(x0: number, x1: number, y: number): void {
        return
    }

    //% blockId=ssd1309_plot
    //% block="draw %plot=plot_conv from x %x0 y %y0 to x %x1 y %y1 $state"
    //% state.shadow="toggleOnOff" state.defl=true
    //% inlineInputMode=inline
    export function plot(plot: Plots, x0: number, y0: number, x1: number, y1: number, state: boolean): void {
        setState(state)
        switch (plot) {
            case 0: { pLine(x0, y0, x1, y1); break }
            case 1: { pBox(x0, y0, x1, y1); break }
            case 2: {
                hLine(x0, x1, y0)
                hLine(x0, x1, y1)
                vLine(x0, y0, y1)
                vLine(x1, y0, y1)
                break
            }
            default: pLine(x0, y0, x1, y1)
        }
    }



    //% blockId=ssd1309_clear
    //% block="clear screen"
    //% shim=ssd1309::clear
    export function clear(): void {
        return
    }
}
ssd1309.init()