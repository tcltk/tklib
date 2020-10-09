#==============================================================================
# Contains procedures that create various bitmap and photo images.  The
# argument w specifies a canvas displaying a sort arrow, while the argument win
# stands for a tablelist widget.
#
# Copyright (c) 2006-2020  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

#------------------------------------------------------------------------------
# tablelist::flat6x4Arrows
#------------------------------------------------------------------------------
proc tablelist::flat6x4Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp6x4_width 6
#define triangleUp6x4_height 4
static unsigned char triangleUp6x4_bits[] = {
   0x0c, 0x1e, 0x3f, 0x3f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn6x4_width 6
#define triangleDn6x4_height 4
static unsigned char triangleDn7x4_bits[] = {
   0x3f, 0x3f, 0x1e, 0x0c};
"
}

#------------------------------------------------------------------------------
# tablelist::flat7x4Arrows
#------------------------------------------------------------------------------
proc tablelist::flat7x4Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp7x4_width 7
#define triangleUp7x4_height 4
static unsigned char triangleUp7x4_bits[] = {
   0x08, 0x1c, 0x3e, 0x7f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn7x4_width 7
#define triangleDn7x4_height 4
static unsigned char triangleDn7x4_bits[] = {
   0x7f, 0x3e, 0x1c, 0x08};
"
}

#------------------------------------------------------------------------------
# tablelist::flat7x5Arrows
#------------------------------------------------------------------------------
proc tablelist::flat7x5Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp7x5_width 7
#define triangleUp7x5_height 5
static unsigned char triangleUp7x5_bits[] = {
   0x08, 0x1c, 0x3e, 0x7f, 0x7f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn7x5_width 7
#define triangleDn7x5_height 5
static unsigned char triangleDn7x5_bits[] = {
   0x7f, 0x7f, 0x3e, 0x1c, 0x08};
"
}

#------------------------------------------------------------------------------
# tablelist::flat7x7Arrows
#------------------------------------------------------------------------------
proc tablelist::flat7x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp7x7_width 7
#define triangleUp7x7_height 7
static unsigned char triangleUp7x7_bits[] = {
   0x08, 0x1c, 0x1c, 0x3e, 0x3e, 0x7f, 0x7f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn7x7_width 7
#define triangleDn7x7_height 7
static unsigned char triangleDn7x7_bits[] = {
   0x7f, 0x7f, 0x3e, 0x3e, 0x1c, 0x1c, 0x08};
"
}

#------------------------------------------------------------------------------
# tablelist::flat8x4Arrows
#------------------------------------------------------------------------------
proc tablelist::flat8x4Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp8x4_width 8
#define triangleUp8x4_height 4
static unsigned char triangleUp8x4_bits[] = {
   0x18, 0x3c, 0x7e, 0xff};
"
    image create bitmap triangleDn$w -data "
#define triangleDn8x4_width 8
#define triangleDn8x4_height 4
static unsigned char triangleDn8x4_bits[] = {
   0xff, 0x7e, 0x3c, 0x18};
"
}

#------------------------------------------------------------------------------
# tablelist::flat8x5Arrows
#------------------------------------------------------------------------------
proc tablelist::flat8x5Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp8x5_width 8
#define triangleUp8x5_height 5
static unsigned char triangleUp8x5_bits[] = {
   0x18, 0x3c, 0x7e, 0xff, 0xff};
"
    image create bitmap triangleDn$w -data "
#define triangleDn8x5_width 8
#define triangleDn8x5_height 5
static unsigned char triangleDn8x5_bits[] = {
   0xff, 0xff, 0x7e, 0x3c, 0x18};
"
}

#------------------------------------------------------------------------------
# tablelist::flat9x5Arrows
#------------------------------------------------------------------------------
proc tablelist::flat9x5Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp9x5_width 9
#define triangleUp9x5_height 5
static unsigned char triangleUp9x5_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x7c, 0x00, 0xfe, 0x00, 0xff, 0x01};
"
    image create bitmap triangleDn$w -data "
#define triangleDn9x5_width 9
#define triangleDn9x5_height 5
static unsigned char triangleDn9x5_bits[] = {
   0xff, 0x01, 0xfe, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flat9x6Arrows
#------------------------------------------------------------------------------
proc tablelist::flat9x6Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp9x6_width 9
#define triangleUp9x6_height 6
static unsigned char triangleUp9x6_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x7c, 0x00, 0xfe, 0x00, 0xff, 0x01, 0xff, 0x01};
"
    image create bitmap triangleDn$w -data "
#define triangleDn9x6_width 9
#define triangleDn9x6_height 6
static unsigned char triangleDn9x6_bits[] = {
   0xff, 0x01, 0xff, 0x01, 0xfe, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flat11x6Arrows
#------------------------------------------------------------------------------
proc tablelist::flat11x6Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp11x6_width 11
#define triangleUp11x6_height 6
static unsigned char triangleUp11x6_bits[] = {
   0x20, 0x00, 0x70, 0x00, 0xf8, 0x00, 0xfc, 0x01, 0xfe, 0x03, 0xff, 0x07};
"
    image create bitmap triangleDn$w -data "
#define triangleDn11x6_width 11
#define triangleDn11x6_height 6
static unsigned char triangleDn11x6_bits[] = {
   0xff, 0x07, 0xfe, 0x03, 0xfc, 0x01, 0xf8, 0x00, 0x70, 0x00, 0x20, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flat13x7Arrows
#------------------------------------------------------------------------------
proc tablelist::flat13x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp13x7_width 13
#define triangleUp13x7_height 7
static unsigned char triangleUp13x7_bits[] = {
   0x40, 0x00, 0xe0, 0x00, 0xf0, 0x01, 0xf8, 0x03, 0xfc, 0x07, 0xfe, 0x0f,
   0xff, 0x1f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn13x7_width 13
#define triangleDn13x7_height 7
static unsigned char triangleDn13x7_bits[] = {
   0xff, 0x1f, 0xfe, 0x0f, 0xfc, 0x07, 0xf8, 0x03, 0xf0, 0x01, 0xe0, 0x00,
   0x40, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flat15x8Arrows
#------------------------------------------------------------------------------
proc tablelist::flat15x8Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp15x8_width 15
#define triangleUp15x8_height 8
static unsigned char triangleUp15x8_bits[] = {
   0x80, 0x00, 0xc0, 0x01, 0xe0, 0x03, 0xf0, 0x07, 0xf8, 0x0f, 0xfc, 0x1f,
   0xfe, 0x3f, 0xff, 0x7f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn15x8_width 15
#define triangleDn15x8_height 8
static unsigned char triangleDn15x8_bits[] = {
   0xff, 0x7f, 0xfe, 0x3f, 0xfc, 0x1f, 0xf8, 0x0f, 0xf0, 0x07, 0xe0, 0x03,
   0xc0, 0x01, 0x80, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle7x4Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle7x4Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp7x4_width 7
#define triangleUp7x4_height 4
static unsigned char triangleUp7x4_bits[] = {
   0x08, 0x1c, 0x36, 0x63};
"
    image create bitmap triangleDn$w -data "
#define triangleDn7x4_width 7
#define triangleDn7x4_height 4
static unsigned char triangleDn7x4_bits[] = {
   0x63, 0x36, 0x1c, 0x08};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle7x5Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle7x5Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp7x5_width 7
#define triangleUp7x5_height 5
static unsigned char triangleUp7x5_bits[] = {
   0x08, 0x1c, 0x3e, 0x77, 0x63};
"
    image create bitmap triangleDn$w -data "
#define triangleDn7x5_width 7
#define triangleDn7x5_height 5
static unsigned char triangleDn7x5_bits[] = {
   0x63, 0x77, 0x3e, 0x1c, 0x08};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle9x5Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle9x5Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp9x5_width 9
#define triangleUp9x5_height 5
static unsigned char triangleUp9x5_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x6c, 0x00, 0xc6, 0x00, 0x83, 0x01};
"
    image create bitmap triangleDn$w -data "
#define triangleDn9x5_width 9
#define triangleDn9x5_height 5
static unsigned char triangleDn9x5_bits[] = {
   0x83, 0x01, 0xc6, 0x00, 0x6c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle9x6Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle9x6Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp9x6_width 9
#define triangleUp9x6_height 6
static unsigned char triangleUp9x6_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x7c, 0x00, 0xee, 0x00, 0xc7, 0x01, 0x83, 0x01};
"
    image create bitmap triangleDn$w -data "
#define triangleDn9x6_width 9
#define triangleDn9x6_height 6
static unsigned char triangleDn9x6_bits[] = {
   0x83, 0x01, 0xc7, 0x01, 0xee, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle9x7Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle9x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp9x7_width 9
#define triangleUp9x7_height 7
static unsigned char triangleUp9x7_bits[] = {
   0x10, 0x00, 0x38, 0x00, 0x7c, 0x00, 0xfe, 0x00, 0xef, 0x01, 0xc7, 0x01,
   0x83, 0x01};
"
    image create bitmap triangleDn$w -data "
#define triangleDn9x7_width 9
#define triangleDn9x7_height 7
static unsigned char triangleDn9x7_bits[] = {
   0x83, 0x01, 0xc7, 0x01, 0xef, 0x01, 0xfe, 0x00, 0x7c, 0x00, 0x38, 0x00,
   0x10, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle10x6Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle10x6Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp10x6_width 10
#define triangleUp10x6_height 6
static unsigned char triangleUp10x6_bits[] = {
   0x30, 0x00, 0x78, 0x00, 0xfc, 0x00, 0xce, 0x01, 0x87, 0x03, 0x03, 0x03};
"
    image create bitmap triangleDn$w -data "
#define triangleDn10x6_width 10
#define triangleDn10x6_height 6
static unsigned char triangleDn10x6_bits[] = {
   0x03, 0x03, 0x87, 0x03, 0xce, 0x01, 0xfc, 0x00, 0x78, 0x00, 0x30, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle10x7Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle10x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp10x7_width 10
#define triangleUp10x7_height 7
static unsigned char triangleUp10x7_bits[] = {
   0x30, 0x00, 0x78, 0x00, 0xfc, 0x00, 0xfe, 0x01, 0xcf, 0x03, 0x87, 0x03,
   0x03, 0x03};
"
    image create bitmap triangleDn$w -data "
#define triangleDn10x7_width 10
#define triangleDn10x7_height 7
static unsigned char triangleDn10x6_bits[] = {
   0x03, 0x03, 0x87, 0x03, 0xcf, 0x03, 0xfe, 0x01, 0xfc, 0x00, 0x78, 0x00,
   0x30, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle11x6Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle11x6Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp11x6_width 11
#define triangleUp11x6_height 6
static unsigned char triangleUp11x6_bits[] = {
   0x20, 0x00, 0x70, 0x00, 0xd8, 0x00, 0x8c, 0x01, 0x06, 0x03, 0x03, 0x06};
"
    image create bitmap triangleDn$w -data "
#define triangleDn11x6_width 11
#define triangleDn11x6_height 6
static unsigned char triangleDn11x6_bits[] = {
   0x03, 0x06, 0x06, 0x03, 0x8c, 0x01, 0xd8, 0x00, 0x70, 0x00, 0x20, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle13x7Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle13x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp13x7_width 13
#define triangleUp13x7_height 7
static unsigned char triangleUp13x7_bits[] = {
   0x40, 0x00, 0xe0, 0x00, 0xb0, 0x01, 0x18, 0x03, 0x0c, 0x06, 0x06, 0x0c,
   0x03, 0x18};
"
    image create bitmap triangleDn$w -data "
#define triangleDn13x7_width 13
#define triangleDn13x7_height 7
static unsigned char triangleDn13x7_bits[] = {
   0x03, 0x18, 0x06, 0x0c, 0x0c, 0x06, 0x18, 0x03, 0xb0, 0x01, 0xe0, 0x00,
   0x40, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::flatAngle15x8Arrows
#------------------------------------------------------------------------------
proc tablelist::flatAngle15x8Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp15x8_width 15
#define triangleUp15x8_height 8
static unsigned char triangleUp15x8_bits[] = {
   0x80, 0x00, 0xc0, 0x01, 0x60, 0x03, 0x30, 0x06, 0x18, 0x0c, 0x0c, 0x18,
   0x06, 0x30, 0x03, 0x60};
"
    image create bitmap triangleDn$w -data "
#define triangleDn15x8_width 15
#define triangleDn15x8_height 8
static unsigned char triangleDn15x8_bits[] = {
   0x03, 0x60, 0x06, 0x30, 0x0c, 0x18, 0x18, 0x0c, 0x30, 0x06, 0x60, 0x03,
   0xc0, 0x01, 0x80, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::photo7x4Arrows
#------------------------------------------------------------------------------
proc tablelist::photo7x4Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
R0lGODlhBwAEAIQRAAAAADxZbDxeckNfb0BidF6IoWGWtlabwIexxZq2xYbI65HL7LXd8rri9MPk
9cTj9Mrm9f///////////////////////////////////////////////////////////yH5BAEK
AB8ALAAAAAAHAAQAAAUS4CcSYikcRRkYypJ8A9IwD+SEADs=
"
    triangleDn$w put "
R0lGODlhBwAEAIQQAAAAADxeclKLq2KauWes03CpxnKrynOy2IO62ZXG4JrH4JrL5pnQ7qbY87Pb
8cTj9P///////////////////////////////////////////////////////////////yH5BAEK
AAAALAAAAAAHAAQAAAUSYDAUBpIogHAwzgO8ROO+70KHADs=
"
}

#------------------------------------------------------------------------------
# tablelist::photo7x7Arrows
#------------------------------------------------------------------------------
proc tablelist::photo7x7Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAABGdBTUEAALGPC/xhBQAAACBjSFJN
AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAACXBIWXMAAA7DAAAOwwHHb6hk
AAAAGnRFWHRTb2Z0d2FyZQBQYWludC5ORVQgdjMuNS4xMDD0cqEAAABCSURBVBhXXY4BCgAgCAP9
T//R9/Ryc+ZEHCyb40CB3D1n6OAZuQOKi9klPhUsjNJ6VwUp+tOLopOGNkXncToWw6IPjiowJNyp
gu8AAAAASUVORK5CYII=
"
    triangleDn$w put "
iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHCAYAAADEUlfTAAAABGdBTUEAALGPC/xhBQAAAAlwSFlz
AAAOwwAADsMBx2+oZAAAABp0RVh0U29mdHdhcmUAUGFpbnQuTkVUIHYzLjUuMTAw9HKhAAAAP0lE
QVQYV22LgQ0AIAjD9g//yD1ejoBoFpRkISsUPsMzPwkOIcARmJlvKMGIJq9jt+Uem51Wscfe1hkq
8VAdWKBfMCRjQcZZAAAAAElFTkSuQmCC
"
}

#------------------------------------------------------------------------------
# tablelist::photo9x5Arrows
#------------------------------------------------------------------------------
proc tablelist::photo9x5Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
R0lGODlhCQAFAIQTAAAAADxeckBidGaJmlabwG6mw4exxZy9z4bI647M7JvS76HV8KjX8a3a8rPc
8rLe87jf9Lzh9MPk9f///////////////////////////////////////////////////yH5BAEK
AB8ALAAAAAAJAAUAAAUZ4Cd+wWgGhGCSBKIMY1AkSwMdpPEwTiT9IQA7
"
    triangleDn$w put "
R0lGODlhCQAFAIQSAAAAADxeck90imuUrGKauW2jwWes036xzXOy2IO83YO83o++2JrH4JrK5rPZ
7rPZ77TZ7sTj9P///////////////////////////////////////////////////////yH5BAEK
AB8ALAAAAAAJAAUAAAUaYECMxbEwzCcgSNJA0ScPSuPEsmw8eC43vhAAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::photo11x6Arrows
#------------------------------------------------------------------------------
proc tablelist::photo11x6Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
R0lGODlhCwAGAKUjAAAAADJdfDJefDFefjRffDhhfC9njDNrjThtjj5xkUJykWuXs2Ogw2ukxHKp
yHusyZrD2o7M7JfQ7qDE2qfH2arJ2aPQ6aLU76Td+6/h/bDi/rrj+bjm/rrn/8Pm+sLr/8Ps/8ro
+szu////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAALAAYAAAYqwJ9Q
WBgahQTF4ohMPCyQYwDhuHA2k6Hg0JBkOh8P5TcwMCIYTQckClWCADs=
"
    triangleDn$w put "
R0lGODlhCwAGAKUkAAAAADl1ml+DnlaRtWGZu2ievXaet2+gvXekvmKfw32owXu314Kqwoiswoey
yo21zIa+3JC2zZ26y5DB3ZjG34fE5ZHJ55/J4ZrN6KTC1KjN4qLb+azf+rrV5rDi/rrn/7/m+8Ps
/8vu/9Pw////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAALAAYAAAYqQEFg
QCgcEApGQ/IzJBaQCeWi6fyujsrG8wmNruCHhfMRgc8RDOjMzrCDADs=
"
}

#------------------------------------------------------------------------------
# tablelist::photo13x7Arrows
#------------------------------------------------------------------------------
proc tablelist::photo13x7Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
R0lGODlhDQAHAKUwAAAAAC1pjjVmhjJrjzppiD1qiTVtkTpwkTxwkUFsikRuilKPs16Rr1aStFyU
tWeHnGKKo2CWtXGhvXOy1Hu01YKovo2xxIC314S31JGyx5W1x5i2yJG915nE2p/F247K65bF4JbN
7Z3Q7Z7X9abJ3azX76fa9qzb9and+bLb8Lne8rHg+rLi+7fi+bnk+73l+v//////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAANAAcAAAY4wJ9w
+BgajQoB5IhEMCQV5i9xiGBAHMuxYHBcRKdSJzMsDBqUkGnVSnk0P0JgMfmMUCzXS0XaBAEAOw==
"
    triangleDn$w put "
R0lGODlhDQAHAKUwAAAAAEaGqlWFpVyav2SVtGCew26tz3OkwXamwnuow36pw3Gv0nSz13iz0361
1IK00oa41Yy815m5zJO+2JjC2Z/D2J7E2obC4o/I5o3J6pTM65jM6J/P6ZzP657X9avH2anP5afS
6q7U6azV66fa9qnZ9Knd+bjV5rrc8bHg+rLi+7fi+b/g8rnk+7zl+sXh8v//////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAANAAcAAAY4QEGg
YGg4IJEJxVL5/AgDxgWz4YRGotNve1hkPCZVy/XamhENDSm1YpnfCUenhHrbFQ+QfS/ZBwEAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::photo15x8Arrows
#------------------------------------------------------------------------------
proc tablelist::photo15x8Arrows w {
    foreach dir {Up Dn} {
	image create photo triangle$dir$w
    }

    triangleUp$w put "
R0lGODlhDwAIAKU/AAAAAB1YfjJefy1pjjVmhjJrjzppiD1qiTVtkTpwkTxwkT18oUFsikRuilKP
s16Rr1aStFyUtWeHnGKKo2CWtXGhvV6dwnOy1Ha02Hu01YKovommuI2xxIC314S31JGyx5W1x5S3
zJi2yJG915nE2p/F24fD44/I5o7K65bF4JbN7ZjM6J/P6Z3Q7Z7X9abJ3anN4KfS6q/U6azV66zX
76fa9qzb9and+bLb8Lne8rHg+rLi+7fi+bnk+73l+v///yH5BAEKAD8ALAAAAAAPAAgAAAZJwJ9w
+JMQj8QGYYI8NhSPiqYpZCQontSI0zwgIp2WjUb6HA8FSEZV0/FwJdDQMHBcUK7brufLvUQ/AgEL
FhgmJyssMTMyMCEbQQA7
"
    triangleDn$w put "
R0lGODlhDwAIAKU/AAAAACdjiUBtjkKBpkaGqlWFpVaUuFyav2SVtGGdv2Cew2ehwm2jw26tz3Ok
wXOmw3amwnuow3ioxH6pw3Gv0nSz13iz03611ICsxYOux4mtwomxyI2yyIK00oa41Yy815KvwZm5
zJO+2JjC2Z/D2J7E2obC4o/I5o3J6pTM65jM6J/P6ZzP657X9avH2anP5afS6q7U6azV66fa9qnZ
9Knd+bjV5rrc8bHg+rLi+7fi+b/g8rnk+7zl+sXh8v///yH5BAEKAD8ALAAAAAAPAAgAAAZIQEFg
YEgsGA8JJrPhaEC/AkHRsFw8H9GoRHL9vohDxXRSrWCymO3LdlBQrVqO1/Ox7xBLaobT7e6AERcs
NDeAhxMdL4eMIYxBADs=
"
}

#------------------------------------------------------------------------------
# tablelist::sunken8x7Arrows
#------------------------------------------------------------------------------
proc tablelist::sunken8x7Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp8x7_width 8
#define triangleUp8x7_height 7
static unsigned char triangleUp8x7_bits[] = {
   0x18, 0x3c, 0x3c, 0x7e, 0x7e, 0xff, 0xff};
"
    image create bitmap darkLineUp$w -data "
#define darkLineUp8x7_width 8
#define darkLineUp8x7_height 7
static unsigned char darkLineUp8x7_bits[] = {
   0x08, 0x0c, 0x04, 0x06, 0x02, 0x03, 0x00};
"
    image create bitmap lightLineUp$w -data "
#define lightLineUp8x7_width 8
#define lightLineUp8x7_height 7
static unsigned char lightLineUp8x7_bits[] = {
   0x10, 0x30, 0x20, 0x60, 0x40, 0xc0, 0xff};
"
    image create bitmap triangleDn$w -data "
#define triangleDn8x7_width 8
#define triangleDn8x7_height 7
static unsigned char triangleDn8x7_bits[] = {
   0xff, 0xff, 0x7e, 0x7e, 0x3c, 0x3c, 0x18};
"
    image create bitmap darkLineDn$w -data "
#define darkLineDn8x7_width 8
#define darkLineDn8x7_height 7
static unsigned char darkLineDn8x7_bits[] = {
   0xff, 0x03, 0x02, 0x06, 0x04, 0x0c, 0x08};
"
    image create bitmap lightLineDn$w -data "
#define lightLineDn8x7_width 8
#define lightLineDn8x7_height 7
static unsigned char lightLineDn8x7_bits[] = {
   0x00, 0xc0, 0x40, 0x60, 0x20, 0x30, 0x10};
"
}

#------------------------------------------------------------------------------
# tablelist::sunken10x9Arrows
#------------------------------------------------------------------------------
proc tablelist::sunken10x9Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp10x9_width 10
#define triangleUp10x9_height 9
static unsigned char triangleUp10x9_bits[] = {
   0x30, 0x00, 0x78, 0x00, 0x78, 0x00, 0xfc, 0x00, 0xfc, 0x00, 0xfe, 0x01,
   0xfe, 0x01, 0xff, 0x03, 0xff, 0x03};
"
    image create bitmap darkLineUp$w -data "
#define darkLineUp10x9_width 10
#define darkLineUp10x9_height 9
static unsigned char darkLineUp10x9_bits[] = {
   0x10, 0x00, 0x18, 0x00, 0x08, 0x00, 0x0c, 0x00, 0x04, 0x00, 0x06, 0x00,
   0x02, 0x00, 0x03, 0x00, 0x00, 0x00};
"
    image create bitmap lightLineUp$w -data "
#define lightLineUp10x9_width 10
#define lightLineUp10x9_height 9
static unsigned char lightLineUp10x9_bits[] = {
   0x20, 0x00, 0x60, 0x00, 0x40, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x01,
   0x00, 0x01, 0x00, 0x03, 0xff, 0x03};
"
    image create bitmap triangleDn$w -data "
#define triangleDn10x9_width 10
#define triangleDn10x9_height 9
static unsigned char triangleDn10x9_bits[] = {
   0xff, 0x03, 0xff, 0x03, 0xfe, 0x01, 0xfe, 0x01, 0xfc, 0x00, 0xfc, 0x00,
   0x78, 0x00, 0x78, 0x00, 0x30, 0x00};
"
    image create bitmap darkLineDn$w -data "
#define darkLineDn10x9_width 10
#define darkLineDn10x9_height 9
static unsigned char darkLineDn10x9_bits[] = {
   0xff, 0x03, 0x03, 0x00, 0x02, 0x00, 0x06, 0x00, 0x04, 0x00, 0x0c, 0x00,
   0x08, 0x00, 0x18, 0x00, 0x10, 0x00};
"
    image create bitmap lightLineDn$w -data "
#define lightLineDn10x9_width 10
#define lightLineDn10x9_height 9
static unsigned char lightLineDn10x9_bits[] = {
   0x00, 0x00, 0x00, 0x03, 0x00, 0x01, 0x80, 0x01, 0x80, 0x00, 0xc0, 0x00,
   0x40, 0x00, 0x60, 0x00, 0x20, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::sunken12x11Arrows
#------------------------------------------------------------------------------
proc tablelist::sunken12x11Arrows w {
    image create bitmap triangleUp$w -data "
#define triangleUp12x11_width 12
#define triangleUp12x11_height 11
static unsigned char triangleUp12x11_bits[] = {
   0x60, 0x00, 0xf0, 0x00, 0xf0, 0x00, 0xf8, 0x01, 0xf8, 0x01, 0xfc, 0x03,
   0xfc, 0x03, 0xfe, 0x07, 0xfe, 0x07, 0xff, 0x0f, 0xff, 0x0f};
"
    image create bitmap darkLineUp$w -data "
#define darkLineUp12x11_width 12
#define darkLineUp12x11_height 11
static unsigned char darkLineUp12x11_bits[] = {
   0x20, 0x00, 0x30, 0x00, 0x10, 0x00, 0x18, 0x00, 0x08, 0x00, 0x0c, 0x00,
   0x04, 0x00, 0x06, 0x00, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00};
"
    image create bitmap lightLineUp$w -data "
#define lightLineUp12x11_width 12
#define lightLineUp12x11_height 11
static unsigned char lightLineUp12x11_bits[] = {
   0x40, 0x00, 0xc0, 0x00, 0x80, 0x00, 0x80, 0x01, 0x00, 0x01, 0x00, 0x03,
   0x00, 0x02, 0x00, 0x06, 0x00, 0x04, 0x00, 0x0c, 0xff, 0x0f};
"
    image create bitmap triangleDn$w -data "
#define triangleDn12x11_width 12
#define triangleDn12x11_height 11
static unsigned char triangleDn12x11_bits[] = {
   0xff, 0x0f, 0xff, 0x0f, 0xfe, 0x07, 0xfe, 0x07, 0xfc, 0x03, 0xfc, 0x03,
   0xf8, 0x01, 0xf8, 0x01, 0xf0, 0x00, 0xf0, 0x00, 0x60, 0x00};
"
    image create bitmap darkLineDn$w -data "
#define darkLineDn12x11_width 12
#define darkLineDn12x11_height 11
static unsigned char darkLineDn12x11_bits[] = {
   0xff, 0x0f, 0x03, 0x00, 0x02, 0x00, 0x06, 0x00, 0x04, 0x00, 0x0c, 0x00,
   0x08, 0x00, 0x18, 0x00, 0x10, 0x00, 0x30, 0x00, 0x20, 0x00};
"
    image create bitmap lightLineDn$w -data "
#define lightLineDn12x11_width 12
#define lightLineDn12x11_height 11
static unsigned char lightLineDn12x11_bits[] = {
   0x00, 0x00, 0x00, 0x0c, 0x00, 0x04, 0x00, 0x06, 0x00, 0x02, 0x00, 0x03,
   0x00, 0x01, 0x80, 0x01, 0x80, 0x00, 0xc0, 0x00, 0x40, 0x00};
"
}

#------------------------------------------------------------------------------
# tablelist::createSortRankImgs
#------------------------------------------------------------------------------
proc tablelist::createSortRankImgs win {
    image create bitmap sortRank1$win -data "
#define sortRank1_width 4
#define sortRank1_height 6
static unsigned char sortRank1_bits[] = {
   0x04, 0x06, 0x04, 0x04, 0x04, 0x04};
"
    image create bitmap sortRank2$win -data "
#define sortRank2_width 4
#define sortRank2_height 6
static unsigned char sortRank2_bits[] = {
   0x06, 0x09, 0x08, 0x04, 0x02, 0x0f};
"
    image create bitmap sortRank3$win -data "
#define sortRank3_width 4
#define sortRank3_height 6
static unsigned char sortRank3_bits[] = {
   0x0f, 0x08, 0x06, 0x08, 0x09, 0x06};
"
    image create bitmap sortRank4$win -data "
#define sortRank4_width 4
#define sortRank4_height 6
static unsigned char sortRank4_bits[] = {
   0x04, 0x06, 0x05, 0x0f, 0x04, 0x04};
"
    image create bitmap sortRank5$win -data "
#define sortRank5_width 4
#define sortRank5_height 6
static unsigned char sortRank5_bits[] = {
   0x0f, 0x01, 0x07, 0x08, 0x09, 0x06};
"
    image create bitmap sortRank6$win -data "
#define sortRank6_width 4
#define sortRank6_height 6
static unsigned char sortRank6_bits[] = {
   0x06, 0x01, 0x07, 0x09, 0x09, 0x06};
"
    image create bitmap sortRank7$win -data "
#define sortRank7_width 4
#define sortRank7_height 6
static unsigned char sortRank7_bits[] = {
   0x0f, 0x08, 0x04, 0x04, 0x02, 0x02};
"
    image create bitmap sortRank8$win -data "
#define sortRank8_width 4
#define sortRank8_height 6
static unsigned char sortRank8_bits[] = {
   0x06, 0x09, 0x06, 0x09, 0x09, 0x06};
"
    image create bitmap sortRank9$win -data "
#define sortRank9_width 4
#define sortRank9_height 6
static unsigned char sortRank9_bits[] = {
   0x06, 0x09, 0x09, 0x0e, 0x08, 0x06};
"
}

#------------------------------------------------------------------------------
# tablelist::createCheckbuttonImgs
#------------------------------------------------------------------------------
proc tablelist::createCheckbuttonImgs {} {
    variable checkedImg   [image create bitmap tablelist_checkedImg]
    variable uncheckedImg [image create bitmap tablelist_uncheckedImg]

    variable scalingpct
    variable winSys
    set onX11 [expr {[string compare $winSys "x11"] == 0}]

    switch $scalingpct {
	100 {
	    if {$onX11} {
		set checkedData "
#define checked_width 9
#define checked_height 9
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x80, 0x00, 0xc0, 0x00, 0xe2, 0x00, 0x76, 0x00, 0x3e, 0x00,
   0x1c, 0x00, 0x08, 0x00, 0x00, 0x00};
"
	    } else {
		set checkedData "
#define checked_width 7
#define checked_height 7
static unsigned char checked_bits[] = {
   0x40, 0x60, 0x71, 0x3b, 0x1f, 0x0e, 0x04};
"
	    }
	    set uncheckedData "
#define unchecked_width 9
#define unchecked_height 9
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	}

	125 {
	    if {$onX11} {
		set checkedData "
#define checked_width 12
#define checked_height 12
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x80, 0x03, 0xc4, 0x01,
   0xec, 0x00, 0x7c, 0x00, 0x38, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 12
#define unchecked_height 12
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    } else {
		set checkedData "
#define checked_width 8
#define checked_height 8
static unsigned char checked_bits[] = {
   0x80, 0xc0, 0xe0, 0x71, 0x3b, 0x1f, 0x0e, 0x04};
"
		set uncheckedData "
#define unchecked_width 10
#define unchecked_height 10
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}

	150 {
	    if {$onX11} {
		set checkedData "
#define checked_width 16
#define checked_height 16
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x38, 0x00, 0x3c,
   0x00, 0x1e, 0x0c, 0x0f, 0x9c, 0x07, 0xfc, 0x03, 0xf8, 0x01, 0xf0, 0x00,
   0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 16
#define unchecked_height 16
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    } else {
		set checkedData "
#define checked_width 12
#define checked_height 12
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x0c, 0x00, 0x0e, 0x00, 0x0f, 0x80, 0x07, 0xc3, 0x03,
   0xe7, 0x01, 0xff, 0x00, 0x7e, 0x00, 0x3c, 0x00, 0x18, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 14
#define unchecked_height 14
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00};
"
	    }
	}

	175 {
	    if {$onX11} {
		set checkedData "
#define checked_width 19
#define checked_height 19
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01,
   0x00, 0xc0, 0x01, 0x00, 0xe0, 0x01, 0x00, 0xf0, 0x01, 0x00, 0xf8, 0x00,
   0x0c, 0x7c, 0x00, 0x1c, 0x3e, 0x00, 0x3c, 0x1f, 0x00, 0xfc, 0x0f, 0x00,
   0xf8, 0x07, 0x00, 0xf0, 0x03, 0x00, 0xe0, 0x01, 0x00, 0xc0, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 19
#define unchecked_height 19
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    } else {
		set checkedData "
#define checked_width 15
#define checked_height 15
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x60, 0x00, 0x70, 0x00, 0x78, 0x00, 0x7c, 0x00, 0x3e,
   0x03, 0x1f, 0x87, 0x0f, 0xcf, 0x07, 0xff, 0x03, 0xfe, 0x01, 0xfc, 0x00,
   0x78, 0x00, 0x30, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 17
#define unchecked_height 17
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00};
"
	    }
	}

	200 {
	    if {$onX11} {
		set checkedData "
#define checked_width 22
#define checked_height 22
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c,
   0x00, 0x00, 0x0e, 0x00, 0x00, 0x0f, 0x00, 0x80, 0x0f, 0x00, 0xc0, 0x0f,
   0x00, 0xe0, 0x07, 0x0c, 0xf0, 0x03, 0x1c, 0xf8, 0x01, 0x3c, 0xfc, 0x00,
   0x7c, 0x7e, 0x00, 0xfc, 0x3f, 0x00, 0xf8, 0x1f, 0x00, 0xf0, 0x0f, 0x00,
   0xe0, 0x07, 0x00, 0xc0, 0x03, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 22
#define unchecked_height 22
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    } else {
		set checkedData "
#define checked_width 18
#define checked_height 18
static unsigned char checked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x80, 0x03, 0x00, 0xc0, 0x03,
   0x00, 0xe0, 0x03, 0x00, 0xf0, 0x03, 0x00, 0xf8, 0x01, 0x03, 0xfc, 0x00,
   0x07, 0x7e, 0x00, 0x0f, 0x3f, 0x00, 0x9f, 0x1f, 0x00, 0xff, 0x0f, 0x00,
   0xfe, 0x07, 0x00, 0xfc, 0x03, 0x00, 0xf8, 0x01, 0x00, 0xf0, 0x00, 0x00,
   0x60, 0x00, 0x00, 0x00, 0x00, 0x00};
"
		set uncheckedData "
#define unchecked_width 20
#define unchecked_height 20
static unsigned char unchecked_bits[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
"
	    }
	}
    }

    tablelist_checkedImg   configure -data $checkedData
    tablelist_uncheckedImg configure -data $uncheckedData
}

#------------------------------------------------------------------------------
# tablelist::adwaitaTreeImgs
#------------------------------------------------------------------------------
proc tablelist::adwaitaTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel
		  collapsedAct expandedAct collapsedSelAct expandedSelAct} {
	variable adwaita_${mode}Img \
		 [image create photo tablelist_adwaita_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_adwaita_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAPUlEQVQoz2NgGGgQT67GTcRqZsIi
FkyMZiYc4gQ1M+GRw6uZiYCLfpGjcTkUk6QRryZc0RFJTjxGMgxaAADyZAiN7tZZlQAAAABJRU5E
rkJggg==
"
	tablelist_adwaita_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAARUlEQVQoz+3LsQ2AIABE0UdciF0Y
wPFcyIRdqGjEGANorz+57h5/wwIS1offduxsQUZBfIsaNMFddIU9PER32DDsM/SVKvNODk3dEE6A
AAAAAElFTkSuQmCC
"
	tablelist_adwaita_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAASUlEQVQoz2NgGFDw////DGLVMqHx
vYjVzIRFjCjNTDjECWpmwiOHVzMTARd9JEfjckZGxuWkasSrCVs8bvr//38kOQkgkmHQAgDrkiAe
os9KvQAAAABJRU5ErkJggg==
"
	tablelist_adwaita_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAARUlEQVQoz+3PMQrAIBAF0dkzWlnl
ePZecGxCIJgotuLA7/YVC6ffQk3ANbkrEVFeEGCCO/TAAf5EXWpS67289LSal9GmNWXQI7TzaAnf
AAAAAElFTkSuQmCC
"
	tablelist_adwaita_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAM0lEQVQoz2NgGGgQT67G/+Rq/k+u
5v/kav5PrGYmAgYpkGNjPTlOrScncOrJiY4GhkELANUCE+t6oO0cAAAAAElFTkSuQmCC
"
	tablelist_adwaita_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAANElEQVQoz2NgGAV4QTkDA8N/Arie
HM315NhcT46z8WpiRuMfZWBgYGRgYDjIwMDQONIjHwD6aBnQtK1ZdwAAAABJRU5ErkJggg==
"
	tablelist_adwaita_collapsedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAOklEQVQoz2NgGFDw////DnI1/idL
838E6CBXI2ma/2MCnJqZCJj1gxwbG8hxagM5gdNATnQ0MAxaAAC4z2BIDOZwwgAAAABJRU5ErkJg
gg==
"
	tablelist_adwaita_expandedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAAKElEQVQoz2NgGAW4wf///8v/EwYN
5GhuIMfmBnKc3UCqnxtI1jRMAQD9zHJvoaewSgAAAABJRU5ErkJggg==
"
    } else {
	tablelist_adwaita_collapsedImg put "
R0lGODlhDgAOAMIEAAAAAE1NTaCgoKampv///////////////yH5BAEKAAAALAAAAAAOAA4AAAMb
CLrc/kvAFuRUoV6Q9ezeAw5fRpbnl07r5m4JADs=
"
	tablelist_adwaita_expandedImg put "
R0lGODlhDgAOAMIEAAAAAE1NTaampqysrP///////////////yH5BAEKAAAALAAAAAAOAA4AAAMa
CLrc/jDKyUa4+Ipmc9hOp0UdGAkmpa7skwAAOw==
"
	tablelist_adwaita_collapsedSelImg put "
R0lGODlhDgAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAA4AAAIXhI+pe8EZ3DNRvmoX
zhDfOoEhp03mmRQAOw==
"
	tablelist_adwaita_expandedSelImg put "
R0lGODlhDgAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAA4AAAIUhI+py+2Pgpw00apu
aJhvCIZiUwAAOw==
"
	tablelist_adwaita_collapsedActImg put "
R0lGODlhDgAOAMIEAAAAAH9/f4CAgKCgoP///////////////yH5BAEKAAQALAAAAAAOAA4AAAMc
SLrc/mvABuRUoF6S9ezeAwpfRpbnl07B5r5KAgA7
"
	tablelist_adwaita_expandedActImg put "
R0lGODlhDgAOAMIEAAAAAH9/f4CAgIiIiP///////////////yH5BAEKAAQALAAAAAAOAA4AAAMa
SLrc/jDKyQa4+IpmM9hOp0UdGAUBpa6slAAAOw==
"
	tablelist_adwaita_collapsedSelActImg put "
R0lGODlhDgAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAA4AAAIXhI+pe8EZ3DNRvmoX
zhDfOoEhp03mmRQAOw==
"
	tablelist_adwaita_expandedSelActImg put "
R0lGODlhDgAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAA4AAAIUhI+py+2Pgpw00apu
aJhvCIZiUwAAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::ambianceTreeImgs
#------------------------------------------------------------------------------
proc tablelist::ambianceTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable ambiance_${mode}Img \
		 [image create photo tablelist_ambiance_${mode}Img]
    }

    tablelist_ambiance_collapsedImg put "
R0lGODlhEgAQAKUxAAAAADw7N9/Wxd/Wxt/WyODYyeLZyuHazeTdz+Pd0eTd0uXf0+Xf1efg1OXg
1ujh0+jg1Onj1+nj2Ork2O3m3Ozm3e7p4e/q4e7s5u/s6PHs5PHs5fHs5vHu6fPw6vTw6vTw6/bz
7vbz7/b07vb07/b08Pb08fj28/n49Pr59fr59vv5+Pv6+Pr6+vz6+fz7+v39/f//////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAahwJ9w
SCwWD4KkUnkwFjotmHQKa2UKxENmxXK5XmAva4VpCgWmEwqVSqna61NJMBSERKSSyRTYl0gjJHRn
Hx4dHiAgAYkeHh8fgz8CHJQcGhsBGxuVHJECFxcWAaOkAaAXnhUVFKoVAa2tnhMRErUSAbYRExOe
DxC/vwHAEA0PngoIycrLCAuRBwwG0tPUBg5mQgUJBAPd3gMECVhHS+XYQkEAOw==
"
    tablelist_ambiance_expandedImg put "
R0lGODlhEgAQAKUyAAAAADw7N9/Wxd/Wxt/WyODYyeLZyuHazeTdz+Pd0eTd0uXf0+Xf1efg1OXg
1ujh0+jg1Onj1+nj2Ork2O3m3Ozm3e7p4e/q4e7s5u/s6PHs5PHs5fHs5vHu6fPw6vTw6vTw6/bz
7vbz7/b07vb07/b08Pb08fj18fj28/n49Pr59fr59vv5+Pv6+Pr6+vz6+fz7+v39/f//////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAabwJ9w
SCwWD4KkUnkwFjqumHQac2UKxEOG1Xq9YGBvi4VpCgUmVCqlUq3aa1RJMBSERKSSyXTal0gjJHRn
Hx4dHiCJiR4eHx+DPwIckxwaGxwbl5SQAhcXFgGhogGeF5wVFRSoq6wVnBMRErKzshETE5wPELu8
vQ0PnAoIw8TFCAuQBwwGzM3OBg5mQgUJBAPX2AMECVhHS9/SQkEAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::aquaTreeImgs
#------------------------------------------------------------------------------
proc tablelist::aquaTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable aqua_${mode}Img \
		 [image create photo tablelist_aqua_${mode}Img]
    }

    variable pngSupported
    variable winSys
    scan $::tcl_platform(osVersion) "%d" majorOSVersion
    if {[string compare $winSys "aqua"] == 0 && $majorOSVersion > 10} {
	set osVerPost10 1
    } else {
	set osVerPost10 0
    }

    if {$pngSupported} {
	if {$osVerPost10} {
	    tablelist_aqua_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAhUlEQVQoz2NgGFaAmYGBgaG4uPih
lZXVvePHj98kxxBGqCH/ofxtDAwMub29vfdIMYQJje/FwMBwvbi4uIoSlyCDawwMDFm9vb0HSXUJ
MtBiYGA4UFxcHECJIdcYGBgcent7NxAyhAWL2C8GBobG3t7eNmLDBN0QsmIHZsgjqOZNQzvZAwA+
LCb4qKbYgQAAAABJRU5ErkJggg==
"
	    tablelist_aqua_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAiUlEQVQoz+2SsQkCQRREn3t9aO51
sKmZJtYhXDS5HUwzwtnCVqC5NmB+gZgui9wulwlO8vnMZ2b4/8MfJVaSHsB6ZuZpezMnEoChYjRU
kwBIGoH9F/5q+1ATCZnbVHBTSwqADiCl9IoxvoFdxp1tX5oWmzeSbsAWuNvuW68Tiv5U1GWQdPzd
j/0AfOEdPAaC2LoAAAAASUVORK5CYII=
"
	} else {
	    tablelist_aqua_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAe0lEQVQoz2NgGH6gra3tYVtbmx+5
+hmhhvyH8rcxMDDkVlVV3SPFECY0vhcDA8P1tra2KkpcggyuMTAwZFVVVR0k1SXIQIuBgeFAW1tb
ACWGXGNgYHCoqqraQMgQFixivxgYGBqrqqraiA0TdEPIih2YIY+gmjcN7RQPAIgqI+JZClM5AAAA
AElFTkSuQmCC
"
	    tablelist_aqua_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAfklEQVQoz+2SsQ2DUAxEX/4gpCeb
hCZzRGKB62huI7IJlJGSMajSJAhZiP9Fh5RrLPusO1s2/BFxsv0Cqo2et6TzlkgC2oxRm50EwHYP
XFf4h6QmJ5IWblPgppIpZhFJT6ALXPetU7TOD7YHoAZGSZfS66SQ30PcB9u3437sB9yMGwQuEm+e
AAAAAElFTkSuQmCC
"
	}

	tablelist_aqua_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAR0lEQVQoz2NgGH7g////N////+9I
qSEwsOT///8SlBry/////5/+//+fRakhMHD6////ppQaAgPOA+YSisOEotihPJ0MCgAABqWnCWRA
sV8AAAAASUVORK5CYII=
"
	tablelist_aqua_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAYAAADJ7fe0AAAAT0lEQVQoz2NgGAUY4P///zf/4wc3
iTHEkYAhjsS6ZgkOA5aQ4iWJ////f0Iz4NP///8lSA2bLDRDssgN5NNQA05TElOmUENMKY1y56Gb
YAGl/KcJzjuWxQAAAABJRU5ErkJggg==
"
    } else {
	if {$osVerPost10} {
	    tablelist_aqua_collapsedImg put "
R0lGODlhEQAOAMIGAAAAAHNzc3Z2doODg4qKipubm////////yH5BAEKAAcALAAAAAARAA4AAAMf
eLrc/jC+IV0Ipa4bhD7cRVQhJ5XjeXnalX3UJ89OAgA7
"
	    tablelist_aqua_expandedImg put "
R0lGODlhEQAOAMIGAAAAAHNzc3Z2doODg4qKipubm////////yH5BAEKAAcALAAAAAARAA4AAAMf
eLrc/jDKqUa4OIyYsSxdMQmYQB3eSQTEqQRuLM9HAgA7
"
	} else {
	    tablelist_aqua_collapsedImg put "
R0lGODlhEQAOAMIGAAAAAIaGhoiIiJSUlJmZmampqf///////yH5BAEKAAcALAAAAAARAA4AAAMf
eLrc/jC+IV0Ipa4bhD7cRVQhJ5XjeXnalX3UJ89OAgA7
"
	    tablelist_aqua_expandedImg put "
R0lGODlhEQAOAMIGAAAAAIaGhoiIiJSUlJmZmampqf///////yH5BAEKAAcALAAAAAARAA4AAAMf
eLrc/jDKqUa4OIyYsSxdMQmYQB3eSQTEqQRuLM9HAgA7
"
	}

	tablelist_aqua_collapsedSelImg put "
R0lGODlhEQAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAARAA4AAAIZhI+py73hVJjxTFrv
jXq3DjlaBXgZiaZLAQA7
"
	tablelist_aqua_expandedSelImg put "
R0lGODlhEQAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAARAA4AAAIXhI+py+1vgpyz0Wpv
eBcCDIGhR5ZmUgAAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::arcTreeImgs
#------------------------------------------------------------------------------
proc tablelist::arcTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel
		  collapsedAct expandedAct collapsedSelAct expandedSelAct} {
	variable arc_${mode}Img \
		 [image create photo tablelist_arc_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_arc_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAdUlEQVQoz43PMQrCQBAF0LcJBlJJ
GgsxjaVYewQPH+y8goLYeIKAzYILZsl8GBgGHjPDL3ucBdMUfY8jLhHYFv0HHUYMeEQhvDM+rOF2
YVbiLZ5rP5a5Y8YuVxhekXDLF/wlVVCX0av2Y6qgqbZp6dQTNhEEX90gEJ+LSk5oAAAAAElFTkSu
QmCC
"
	tablelist_arc_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAdklEQVQoz8XRPQrCYBCE4ccf0oqF
phPxEBbBOuDZ1SOk10ZME2IjNqvIRyQiiFMu8y67M/xDM2x6PEX4nhriignKN1CJKdrX4SjACxZY
oUqgDAecUxAa1AEvA35AO5zSMwYd/65j4Q17HD8Na44t8m+SHv+swzvwkBDQCQf9GAAAAABJRU5E
rkJggg==
"
	tablelist_arc_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAWklEQVQoz8XNsQ1AUBRG4fPMYAMD
SERjDCO8SIxhEIUNNLZTHY1CIeE2nOrPTb5cOFM7NfOy4rJLoFcnoqmDuv2Cxydc3B1TSjOwA7Va
RT4u6qq2n6EmgnIEHTdXWJbfx3TnAAAAAElFTkSuQmCC
"
	tablelist_arc_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAYklEQVQoz73RsQmAQAxG4YeNowg2
h+CGgmMc2NiIjYuJEzwr4RCPs9GUIR9/QuD3UoM6FmYGNaS9CjiARp0yKAItsOdSlztWo7qqfWnl
9cIJ6t7eu6hbMSmD51dJD7j+7I0n6qZe9ie8GDoAAAAASUVORK5CYII=
"
	tablelist_arc_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAc0lEQVQoz5XQMQrCQBAF0IcpPUTE
Ugi2Se8VBC+Rm2xt9AS5SrC2Fs9hZbPgFkJmf/UZeDAz/DLgIphN0bc4YYzApuivjAfssUQhPDPu
13DzZ1biFo+1G8vM+OCAXQ1MeZsb3tFPJ9xxVJGECV0NOuMaRV+KwQ8YfvQOIwAAAABJRU5ErkJg
gg==
"
	tablelist_arc_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAfklEQVQoz8XRsQnCYBiE4UdFEII7
WFgZnMAurmNn4RLaBDSzxC2SOoV9GsVasAkSfpBIIHjdd9wLx338QyscOjL7JvfRGA8scPoCHbHE
vW1O8MQNG2yRB9AcGaoQhLoFJ7g2UIQzyrDGKLhj7DDFCxcUv44VI8W6z9KzwX74Bj4AEo6rawBK
AAAAAElFTkSuQmCC
"
	tablelist_arc_collapsedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAASElEQVQoz2NggIL///8H/f//v5eB
VPD////8/xCwgRzNE6Cat9Jd8yRKnP31////P/7//29OiqYnUE2+dNPkQYqmbqi/iNIEAFLCatI7
yC/KAAAAAElFTkSuQmCC
"
	tablelist_arc_expandedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA4AAAAKCAYAAACE2W/HAAAAWElEQVQoz2NgoDv4//+/6////w8S
ULPn////zuiCuv/////x////Zzg0PYHKa+Gy9Su6Zqim3/////cl5GS4zUg2eRDr36//IQC/TTg0
vyPKJiyaeWgWjQCS2nBV7y8ibwAAAABJRU5ErkJggg==
"
    } else {
	tablelist_arc_collapsedImg put "
R0lGODlhDgAKAOMKAAAAALGxsbOzs7S0tLm5ucfHx8nJydPT09XV1eXl5f//////////////////
/////yH5BAEKAA8ALAAAAAAOAAoAAAQc8L10pL03GMxlKB33hZhGWoNwPoR6tit8IsMZAQA7
"
	tablelist_arc_expandedImg put "
R0lGODlhDgAKAOMJAAAAALGxsbOzs7S0tLa2tri4uLm5ucPDw8XFxf//////////////////////
/////yH5BAEKAA8ALAAAAAAOAAoAAAQd8MlJq73vXFSHqcZgDcVkCJjwnZg0BGgrEXJtTxEAOw==
"
	tablelist_arc_collapsedSelImg put "
R0lGODlhDgAKAKECAAAAAMzMzP///////yH5BAEKAAAALAAAAAAOAAoAAAIUBBKmu8hvHGRyqmox
1I/TZB3gVAAAOw==
"
	tablelist_arc_expandedSelImg put "
R0lGODlhDgAKAKECAAAAAMzMzP///////yH5BAEKAAAALAAAAAAOAAoAAAIUhI+pC7GOAjxSVXOt
y4+zyYSiUgAAOw==
"
	tablelist_arc_collapsedActImg put "
R0lGODlhDgAKAOMLAAAAAGNjY2ZmZmhoaGlpaXNzc4+Pj5KSkqenp6qqqsbGxv//////////////
/////yH5BAEKAA8ALAAAAAAOAAoAAAQc8D2FpL03HMxlMB33hZhGWsRwPoWwtq96JsQZAQA7
"
	tablelist_arc_expandedActImg put "
R0lGODlhDgAKAOMKAAAAAGNjY2ZmZmhoaG1tbXFxcXJycnNzc4iIiIyMjP//////////////////
/////yH5BAEKAA8ALAAAAAAOAAoAAAQd8MlJq70P3VSHqcdgDcV0CJj3hJg0BGgrEXJtTxEAOw==
"
	tablelist_arc_collapsedSelActImg put "
R0lGODlhDgAKAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAAoAAAIUBBKmu8hvHGRyqmox
1I/TZB3gVAAAOw==
"
	tablelist_arc_expandedSelActImg put "
R0lGODlhDgAKAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAOAAoAAAIUhI+pC7GOAjxSVXOt
y4+zyYSiUgAAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::baghiraTreeImgs
#------------------------------------------------------------------------------
proc tablelist::baghiraTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable baghira_${mode}Img \
		 [image create photo tablelist_baghira_${mode}Img]
    }

    tablelist_baghira_collapsedImg put "
R0lGODlhDQAIAIABAAAAAP///yH5BAEKAAEALAAAAAANAAgAAAIQjI8JyQHbzoNxUjajeXr3AgA7
"
    tablelist_baghira_expandedImg put "
R0lGODlhDQAIAIABAAAAAP///yH5BAEKAAEALAAAAAANAAgAAAIOjI+pywcPwYqSwWYqxgUAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::bicolor100TreeImgs
#------------------------------------------------------------------------------
proc tablelist::bicolor100TreeImgs {} {
    plain100TreeImgs "bicolor100"

    foreach mode {collapsedSel expandedSel} {
	variable bicolor100_${mode}Img \
		 [image create photo tablelist_bicolor100_${mode}Img]
    }

    tablelist_bicolor100_collapsedSelImg put "
R0lGODlhDAAKAIAAAP///////yH5BAEKAAEALAAAAAAMAAoAAAIUjI8IybB83INypmqjhGFzxxkZ
UgAAOw==
"
    tablelist_bicolor100_expandedSelImg put "
R0lGODlhDAAKAIAAAP///////yH5BAEKAAEALAAAAAAMAAoAAAIQjI+py+D/EIxpNscMyLyHAgA7
"
}

#------------------------------------------------------------------------------
# tablelist::bicolor125TreeImgs
#------------------------------------------------------------------------------
proc tablelist::bicolor125TreeImgs {} {
    plain125TreeImgs "bicolor125"

    foreach mode {collapsedSel expandedSel} {
	variable bicolor125_${mode}Img \
		 [image create photo tablelist_bicolor125_${mode}Img]
    }

    tablelist_bicolor125_collapsedSelImg put "
R0lGODlhDwAMAIAAAP///////yH5BAEKAAEALAAAAAAPAAwAAAIXjI95oB3AHIJRPmovlnS3Xn2e
M5IhlxUAOw==
"
    tablelist_bicolor125_expandedSelImg put "
R0lGODlhDwAMAIAAAP///////yH5BAEKAAEALAAAAAAPAAwAAAIVjI+pyw0PI0gyrjqZbAbyk33i
SBoFADs=
"
}

#------------------------------------------------------------------------------
# tablelist::bicolor150TreeImgs
#------------------------------------------------------------------------------
proc tablelist::bicolor150TreeImgs {} {
    plain150TreeImgs "bicolor150"

    foreach mode {collapsedSel expandedSel} {
	variable bicolor150_${mode}Img \
		 [image create photo tablelist_bicolor150_${mode}Img]
    }

    tablelist_bicolor150_collapsedSelImg put "
R0lGODlhEgAOAIAAAP///////yH5BAEKAAEALAAAAAASAA4AAAIejI+poI3AXINRPmovzoFu631O
WEkh14kghBps27UFADs=
"
    tablelist_bicolor150_expandedSelImg put "
R0lGODlhEgAOAIAAAP///////yH5BAEKAAEALAAAAAASAA4AAAIYjI+py+2vgJx0xloZtm3DDAVc
KJLmiR4FADs=
"
}

#------------------------------------------------------------------------------
# tablelist::bicolor175TreeImgs
#------------------------------------------------------------------------------
proc tablelist::bicolor175TreeImgs {} {
    plain175TreeImgs "bicolor175"

    foreach mode {collapsedSel expandedSel} {
	variable bicolor175_${mode}Img \
		 [image create photo tablelist_bicolor175_${mode}Img]
    }

    tablelist_bicolor175_collapsedSelImg put "
R0lGODlhFQAQAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAVABAAAAIjhI+pGOsZ2ntRTlXt
PVnv7k1g6IwkBm5GqgJdu1ZwfIq1OBcAOw==
"
    tablelist_bicolor175_expandedSelImg put "
R0lGODlhFQAQAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAVABAAAAIehI+py+0PVZi02mXz
bLq+HkRaZFxkuZ1HqLbuCysFADs=
"
}

#------------------------------------------------------------------------------
# tablelist::bicolor200TreeImgs
#------------------------------------------------------------------------------
proc tablelist::bicolor200TreeImgs {} {
    plain200TreeImgs "bicolor200"

    foreach mode {collapsedSel expandedSel} {
	variable bicolor200_${mode}Img \
		 [image create photo tablelist_bicolor200_${mode}Img]
    }

    tablelist_bicolor200_collapsedSelImg put "
R0lGODlhGAASAIAAAP///////yH5BAEKAAEALAAAAAAYABIAAAIpjI+pC+sO2psmSgotznon23kV
GIkjeW1oiK1pi5pBLJPy+YpsnZs9VgAAOw==
"
    tablelist_bicolor200_expandedSelImg put "
R0lGODlhGAASAIAAAP///////yH5BAEKAAEALAAAAAAYABIAAAIijI+py+0Po5yg2osry1y3jkGg
J3ZTwJ1GqK5ki8LyTNdKAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::blueMentaTreeImgs
#------------------------------------------------------------------------------
proc tablelist::blueMentaTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel
		  collapsedAct expandedAct collapsedSelAct expandedSelAct} {
	variable blueMenta_${mode}Img \
		 [image create photo tablelist_blueMenta_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_blueMenta_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAPklEQVQY02NgIAOI45NkQmL7MDAw
ZBKjkAGqMJMYhTgVM+GwKZOBgcGMGIXTGRgYThFSOB2KcYJkfL4mOhwBfAkGjtSLavwAAAAASUVO
RK5CYII=
"
	tablelist_blueMenta_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAATklEQVQY08XQQQ2AMABD0UdAx1SA
EFzADE0GRjghYS52gstOBAgn6LH9SZvymxoEjA/MgtwhoyBeQKnm2mqs2DGcoHRXM2HD/GZ3/809
B7GOCszzE05qAAAAAElFTkSuQmCC
"
	tablelist_blueMenta_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAQUlEQVQY02NgIBX8//9fBp88ExI7
5v///w3EmFjxHwIaCJkIA/XYFDPhsKD+////jsQobGRkZNxPlhvRFTZQHI4AbXUv3nezwkkAAAAA
SUVORK5CYII=
"
	tablelist_blueMenta_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAP0lEQVQY02NgGDDA+P//f2UGBoYU
PGrmMDIy3mVgYGBg+P//f+1/7KABQxsWxQ047UBS3EDQ0f///7enT/AAAJt8QP+zI+bcAAAAAElF
TkSuQmCC
"
	tablelist_blueMenta_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAPklEQVQY02NgIAOI45NkQmL7MDAw
ZBKjkAGqMJMYhTgVM+GwKZOBgcGMGIXTGRgYThFSOB2KcYJkfL4mOhwBfAkGjtSLavwAAAAASUVO
RK5CYII=
"
	tablelist_blueMenta_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAATklEQVQY08XQQQ2AMABD0UdAx1SA
EFzADE0GRjghYS52gstOBAgn6LH9SZvymxoEjA/MgtwhoyBeQKnm2mqs2DGcoHRXM2HD/GZ3/809
B7GOCszzE05qAAAAAElFTkSuQmCC
"
	tablelist_blueMenta_collapsedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAPklEQVQY02NgIAOI45NkQmL7MDAw
ZBKjkAGqMJMYhTgVM+GwKZOBgcGMGIXTGRgYThFSOB2KcYJkfL4mOhwBfAkGjtSLavwAAAAASUVO
RK5CYII=
"
	tablelist_blueMenta_expandedSelActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAATklEQVQY08XQQQ2AMABD0UdAx1SA
EFzADE0GRjghYS52gstOBAgn6LH9SZvymxoEjA/MgtwhoyBeQKnm2mqs2DGcoHRXM2HD/GZ3/809
B7GOCszzE05qAAAAAElFTkSuQmCC
"
    } else {
	tablelist_blueMenta_collapsedImg put "
R0lGODlhCgAKAMIFAAAAAC0tLZaWlpycnMnJyf///////////yH5BAEKAAcALAAAAAAKAAoAAAMU
eLrcfkM8GKQbod4cSMPaF37W5CQAOw==
"
	tablelist_blueMenta_expandedImg put "
R0lGODlhCgAKAKEDAAAAAC0tLZCQkP///yH5BAEKAAMALAAAAAAKAAoAAAIPnI+pe+IvUJhTURaY
3qwAADs=
"
	tablelist_blueMenta_collapsedSelImg put "
R0lGODlhCgAKAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAKAAoAAAIQhI+pELHcVotp0mPV
lO6tAgA7
"
	tablelist_blueMenta_expandedSelImg put "
R0lGODlhCgAKAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAKAAoAAAIOhI+pe+EfEIzpMcqy
VgUAOw==
"
	tablelist_blueMenta_collapsedActImg put "
R0lGODlhCgAKAMIFAAAAAC0tLZaWlpycnMnJyf///////////yH5BAEKAAcALAAAAAAKAAoAAAMU
eLrcfkM8GKQbod4cSMPaF37W5CQAOw==
"
	tablelist_blueMenta_expandedActImg put "
R0lGODlhCgAKAKEDAAAAAC0tLZCQkP///yH5BAEKAAMALAAAAAAKAAoAAAIPnI+pe+IvUJhTURaY
3qwAADs=
"
	tablelist_blueMenta_collapsedSelActImg put "
R0lGODlhCgAKAMIFAAAAAC0tLZaWlpycnMnJyf///////////yH5BAEKAAcALAAAAAAKAAoAAAMU
eLrcfkM8GKQbod4cSMPaF37W5CQAOw==
"
	tablelist_blueMenta_expandedSelActImg put "
R0lGODlhCgAKAKEDAAAAAC0tLZCQkP///yH5BAEKAAMALAAAAAAKAAoAAAIPnI+pe+IvUJhTURaY
3qwAADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::classic100TreeImgs
#------------------------------------------------------------------------------
proc tablelist::classic100TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable classic100_${mode}Img \
		 [image create photo tablelist_classic100_${mode}Img]
    }

    tablelist_classic100_collapsedImg put "
R0lGODlhDAAKAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAMAAoAAAIgnI8Xy4EhohTOwAhk
HVfkuEHAOFKK9JkWqp0T+DQLUgAAOw==
"
    tablelist_classic100_expandedImg put "
R0lGODlhDAAKAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAMAAoAAAIcnI8Xy4EhohTOwBnr
uFhDAIKUgmVk6ZWj0ixIAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::classic125TreeImgs
#------------------------------------------------------------------------------
proc tablelist::classic125TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable classic125_${mode}Img \
		 [image create photo tablelist_classic125_${mode}Img]
    }

    tablelist_classic125_collapsedImg put "
R0lGODlhDwAMAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAPAAwAAAImnI85wd0ZhJwzoDgB
tQdLXV0UKHFGBKSqZi7jJmZw94Y0NXeOkxQAOw==
"
    tablelist_classic125_expandedImg put "
R0lGODlhDwAMAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAPAAwAAAIlnI85wd0ZhJwzoEip
PTjLbXQeuAjAiQICKWasV13wJ8/k4jhJAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::classic150TreeImgs
#------------------------------------------------------------------------------
proc tablelist::classic150TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable classic150_${mode}Img \
		 [image create photo tablelist_classic150_${mode}Img]
    }

    tablelist_classic150_collapsedImg put "
R0lGODlhEgAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAASAA4AAAIxnI+Jwe2hgpi0Cris
xkdWYHGGR4GVOJCTSaEeAMema7ET/YWJKtjXrtFlgq3I46EoAAA7
"
    tablelist_classic150_expandedImg put "
R0lGODlhEgAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAASAA4AAAIrnI+Jwe2hgpi0Cris
xkfqyhneN4XDSJoewLZAmaCfSlJ0fcV4nuHm+XgoCgA7
"
}

#------------------------------------------------------------------------------
# tablelist::classic175TreeImgs
#------------------------------------------------------------------------------
proc tablelist::classic175TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable classic175_${mode}Img \
		 [image create photo tablelist_classic175_${mode}Img]
    }

    tablelist_classic175_collapsedImg put "
R0lGODlhFQAQAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAVABAAAAI9nI+pE+3vVhC02hrU
vFzktFkA9yFhNV7lcVKptRqt8GKaC+R6TsUMV+vdLkHPUEQ6opKgDtPkVEkgVN+gAAA7
"
    tablelist_classic175_expandedImg put "
R0lGODlhFQAQAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAVABAAAAI1nI+pE+3vVhC02hrU
vFzktHXWh4QiRR7mmRqr2DIUQNc1qp1jruNg7ysBPbxe7NWJMSBMZQEAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::classic200TreeImgs
#------------------------------------------------------------------------------
proc tablelist::classic200TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable classic200_${mode}Img \
		 [image create photo tablelist_classic200_${mode}Img]
    }

    tablelist_classic200_collapsedImg put "
R0lGODlhGAASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAYABIAAAJKXI6pMe0mopxUsAer
jvcFDQBa53xVOGIZhVZkY7Kiq8ZTS71ZyPc8V4v4hjOdTYKbGEGzXPDUVD5lKcxRGJUsN1UPt+tZ
iA+qQQEAOw==
"
    tablelist_classic200_expandedImg put "
R0lGODlhGAASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAYABIAAAJAXI6pMe0mopxUsAer
jveFvXXOB1ZiQ5bTmakSm7oWlgH2jdscTeY+sMPEXDDZi2cMepIzIbOYhBpZhoX1QBsUAAA7
"
}

#------------------------------------------------------------------------------
# tablelist::dustTreeImgs
#------------------------------------------------------------------------------
proc tablelist::dustTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable dust_${mode}Img \
		 [image create photo tablelist_dust_${mode}Img]
    }

    tablelist_dust_collapsedImg put "
R0lGODlhEgAQAKU0AAAAADIyMrConLGpncC6scC7ssG8s8K8tMK9tdDMxtDMx9LOyNrVztvVz9vW
ztvWz9vX0NzW0N3Y0d/a0uDd1uHe1+Lf2OPg2uTh2+Xj3efk3+jl4Ojm4enm4unn4+nn5Orn5evo
5Ovo5evq5ezp5e3q5u3q5+7s6O/t6e7t6vDu6/Hv7PHv7fLw7PLw7vT08vf39fj39fn49vn49///
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAakwJ9w
SCwSCQOBcrkcEIiGxQsWk82ushjspTgMB6zSCaVatVYq1GnkGgwFrE6IVDLZS6RQhyV4pzAZGhsc
ARwbGhkYKX1CAiYUFRYXFwGTFhUUJow/AiISnxITAROgEiKbAh0MEQGtrgEPDx2oHbEPDg8BDbay
qB68ucAevsCwvMNvIRHLzM0RIZsDHhDOzRAebkIHCiAi3t/fHwkIR0lMTAMFREEAOw==
"
    tablelist_dust_expandedImg put "
R0lGODlhEgAQAKU0AAAAADIyMrConLGpncS+tcS/tsbBuMfBucfCucfCutfTzdjUztnUz9vWztvW
z9vX0NzW0N3Y0d/a0t/a0+Dd1uHe1+Lf2OPg2uTh2+Xj3efk3+jl4Ojm4enm4unn4+vo5Ovo5evp
5uvq5ezp5e3q5u3q5+7s6O/t6e7t6vDu6/Hv7PLv7fLw7PHw7fLx7vX08vf39fj39fn49vn49///
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAagwJ9w
SCwSCQOBcrkcEIiGxQsWk82ushjspUAMBy2S6ZRSsVSpk0nkGgwFq85nRCrZSaNPZyV4ozAZGhsc
hBsaGRgofUICJRQVFhcXGJIWFRQliz8CIBGeERITEp8RIJoCHQsQAaytAQ4OHacdsA4NsAy1sace
ur6wHry/vsFvHxDIycoQH5oDHw/Lyg8fbkIHDCEg29zdCwlHSUxMAwVEQQA7
"
}

#------------------------------------------------------------------------------
# tablelist::dustSandTreeImgs
#------------------------------------------------------------------------------
proc tablelist::dustSandTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable dustSand_${mode}Img \
		 [image create photo tablelist_dustSand_${mode}Img]
    }

    tablelist_dustSand_collapsedImg put "
R0lGODlhEgAQAKU1AAAAADIyMpuWjJyXjrSxqbWxqre0rbi1rrm2r8K+tsO+t8TAuMXBusbCu8nF
vcnGvsrHv8vHwMnGwcrIwczIwMzIwc3Jw87LxMzKxc/MxdDMxdDMx9HOx9HOyNLPydPPytPQydPQ
y9TRy9TRzNXTzNXSzdfTztbUzNbUzdfVz9nV0NjW0NnW0drY097c2eDe2eXi3uXj3+jm4+nn5Oro
5f///////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAajwJ9w
SCwSCQOBcrkcEIiGCUwmm81oVmpMchgOXqWSSbVirVSm0ug1GApcm85HNKqLPp2NS+BuVSwXGRoB
GhkXFhUtfEICKQ4PEBEUARQREA8OKYs/AiEMnwwNAQ2gDCGbAhwJCgGtrgEKChyoHLGxCQGrtrNu
tbasv7KoHcGwvx2oHgvLzM0LHpsDJc7UJG1CBxgoINzd3ScYCEQFSUxMAwVEQQA7
"
    tablelist_dustSand_expandedImg put "
R0lGODlhEgAQAKU3AAAAADIyMpuWjJyXjrSxqbWxqre0rbi1rrm2r8K+tsO+t8TAuMXBusbCu8bC
vMnFvcnGvsrHv8vHwMnGwcrIwczIwMzIwc3Jw87LxMzKxc/Mxc/MxtDMxdDMx9HOx9HOyNLPydPP
ytPQydPQy9TRy9TRzNXTzNXSzdfTztbUzNbUzdfVz9nV0NjW0NnW0drY097c2eDe2eXi3uXj3+jm
4+nn5Oro5f///////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAagwJ9w
SCwSCQOBcrkcEIgGioxGq9VsVupschgOYqcTitVytVioUyk2GApgnU+IVKqTQp8OTOB+WS4YGhwb
HBoYFxYvfEICKw8QERIVFhUSERAPK4s/AiMMnwwNDg2gDCObAh4JCgGtrgEKCh6oHrGxCbi2srS6
vbGzbh++vR+oIAvIycoLIJsDJ8vRJm1CBxkqItna2ikZCEQFSUxMAwVEQQA7
"
}

#------------------------------------------------------------------------------
# tablelist::gtkTreeImgs
#------------------------------------------------------------------------------
proc tablelist::gtkTreeImgs {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable gtk_${mode}Img \
		 [image create photo tablelist_gtk_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_gtk_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAUUlEQVQoz8XTwQ2AQAhE0T17+jVQ
h/XRGIV9L5p4FsxSwAuZgbV+nHNEARzBACOijwFWVR8DVPvYA7WxN6Samd4FHHs3GslorLWxO5p6
k0/IBbP6VlQP0oOsAAAAAElFTkSuQmCC
"
	tablelist_gtk_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAW0lEQVQoz+3SwQmAQAxE0fHqKTVM
HWt7aWwsKB3Ek4IQYXVBEPzXkJdLgL/XmgA0M1PvQkQsANareSOZkrJKUpJMAK3nWIndRUrsKXLC
3H0IOTAzG0b25m8/5Aai703YBhwgYAAAAABJRU5ErkJggg==
"
	tablelist_gtk_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAa0lEQVQoz7XSMQqAMAyF4d9OAZeM
OYyeXg/TMZN0qwdQKyltxjz4CI/AxNmGKKpah2CqWs0sjKW3ZSkFMzsiWPoKolhqhRFs+Sj7Me6+
AlfXRQAigrvvLeQXEhFyzjtwdncUQYb+0bzP7kVuCWMmCi7K2XoAAAAASUVORK5CYII=
"
	tablelist_gtk_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAXUlEQVQoz2NgGAV0A4wMDAyZAgIC
04jV8OHDhywGBobp6OLMDAwMZ378+PGKg4PDm1xDYAYxEGMYPkOwgUwBAYH/6JiBgSGTnHCDG6ak
pES2ISiGUWoIDIgM7QQJACRKJBMon0pJAAAAAElFTkSuQmCC
"
    } else {
	tablelist_gtk_collapsedImg put "
R0lGODlhEgAOAMIFAAAAABAQECIiIoaGhsPDw////////////yH5BAEKAAcALAAAAAASAA4AAAMi
eLrc/pCFCIOgLpCLVyhbp3wgh5HFMJ1FKX7hG7/mK95MAgA7
"
	tablelist_gtk_expandedImg put "
R0lGODlhEgAOAMIFAAAAABAQECIiIoaGhsPDw////////////yH5BAEKAAcALAAAAAASAA4AAAMg
eLrc/jDKSWu4OAcoSPkfIUgdKFLlWQnDWCnbK8+0kgAAOw==
"
	tablelist_gtk_collapsedActImg put "
R0lGODlhEgAOAKEDAAAAABAQEBgYGP///yH5BAEKAAMALAAAAAASAA4AAAIdnI+pyxjNgoAqSOrs
xMNq7nlYuFFeaV5ch47raxQAOw==
"
	tablelist_gtk_expandedActImg put "
R0lGODlhEgAOAKEDAAAAABAQECIiIv///yH5BAEKAAMALAAAAAASAA4AAAIYnI+py+0PY5i0Bmar
y/fZOEwCaHTkiZIFADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::klearlooksTreeImgs
#------------------------------------------------------------------------------
proc tablelist::klearlooksTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable klearlooks_${mode}Img \
		 [image create photo tablelist_klearlooks_${mode}Img]
    }

    tablelist_klearlooks_collapsedImg put "
R0lGODlhDQAIAIABAAAAAP///yH5BAEKAAEALAAAAAANAAgAAAIPjI8IkL3c1IoSxkcDzjMXADs=
"
    tablelist_klearlooks_expandedImg put "
R0lGODlhDQAIAIABAAAAAP///yH5BAEKAAEALAAAAAANAAgAAAIRjI+pCXCtmpNLwhUoNm57UwAA
Ow==
"
}

#------------------------------------------------------------------------------
# tablelist::mateTreeImgs
#------------------------------------------------------------------------------
proc tablelist::mateTreeImgs {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable mate_${mode}Img \
		 [image create photo tablelist_mate_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_mate_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAeUlEQVQoz83RLQ7CUBRE4S+vFQQM
Eo/DlB10Y0gEEnwXQMIq2AChFeygSWUNHtOahv4ISDpmMsk9yUwus9Vm6mHU+BVLPMaA0PgKKW5I
pgDwQokjTn01QyfXKLDH5RsUd/IaWzxxRjUE7LDAAXnfhhZ4447s53/4vz4ZeA6wL/7UqwAAAABJ
RU5ErkJggg==
"
	tablelist_mate_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAf0lEQVQoz9XRMQrCYAyG4ccWtdC1
8l/B1at4Cg/iIXqBTr2BOLq4dnEQXJxcnHR3iVBKh64NhDd84UsgYf6xQEKNcqT/xQGvv5CHuMQG
VzwiC5xw6U/IgmesUIW5whrtcGUe/OCOPd7Y4ojn0JD16g437ILdlCMkNMHJkWb26R+bgxLSbl4O
9wAAAABJRU5ErkJggg==
"
	tablelist_mate_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAdElEQVQoz83RsQ2CUBQF0AORhoZO
XcHEbZjDECYxhDlMXMDOERxC6WxsbGgwMQTjp/gJt3mveKe4eSw227ngijbkMB3mGztcUIYAeOCF
Gmfs/wED6FCgmeo2BjnWeKLCfQxWX/sGCY44/erwARluOET7Q7z0AZUOkqtBUcIAAAAASUVORK5C
YII=
"
	tablelist_mate_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAa0lEQVQoz9XRQQqDUAwE0Ke1Z/A2
f+mid/B0nsCFm55I8QBuWnCTDx/BYpcOhGRgYJIJ90eFFsMPTY8lkzrIHHwrCtZSnB0y3vjigwYP
dEe7upjHEFXRx7MbSkx4hsvrSggpVkv/JNfe7NM710YQSDbaCJ8AAAAASUVORK5CYII=
"
    } else {
	tablelist_mate_collapsedImg put "
R0lGODlhDAAOAOMOAAAAAEBAQEdHR0tLS0xMTFRUVFZWVlxcXG9vb3d3d3p6en9/f4aGhpubm///
/////yH5BAEKAA8ALAAAAAAMAA4AAAQe8MlJq70409F0OEUWMAiRXOOiCIY1lqcLZpxm33cEADs=
"
	tablelist_mate_expandedImg put "
R0lGODlhDAAOAIQQAAAAAEVFRUxMTFBQUFFRUVhYWFlZWVpaWl9fX3V1dXp6en19fYSEhImJiZ6e
nqOjo////////////////////////////////////////////////////////////////yH5BAEK
AAAALAAAAAAMAA4AAAUkICCOZGmeaEoOQdsO5YM0NOKYRsIkBUoshJRCoFAdVMikMhUCADs=
"
	tablelist_mate_collapsedActImg put "
R0lGODlhDAAOAOMLAAAAADs7O0BAQEJCQkNDQ0xMTE9PT1FRUVZWVlpaWmxsbP//////////////
/////yH5BAEKAA8ALAAAAAAMAA4AAAQf8MlJq70406C0IEMmJEVgXCNyCGE1lqf1tRen3TgeAQA7
"
	tablelist_mate_expandedActImg put "
R0lGODlhDAAOAOMKAAAAAEVFRUhISElJSUpKSktLS0xMTE5OTlpaWl1dXf//////////////////
/////yH5BAEKAA8ALAAAAAAMAA4AAAQf8MlJq70408B7qElwjAFiBYIhfFdQsBcRDBqs3XhuRQA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::mentaTreeImgs
#------------------------------------------------------------------------------
proc tablelist::mentaTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable menta_${mode}Img \
		 [image create photo tablelist_menta_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_menta_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAAPklEQVQY02NgIAOI45NkQmL7MDAw
ZBKjkAGqMJMYhTgVM+GwKZOBgcGMGIXTGRgYThFSOB2KcYJkfL4mOhwBfAkGjtSLavwAAAAASUVO
RK5CYII=
"
	tablelist_menta_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAATklEQVQY08XQQQ2AMABD0UdAx1SA
EFzADE0GRjghYS52gstOBAgn6LH9SZvymxoEjA/MgtwhoyBeQKnm2mqs2DGcoHRXM2HD/GZ3/809
B7GOCszzE05qAAAAAElFTkSuQmCC
"
    } else {
	tablelist_menta_collapsedImg put "
R0lGODlhCgAKAMIFAAAAAC0tLZaWlpycnMnJyf///////////yH5BAEKAAcALAAAAAAKAAoAAAMU
eLrcfkM8GKQbod4cSMPaF37W5CQAOw==
"
	tablelist_menta_expandedImg put "
R0lGODlhCgAKAKEDAAAAAC0tLZCQkP///yH5BAEKAAMALAAAAAAKAAoAAAIPnI+pe+IvUJhTURaY
3qwAADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::mintTreeImgs
#------------------------------------------------------------------------------
proc tablelist::mintTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable mint_${mode}Img \
		 [image create photo tablelist_mint_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_mint_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAU0lEQVQoz73RQQ2AMAwF0JfdZodg
AhEo44gITBAkYGNXDIxmCwv/2PQ1acvf2XrBjT1qSJXaFKEayBFKL4MyZhytoGsHKDixtICCC+uQ
s35+3Pg8G2gLGrFw1rcAAAAASUVORK5CYII=
"
	tablelist_mint_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAVUlEQVQoz+XRsQmAMBRF0SM6gQOl
dgwLB3OWLGCXMuAWljYKQRTTihd+8/591eOHNAiYK9wRscWKBQO6G3HDhHh9BCTk4tKRP1KWXuWy
lGvlk/5Dw+18fA9T93dmqwAAAABJRU5ErkJggg==
"
	tablelist_mint_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAATUlEQVQoz2NgoCv4////PFI1vPj/
//9yfGqYsIhZ4NOETQMnPk1MOAyCadpHrAaS/MDAwMDwnYGB4QQjI6MTMaF0n1BIkRSslEUcTQAA
5D0vedmcvmEAAAAASUVORK5CYII=
"
	tablelist_mint_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAOCAYAAAAbvf3sAAAAVUlEQVQoz+WRwQnAIBAEdwPpyTIs
NWXYhV878Dn5JGAkEb+ShfssM3Cw0g9jIEg6JthoO222k6QoqX6A9YYfLRCADJTm8vXBezppDHdS
mYIbaV9ouBPWj0JRP45ECQAAAABJRU5ErkJggg==
"
    } else {
	tablelist_mint_collapsedImg put "
R0lGODlhDAAOAMIHAAAAACEhISgoKCoqKkhISFxcXGRkZP///yH5BAEKAAcALAAAAAAMAA4AAAMd
eLrc7uaxUKQKo8qAteOBQDygSHZbZlHWEbVwmwAAOw==
"
	tablelist_mint_expandedImg put "
R0lGODlhDAAOAKEDAAAAACEhISkpKf///yH5BAEKAAMALAAAAAAMAA4AAAIWnI+py+0aopRIzCCU
jXnZzgTPSJZIAQA7
"
	tablelist_mint_collapsedSelImg put "
R0lGODlhDAAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAMAA4AAAIXhI+pGovRHIBx0Zou
PtpS94FbJpWmUQAAOw==
"
	tablelist_mint_expandedSelImg put "
R0lGODlhDAAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAMAA4AAAIRhI+py+0aopRo0mTZ
1a/7jxQAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::mint2TreeImgs
#------------------------------------------------------------------------------
proc tablelist::mint2TreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable mint2_${mode}Img \
		 [image create photo tablelist_mint2_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_mint2_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAQ0lEQVQoz2NgGCjQRY6mewwMDLMI
KWLCImZHSCM2TWyENDLhEMerkYkcj+PS9IuBgeEQAwNDGrGa8GogO8ipErm0AwAGOwrpO0JShAAA
AABJRU5ErkJggg==
"
	tablelist_mint2_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAVElEQVQoz+3RIQqAQBBA0afd4i08
kXhCryIYDSavYNNsWWEQXDQKfhhYhnlp+QMFGvSoMncbWsxQpkeH9QbsEVxrMGIJM6V9tggfgQiH
N+Cs/vDnHlP2D8ZcM1duAAAAAElFTkSuQmCC
"
	tablelist_mint2_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAUUlEQVQoz2NgGBAwadKk/8SoY0Lm
fP36lSiNTOgCMjIyBDViaHJ3dyeokQmbICGNTOQEGFZNO3fuZHjy5AlDXl4eI1GaCGnAqomQBrIj
l34AADlaJg96+zhqAAAAAElFTkSuQmCC
"
	tablelist_mint2_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAT0lEQVQoz+3RsQ3AQAgDQH/Fvgzi
yRjCS1BQkS5CivL6PkGiMicXAP8AABYAkOyqej0yM7j7egQkW1Jn5r2SmmRvayc8AhNGxDmY8GvP
vQB58zr4kXiRVAAAAABJRU5ErkJggg==
"
    } else {
	tablelist_mint2_collapsedImg put "
R0lGODlhDQAOAMIFAAAAACEhIScnJ2VlZXV1df///////////yH5BAEKAAcALAAAAAANAA4AAAMc
eLrc/odAFsZUQdgZ8n6dB4XaKI4l90HS5b5HAgA7
"
	tablelist_mint2_expandedImg put "
R0lGODlhDQAOAMIHAAAAACIiIiwsLC0tLS8vLzQ0NDc3N////yH5BAEKAAcALAAAAAANAA4AAAMZ
eLrc/jDKSYK9YbSCg3ic9UHcGBlTqq5RAgA7
"
	tablelist_mint2_collapsedSelImg put "
R0lGODlhDQAOAMIFAAAAAIeHh5KSkq6urvX19f///////////yH5BAEKAAcALAAAAAANAA4AAAMd
eLrc/kdAFuQ8YVgYiJ6dtzXh93TmmZ7j017wlAAAOw==
"
	tablelist_mint2_expandedSelImg put "
R0lGODlhDQAOAMIGAAAAAIeHh46OjszMzODg4PX19f///////yH5BAEKAAcALAAAAAANAA4AAAMa
eLrc/jDKKYK9QTRBiieawxVgJAyhOa1sGyUAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::newWaveTreeImgs
#------------------------------------------------------------------------------
proc tablelist::newWaveTreeImgs {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable newWave_${mode}Img \
		 [image create photo tablelist_newWave_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_newWave_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAABCUlEQVQoz8WSP0vEQBTE561h0SL2
FgFTZHGrlNY2FvJ6K/Ej2F6hvVjZChZWfgCzJ3YBOxftZSFwrRGuEJKT/LVKIQiXs7lpB37Mm3nA
ukXMvA3giogukiT5XBWwoZTaaprmtm3bE621UEq9Oee6sQABAHVd52maXud5ftD3/SszH60EIKK6
qqoPa+29tfamKIoJM0+ZeW/MCZtd151mWfYAYFGW5Xw2mz0LIb5837/UWiul1Itz7vsvgDckADD/
ZXheQURLu/AAQAjRDIAoinbCMJxIKQWAY2PM+1IAEdVBECy01mdSykMA58aYxzElDgl24zh+AnAH
YN8YU49dwQPQAZj+95HWrx8slWOLxRjWjwAAAABJRU5ErkJggg==
"
	tablelist_newWave_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAABBklEQVQoz9VSPUsDQRB9c7dedeSK
LW7/QLgjbHuV3RUiuD/AJtraWdgFUqS1lPwBA4KN3VjaXe0P2NYrrtAELBT2DrFJIITNRyU4MDBv
5s2D+QD+vZExpgcg2MP7YeZPX0EAuO267tw59+EjRFEkhRCPAK68AkQ0BnBSVdWdc67daD4qy/J6
yfFaaK39yvM8SJLkuK7rVwDfKy+K4jSO4ydmftkmsJp9KqXsK6VCAHMAc6VUKKXsA5juWk4AAMzc
EtFIaz0EsACw0FoPiWjEzO3OK6wDY8xz0zT3AKCUumTms31nFBv4Jk3T2TK+OOQPwnVgrX3PsmxA
RG/M/HCIgPDkJn/6yr/4D0fVv4huoQAAAABJRU5ErkJggg==
"
	tablelist_newWave_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAABEElEQVQoz9XRsUoDURAF0DvZl8QQ
iYquy75tLaxsZjv/wMJSEC39AnvBzlIEwc5a/IB0NoKFmGmsRKx3MQGjEkR8u28sRLCRbCrxtsMc
LjPAXydI07QTx/GRtfY6z/O3iQFrbatdw1mTsLMQW5ckiWRZ5qsCNQDoBCi25v172tZ9A71l5rWJ
ABB0qk7F6gyG24s6vdTCOTN3mXm5EkAEDQyVgaFyrkkf6yEeNyKshA3cMPMhM8/+BpjvBoGh4ueA
HOqA6rgG5mufYEytBIBnp+ZioNH9SK8A7IrI3VgABPUBlZd9H/aG/sl5bIpIt8oRDQC8OG2cPJTR
q9MDIjoW6bmqXzAA/KjAKaB7IjLAv8snuPFdR0oRvJ0AAAAASUVORK5CYII=
"
	tablelist_newWave_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAABDklEQVQoz9VSPUsDQRB9b/fuhKAn
gRA5q/yIq+0s7fwJFtYhbUCxs05pK/4IsbhOcBdNbWOVBUlhDu5E93JjFVC5fFSCAwPz5j0ew8wA
/z6YpmkMQK3R1caYvIkIROSypXASK5k3CfKauqxxBeC00QDAUAHHR3H9GfAnWQlw86YjAMNlo2nn
XNlJ9r3SPOy1WGrNepEP79x5+eCFtfZumYECAJKjccFJSUoQsgpCViUp44ITkqNVy1EAYIzxXjDI
ZmyHkfJhpHw2Y9sLBsYYv8pALwrn3PNWJznobbObz6GzqTxaa8/WnTH4hfu3r3IPAAL0N/kD/R04
56a73WSvqPBkrb3exCBo6J3/6St/AbNWYeq4QB0rAAAAAElFTkSuQmCC
"
    } else {
	tablelist_newWave_collapsedImg put "
R0lGODlhEAAOAIQdAAAAAFJSUl5eXl9fX2JiYmZmZmdnZ2lpaWtra2xsbG5ubnBwcHJycnR0dH19
fX9/f5KSkpSUlJqampycnJ2dnaGhoaenp6ysrLm5ucvLy8zMzN3d3ejo6P///////////yH5BAEK
AB8ALAAAAAAQAA4AAAU44CeOZGmeZYSegbCWAsQgr0hYFqU8r4H9mEpBgkJkjpnLgXhabDYaB2/V
4EwUtc8gkRWpuuDwKAQAOw==
"
	tablelist_newWave_expandedImg put "
R0lGODlhEAAOAIQSAAAAAFJSUltbW19fX2xsbHBwcHh4eHl5eX9/f5KSkpSUlJWVlZqamqenp6ys
rLm5ubq6usrKyv///////////////////////////////////////////////////////yH5BAEK
AB8ALAAAAAAQAA4AAAU04CeOZGmeaKqmSiC8cKCcQ7LcSzKkR+M3BxXB8Xg4CCtDJGJYfRAQCML5
KRSoHwYDy6WGAAA7
"
	tablelist_newWave_collapsedActImg put "
R0lGODlhEAAOAKUgAAAAAEA3NUI6N1A9OFE/OVNAOlNCO1BCPFFDPVRCO1VEPF5EO2JJP29IPU1E
QlBIRFdTU1dVU3lWR21tbZVdSJ9dSJdgS6RbRq1iSqpsUrFoTrRuUrlzVrh4WYWFhYyMjP//////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAAAALAAAAAAQAA4AAAY8QIBw
SCwaj0UP8hhwLIuDSwPyFBIwmMpi8ixovhrK4YM0bM4bC4J8THA4GQZ3qehIIlWA4JEXKvuAgUNB
ADs=
"
	tablelist_newWave_expandedActImg put "
R0lGODlhEAAOAIQSAAAAAD83NU87NlNGP2FIP29KPk1EQldUU21tbZ1oT6JXRKVYRKNiS6xhSrFo
TrdwU4WFhYyMjP///////////////////////////////////////////////////////yH5BAEK
AB8ALAAAAAAQAA4AAAU04CeOZGmeaKqmUCC8cACdhrLci2KkReM3BdWB4XAwDivC40FYfRCJBML5
GQyon0gEy6WGAAA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::oxygen1TreeImgs
#------------------------------------------------------------------------------
proc tablelist::oxygen1TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable oxygen1_${mode}Img \
		 [image create photo tablelist_oxygen1_${mode}Img]
    }

    tablelist_oxygen1_collapsedImg put "
R0lGODlhDwAGAKECAAAAABQTEv///////yH5BAEKAAAALAAAAAAPAAYAAAINhI95oQ3sVpgwPouq
KwA7
"
    tablelist_oxygen1_expandedImg put "
R0lGODlhDwAGAKECAAAAABQTEv///////yH5BAEKAAAALAAAAAAPAAYAAAIKhI+pyw0BoZtUFQA7
"
}

#------------------------------------------------------------------------------
# tablelist::oxygen2TreeImgs
#------------------------------------------------------------------------------
proc tablelist::oxygen2TreeImgs {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable oxygen2_${mode}Img \
		 [image create photo tablelist_oxygen2_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_oxygen2_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAVUlEQVQY063NsQ1AUBhF4S/RSAxi
ARWVRCMS21hF8Sq7WEEMoLGG5i3wvzjNrc49/MCENSpVeVvsaHCW1DtcOPJJmAEvtqjY40ZCHREX
PCVFGDFHpQ9E+QlJi3wOIgAAAABJRU5ErkJggg==
"
	tablelist_oxygen2_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAUklEQVQY08XQKwqAQAAE0BcXvI5p
TYJlEbyNyZuYPJTYtXgNyybTatBpMzDMhz/Ror9pCV2JOeFAzLzGjqE0fcSGBiump/VnnFjebA+5
QfXJ0xfHZQlg71WjSwAAAABJRU5ErkJggg==
"
	tablelist_oxygen2_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAdklEQVQY06WQLQ6DYBBE3zZwn09U
oUkQJJxhHUnRKI6BxOwdEFwCsWfoHVq7NYjKbjpm1Mv8wL9Sj1Y9hix3u7wGVvVYMrB8pd8BA05g
siKvX5OxIicwAh3wyNRGPRpgA3ZgzRzWq8dTPebM5uryNzBakSMDfwCuvyBR+rjbCQAAAABJRU5E
rkJggg==
"
	tablelist_oxygen2_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAYAAAAm06XyAAAAcklEQVQY08XQLQ7CQBAG0LcEQThN
BQpHgiGkd5gKLI4jcAX+VB1n6C3Wc5jFrCCYVsGoyZe8Sb7hbxO5bCKX/Ve2i1y2Y3aGBa6Ry7rC
FW5YjuFUwQkdDrjj2TfpPAnXAw+0GPomxZTK84/9iBcuP3n2G9A/HMoKfNhNAAAAAElFTkSuQmCC
"
    } else {
	tablelist_oxygen2_collapsedImg put "
R0lGODlhDwAIAIABAAAAAP///yH5BAEKAAEALAAAAAAPAAgAAAIQjI8ZAOrcXIJysmoo1jviAgA7
"
	tablelist_oxygen2_expandedImg put "
R0lGODlhDwAIAIABAAAAAP///yH5BAEKAAEALAAAAAAPAAgAAAIRjI+pawDnmHuThRntzfr2fxQA
Ow==
"
	tablelist_oxygen2_collapsedActImg put "
R0lGODlhDwAIAKECAAAAAGDQ/////////yH5BAEKAAAALAAAAAAPAAgAAAIQhI8JEercXIJysmoo
1jviAgA7
"
	tablelist_oxygen2_expandedActImg put "
R0lGODlhDwAIAKECAAAAAGDQ/////////yH5BAEKAAAALAAAAAAPAAgAAAIRhI+paxHnmHuTgRnt
zfr2fxQAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::phaseTreeImgs
#------------------------------------------------------------------------------
proc tablelist::phaseTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable phase_${mode}Img \
		 [image create photo tablelist_phase_${mode}Img]
    }

    tablelist_phase_collapsedImg put "
R0lGODlhDwAKAKECAAAAAMfHx////////yH5BAEKAAAALAAAAAAPAAoAAAIUhI9poQ3BHIJRPmov
lrS6bUHZMhYAOw==
"
    tablelist_phase_expandedImg put "
R0lGODlhDwAKAKECAAAAAMfHx////////yH5BAEKAAAALAAAAAAPAAoAAAIRhI+pyx0P4YqS0WYq
BmH7jxQAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::plain100TreeImgs
#------------------------------------------------------------------------------
proc tablelist::plain100TreeImgs {{treeStyle "plain100"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAYAAACALL/6AAAAKklEQVQY02NgoADUE6OIiVRNTKTa
xESq85hI9RM+DY2kaGgkxUmNVI0HAPz6BIzB2+8fAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAwAAAAKCAYAAACALL/6AAAAL0lEQVQY02NgGHSAkYGBoZ4IdY3I
GhgIaGpEt4EBj6ZGbE5iwKGpkVh/1Q9ssAIAIv0EhL5rqRkAAAAASUVORK5CYII=
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhDAAKAIABAH9/f////yH5BAEKAAEALAAAAAAMAAoAAAIUjI8IybB83INypmqjhGFzxxkZ
UgAAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhDAAKAIABAH9/f////yH5BAEKAAEALAAAAAAMAAoAAAIQjI+py+D/EIxpNscMyLyHAgA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::plain125TreeImgs
#------------------------------------------------------------------------------
proc tablelist::plain125TreeImgs {{treeStyle "plain125"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAMCAYAAAC9QufkAAAAMklEQVQoz2NgoCJoIkUxEyUGMFHi
AiZKvMBESRgwURKIxGiuI1dzHbnOriM3wOponsIAebUFmXDw+D8AAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA8AAAAMCAYAAAC9QufkAAAAN0lEQVQoz2NgGJKAkYGBoZ4E9Y3o
mhmINKARm80MRBjQiMvZDAQMaMTnZwY8BjSSE5D1DMMXAABNQwWFHKBjWAAAAABJRU5ErkJggg==
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhDwAMAIABAH9/f////yH5BAEKAAEALAAAAAAPAAwAAAIXjI95oB3AHIJRPmovlnS3Xn2e
M5IhlxUAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhDwAMAIABAH9/f////yH5BAEKAAEALAAAAAAPAAwAAAIVjI+pyw0PI0gyrjqZbAbyk33i
SBoFADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::plain150TreeImgs
#------------------------------------------------------------------------------
proc tablelist::plain150TreeImgs {{treeStyle "plain150"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAO0lEQVQoz8WTwQkAIAzEShaXbO4K
IhH7b+hd6MyjWbeLVDCqy6hiUnVGJYDK5inIAmQRzaJsC/1++7UNYcUGlAU+IlcAAAAASUVORK5C
YII=
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAAOCAYAAAAi2ky3AAAAP0lEQVQoz+3SuRHAIAwEwHXlzHXu
BgAJO+Vy7ejjpsqD8aEuM8ghllVHDrDsRtPEUu1IA0tn2Qosfy867lODF7S/BobiEIg7AAAAAElF
TkSuQmCC
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhEgAOAIABAH9/f////yH5BAEKAAEALAAAAAASAA4AAAIejI+poI3AXINRPmovzoFu631O
WEkh14kghBps27UFADs=
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhEgAOAIABAH9/f////yH5BAEKAAEALAAAAAASAA4AAAIYjI+py+2vgJx0xloZtm3DDAVc
KJLmiR4FADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::plain175TreeImgs
#------------------------------------------------------------------------------
proc tablelist::plain175TreeImgs {{treeStyle "plain175"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAAQCAYAAAD52jQlAAAAQ0lEQVQ4y72UgQkAMAjDJI+Pfr4b
hs08IGgbnPk0ZwvAAGNsjBEFRsYY5WFYgaHbKzRtaNrnp11U2kqlLX+mOOsvdQEd0weYc7j+XgAA
AABJRU5ErkJggg==
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAAQCAYAAAD52jQlAAAARUlEQVQ4y+2TMRIAIAjD4su9/twX
qAUZHMhODihAU80A5kO9dlKSYp06JSHWbXyCYjk7JSCWGxSmWJH0McSqPLnZX/cHC9piB4dGz7zF
AAAAAElFTkSuQmCC
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhFQAQAKECAAAAAICAgP///////yH5BAEKAAAALAAAAAAVABAAAAIjhI+pGOsZ2ntRTlXt
PVnv7k1g6IwkBm5GqgJdu1ZwfIq1OBcAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhFQAQAKECAAAAAICAgP///////yH5BAEKAAAALAAAAAAVABAAAAIehI+py+0PVZi02mXz
bLq+HkRaZFxkuZ1HqLbuCysFADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::plain200TreeImgs
#------------------------------------------------------------------------------
proc tablelist::plain200TreeImgs {{treeStyle "plain200"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABgAAAASCAYAAABB7B6eAAAASElEQVQ4y8WVhw0AIAzDkB9H/pwf
AEMPSNSMdowPM2+CUZNQb0ItF7Un1MZTp4s6wtQ92SGwJLCUyNJky5haFs3yVByDP/kHCxQRCJzE
wLOAAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABgAAAASCAYAAABB7B6eAAAATElEQVQ4y+3UyQ0AIAhE0W/lZDq3
A2XRg4YpgBdlgc73GYAdqKMVQBHR7gUUEHm+iCQibw9IIIo0mSCi6BQRQJQZU5yIbu2K9bl4OxOe
wQiIsZLIJgAAAABJRU5ErkJggg==
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhGAASAIABAH9/f////yH5BAEKAAEALAAAAAAYABIAAAIpjI+pC+sO2psmSgotznon23kV
GIkjeW1oiK1pi5pBLJPy+YpsnZs9VgAAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhGAASAIABAH9/f////yH5BAEKAAEALAAAAAAYABIAAAIijI+py+0Po5yg2osry1y3jkGg
J3ZTwJ1GqK5ki8LyTNdKAQA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::plastikTreeImgs
#------------------------------------------------------------------------------
proc tablelist::plastikTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable plastik_${mode}Img \
		 [image create photo tablelist_plastik_${mode}Img]
    }

    tablelist_plastik_collapsedImg put "
R0lGODlhDgAOAMIDAAAAAHZ2drW1tf///////////////////yH5BAEKAAQALAAAAAAOAA4AAAMp
SLrc/vCJQKlwc2gdLgsbsAUNqIlcOQAsO5BfOKrnzGTb692VFf1ARgIAOw==
"
    tablelist_plastik_expandedImg put "
R0lGODlhDgAOAMIDAAAAAHZ2drW1tf///////////////////yH5BAEKAAQALAAAAAAOAA4AAAMn
SLrc/vCJQKlwc2gdLgtbGDRgyJEDoKrD+JnnC7tLJnrMVHVR7zMJADs=
"
}

#------------------------------------------------------------------------------
# tablelist::plastiqueTreeImgs
#------------------------------------------------------------------------------
proc tablelist::plastiqueTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable plastique_${mode}Img \
		 [image create photo tablelist_plastique_${mode}Img]
    }

    tablelist_plastique_collapsedImg put "
R0lGODlhEQAOAOMLAAAAAHp4eH59fa+trfHx8fPz8/X19ff39/n5+fv7+/39/f//////////////
/////yH5BAEKAA8ALAAAAAARAA4AAAQ+8MlJq7042yG6FwMmKGSpCGKiBmqCXgIiBzLyWsIR7Ptx
VwKDMCA0/CiCgjKgLBwnAoJ0SnhKOJ9OSMPtYiIAOw==
"
    tablelist_plastique_expandedImg put "
R0lGODlhEQAOAOMLAAAAAHp4eH59fa+trfHx8fPz8/X19ff39/n5+fv7+/39/f//////////////
/////yH5BAEKAA8ALAAAAAARAA4AAAQ78MlJq7042yG6FwMmKGSpCGKirgl6CUgsI64lHEGeH3Ul
GMCgoUcRFI7IAnEiIDifhKWE8+mENNgsJgIAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::radianceTreeImgs
#------------------------------------------------------------------------------
proc tablelist::radianceTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable radiance_${mode}Img \
		 [image create photo tablelist_radiance_${mode}Img]
    }

    tablelist_radiance_collapsedImg put "
R0lGODlhEgAQAKUoAAAAAEBAQOTe1eTe1uTf1+bh2ejj2ujk3erl3uvn4Ozo4u3p4+7q5O/r5u/s
5+/t6PDt6PPw7PLw7fXz8Pb08ff18vb18/f28vj28fj28vj28/j39Pj39fj49fn49/n5+Pr6+Pv7
+fz8+fz8+vz8+/39/P39/f7+/f//////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAaZwJ9w
SCwWD4KkUnkwFjAj02k6NY0oBeLBQiKVvuBS19IUCkCgkGjEZotCaMFQ4Kl/7oH7p+6RmzkcGxsc
HQEdgYAcfj8CGhoZGhQVARUVF44aiwIUFBMBn6ABnBSaEhESqBIBqamaEA+wsAGxsBCaC7i5Abm4
DJoJCMHCwwgKiwcNBsrLzAYOZUIFCgQD1dYDBApZR0vd0EJBADs=
"
    tablelist_radiance_expandedImg put "
R0lGODlhEgAQAKUoAAAAAEBAQOTe1eTe1uTf1+bh2ejj2ujk3erl3uvn4Ozo4u3p4+7q5O/r5u/s
5+/t6PDt6PPw7PLw7fXz8Pb08ff18vb18/f28vj28fj28vj28/j39Pj39fj49fn49/n5+Pr6+Pv7
+fz8+fz8+vz8+/39/P39/f7+/f//////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAASABAAAAaTwJ9w
SCwWD4KkUnkwFjAj02k6NY0oBeLBQiKVvuBS19IUCkCgkGjEZotCaMFQ4Kl/7vhP3SM3czgbGxwd
hIB/HH0/AhoaGRoUFRcVkYwaiQIUFBMBnJ0BmRSXEhESpaanEpcQD6ytrg8QlwuztLWzDJcJCLu8
vQgKiQcNBsTFxgYOZUIFCgQDz9ADBApZR0vXykJBADs=
"
}

#------------------------------------------------------------------------------
# tablelist::ubuntuTreeImgs
#------------------------------------------------------------------------------
proc tablelist::ubuntuTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable ubuntu_${mode}Img \
		 [image create photo tablelist_ubuntu_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_ubuntu_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAgElEQVQoz73ROwrCUBSE4Q8jATtR
AkoWpZCVuA8xO0gr2LgdF+Cj0CJ1bGyuTUhuECTTzTn/FMMwllaxZ9LyFd64dMGTlk9RoEQ+BMMN
sxAohmCoccUmhNYxGBo8QukDsmkETrHEHXs8++A5Fjji/D12wTle2IWyvTph+5cFf9IH6EoSOPaU
kccAAAAASUVORK5CYII=
"
	tablelist_ubuntu_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAiklEQVQoz9XRIQoCYRAF4M8VXCzC
j2lFTJ7H5C02eA+bd9BgEBeP4R3MBrVZNFn+hZ8/qEnwwYThvZl5vOH/0EGFFfpvdE8surjjgSlO
uGTVwxbHIk4ecEXINgbcsIciIZYYoIx9iVDX9Sb1nGKGOc4YYYemJYtM3NqZxPPNp4QqrDH+NtLh
bz/4Au5zF3nYGscDAAAAAElFTkSuQmCC
"
	tablelist_ubuntu_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAiElEQVQoz72SoQoCURREz11YweIv
uFEQo83id+wvWMT/M4nFbhCxLNjXKMixaHks6xPEaQOHO8xw4S9Sp9/AN3WTC9/Vq3roSikSXwIn
YATs05RILwO7lx0CY6AB6og498FvzYAHMC96KgyACXABFhHRdBXcqke1Vde5a1SfpmvVVe7Oy5+9
wxNzbFn4+q5BGgAAAABJRU5ErkJggg==
"
	tablelist_ubuntu_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAsAAAAOCAYAAAD5YeaVAAAAj0lEQVQoz9WRMQ4BARBF30ejICKa
jUg4z15EOMsewC00nEOhlJAoHEDUT7MrCkQl8ZufmXnF/Bn4P0WdAlug/4G7AWUnyUmtgAVwfAHO
gFWSQ5qOugF6wOUJLIBrkhKg9TSYA0OgW9ddYAQsG+ABJzkDFTAG2rVXSU5vk6hrdV+v9Vlqoe7U
yVf3VAe//eAdhJ0u3C54tZ8AAAAASUVORK5CYII=
"
    } else {
	tablelist_ubuntu_collapsedImg put "
R0lGODlhCwAOAKECAAAAAExMTP///////yH5BAEKAAAALAAAAAALAA4AAAIWhI+py8EWYotOUZou
PrrynUmL95RLAQA7
"
	tablelist_ubuntu_expandedImg put "
R0lGODlhCwAOAKECAAAAAExMTP///////yH5BAEKAAAALAAAAAALAA4AAAIThI+pyx0P4Yly0pDo
qor3BoZMAQA7
"
	tablelist_ubuntu_collapsedSelImg put "
R0lGODlhCwAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAALAA4AAAIWhI+py8EWYotOUZou
PrrynUmL95RLAQA7
"
	tablelist_ubuntu_expandedSelImg put "
R0lGODlhCwAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAALAA4AAAIThI+pyx0P4Yly0pDo
qor3BoZMAQA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::ubuntu2TreeImgs
#------------------------------------------------------------------------------
proc tablelist::ubuntu2TreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable ubuntu2_${mode}Img \
		 [image create photo tablelist_ubuntu2_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_ubuntu2_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAYAAACJxx+AAAAAQ0lEQVQY02NgIAGoEFKwHZsiJiQ2
FwMDwxR0RUxoGjjRFTFhsYqTgYGhB5+C7wwMDCW4FHxnYGDIYWBguEO0LwiGAwABBAfLngO55AAA
AABJRU5ErkJggg==
"
	tablelist_ubuntu2_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAYAAACJxx+AAAAASElEQVQY073MsRFAQBgF4Y8LVCAU
aUZDAoECjIKc9Oa6kkj+kJAN3+48PqfBgunF54SKAT26EBcObCmGgjGiFif2p8sVs3+5ATBkB+s7
tAL3AAAAAElFTkSuQmCC
"
	tablelist_ubuntu2_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAYAAACJxx+AAAAAS0lEQVQY02NgIAGwYRNkQmILMzAw
sOJTwAnFrLgUMPz//38nVBE7NuuU/kNAHwMDgwguBccZGBj4cJqATRLZDf8ZGBh+QjFWgNVYAOY5
EusI1YWXAAAAAElFTkSuQmCC
"
	tablelist_ubuntu2_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAAgAAAAKCAYAAACJxx+AAAAARElEQVQY073MsQmAUBBEwblIRAT5
YAPWYG779mNkdEaHiYY60cLC43OBGePLf9SYMnPN24auCqVl5oIhInacT8mG3r8uDt8Ur7bv+awA
AAAASUVORK5CYII=
"
    } else {
	tablelist_ubuntu2_collapsedImg put "
R0lGODlhCAAKAMIFAAAAAD4+PkdHR0hISE9PT////////////yH5BAEKAAcALAAAAAAIAAoAAAMS
eLrcO+4E4cJsNhBmKfcMFDUJADs=
"
	tablelist_ubuntu2_expandedImg put "
R0lGODlhCAAKAMIEAAAAAD4+PkNDQ0tLS////////////////yH5BAEKAAAALAAAAAAIAAoAAAMO
CLrcziHKNaJo477NewIAOw==
"
	tablelist_ubuntu2_collapsedSelImg put "
R0lGODlhCAAKAMIGAAAAAN3d3d7e3ubm5uvr6/Hx8f///////yH5BAEKAAcALAAAAAAIAAoAAAMS
eLrcO+6E4oKhzBqSb5uOEDkJADs=
"
	tablelist_ubuntu2_expandedSelImg put "
R0lGODlhCAAKAKECAAAAAN3d3f///////yH5BAEKAAMALAAAAAAIAAoAAAINnI+pGO0nokhx2YtH
AQA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::ubuntu3TreeImgs
#------------------------------------------------------------------------------
proc tablelist::ubuntu3TreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable ubuntu3_${mode}Img \
		 [image create photo tablelist_ubuntu3_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_ubuntu3_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAXElEQVQoz53SwQnAMAiF4R+7RDtP
5uk0WbIDBHLtJaegz9Z3EYUPRIRCjq1vwASGQrb1F9CB8w9iAQktmEtoYosQWnIoF1rl5Bl6gHvV
T8gFCoUgQhJ4adk3lPMCv1MPZaZLyU8AAAAASUVORK5CYII=
"
	tablelist_ubuntu3_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAXUlEQVQoz93QMQ2AMBBA0dcggLUT
RjCBEdQggwUPOGFCAAJYOkBIKWyEn9xyubcc/yugQ3x4v2IKCQxoCmBBj7XChhkt6hKAKi3v4Akc
UQ5eQK6IMU1889X4FnyoHanvE2re8YhQAAAAAElFTkSuQmCC
"
	tablelist_ubuntu3_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAAYElEQVQoz7XQwQ2AMAiF4R/iFJ50
FKdwXEexJ9d43ptCq8Z3g/AlAHyNpH1kzqt6lnRKWp4ggAU4MuhBP4WebBFC79zchP7myz1UgM3M
yihqggyFIEIpAJiq+jKzlT9yA0MWI4rFHgIbAAAAAElFTkSuQmCC
"
	tablelist_ubuntu3_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAOCAYAAAD0f5bSAAAARUlEQVQoz93SsQkAIBAEwftOHuzN
ouxNLGXNBEX0U934JjvpvwzIklJwX82sCHCgca8BPngAziAA9+AAz2ADY2CB/ugjOncZoKZnp+Bb
AAAAAElFTkSuQmCC
"
    } else {
	tablelist_ubuntu3_collapsedImg put "
R0lGODlhDQAOAMIFAAAAADw8PFRUVKOjo7y8vP///////////yH5BAEKAAcALAAAAAANAA4AAAMf
eLrcR84NEdkItJ6LNe/RBzZiRgaoeY4SK6kRpM1KAgA7
"
	tablelist_ubuntu3_expandedImg put "
R0lGODlhDQAOAMIFAAAAADY2NlRUVJeXl6+vr////////////yH5BAEKAAcALAAAAAANAA4AAAMd
eLrc/jA+Mqq9RInAOxfM5gVgI36QWKar5L5wlAAAOw==
"
	tablelist_ubuntu3_collapsedSelImg put "
R0lGODlhDQAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAANAA4AAAIZhI8JoRrczoNxUmer
vXI3/03R8oykuaBoAQA7
"
	tablelist_ubuntu3_expandedSelImg put "
R0lGODlhDQAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAANAA4AAAIUhI+py70Bo4RmTmRp
skw67YTi6BQAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::ubuntuMateTreeImgs
#------------------------------------------------------------------------------
proc tablelist::ubuntuMateTreeImgs {} {
    foreach mode {collapsed expanded collapsedSel expandedSel} {
	variable ubuntuMate_${mode}Img \
		 [image create photo tablelist_ubuntuMate_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_ubuntuMate_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAAAXklEQVQoz2NgoCawsbGRJlUPExo/
1sbGpoESAxgYGBjqSTGECYc40YYw4ZEjyhAmAvIEDWEiwpX1NjY2jpQY0HjkyJH95BrQeOTIEbK9
QFAzPgOI0ozLAKI1UyUvAADOUhxG1dpsVwAAAABJRU5ErkJggg==
"
	tablelist_ubuntuMate_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAAAYUlEQVQoz+3SsQ2AMAxE0Y/Ywx1b
nAS7MAgwCMMgeYt0mYQuUkSIkhqu9n+V4d8gaQLWjuZ095AAAEkbsDfEh7tndyNAjPEyM4ClJ05A
A1KMM6CCvMYPoIBU4+okzR/5xBvrpyg6R2b3OgAAAABJRU5ErkJggg==
"
	tablelist_ubuntuMate_collapsedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAAAWklEQVQoz2NgoCb4//+/DKl6mND4
Mf///2+gxAUV/yGggVwXwEA9sYYw4ZEjyhAmAvIEDWEiwpX1////d6TEgEZGRsb95BrQyMjISLYX
CGqmSjrAZkADXfMCAHPpOeamW0O+AAAAAElFTkSuQmCC
"
	tablelist_ubuntuMate_expandedSelImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAAASUlEQVQoz2NgGAWM////V2FgYEgh
Qc9cRkbG2ygi////r/9PHGjAaSwRhjQQdBseQxqI9iAWQxpIDlkkQxrIjp7////bj5CUCAC6C463
hFszLQAAAABJRU5ErkJggg==
"
    } else {
	tablelist_ubuntuMate_collapsedImg put "
R0lGODlhEAAOAMIFAAAAADw8PJ2dnaOjo83Nzf///////////yH5BAEKAAcALAAAAAAQAA4AAAMg
eLrc/m8I6EaYdNmb1ebZB0JiQFAiRgasuo4ojLpdnQAAOw==
"
	tablelist_ubuntuMate_expandedImg put "
R0lGODlhEAAOAMIFAAAAADw8PJeXl52dnc7Ozv///////////yH5BAEKAAcALAAAAAAQAA4AAAMf
eLrc/jBKKaq9oo3Aex/O5nHgI37SWabBOhFTLM9PAgA7
"
	tablelist_ubuntuMate_collapsedSelImg put "
R0lGODlhEAAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAQAA4AAAIbhI+puxGs3INHTmov
yzpy+IEWBYykRBpOyhoFADs=
"
	tablelist_ubuntuMate_expandedSelImg put "
R0lGODlhEAAOAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAQAA4AAAIXhI+py+0eopwh0auu
ZBrOB2xgOJamWQAAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs {{treeStyle "vistaAero"}} {
    variable scalingpct
    vistaAeroTreeImgs_$scalingpct $treeStyle
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs_100
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs_100 {{treeStyle "vistaAero"}} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAOCAYAAAAWo42rAAAAbUlEQVQoz83QsQqCUBQG4I9oayrd
Gpp6COfWBgVBH1Eh6A16myYRX6FF4XJBBXHonw7n/4bD4S+S4TRXHoL5hieSNQgfFLiuwQ5vlLgv
QejRosZ5CV5QocEwLY8RSpHjhW9YxPAx3thv/uP++QGucwwpQjDsiQAAAABJRU5ErkJggg==
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAOCAYAAAAWo42rAAAAOklEQVQoz2NgGLrAkYGBoZwYRVcY
GBhuElQUERHxH10hE5qiyREREdrYTGAiRhEyKIdahYwrh1oMAACO1g8CUDLawwAAAABJRU5ErkJg
gg==
"
	tablelist_${treeStyle}_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAOCAYAAAAWo42rAAAAiklEQVQoz2NgGHggc+T7FJkj3w1x
yTMhseMYGBiWyRz57kxIIQMDA8NMqOJIfFZ/gtJJMke+f5M58j0Jn4kMT2w45zEwMBQyMDDMlTny
XQOnQqhJ/QwMDMlPbDhvwMRZ0BQVMDAwVEIVLUeWY0EzMJ2BgSHqiQ3nXnSbkBUuYmBgmPvEhvM8
fWIOAAwvKe6unLtFAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAAoAAAAOCAYAAAAWo42rAAAAQUlEQVQoz2NgGKJA5sj3Spkj3zci
i7FgU8TAwNCELseETVGaNAuGAUzEKIIrJKQI2Y0WDAwMLLOe/kGW2zTUIgEAh5gVN7Wc7FMAAAAA
SUVORK5CYII=
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhCgAOAMIHAAAAAIKCgpCQkJubm6enp6ioqMbGxv///yH5BAEKAAcALAAAAAAKAA4AAAMa
eLrc/szAQwokZzx8hONH0HDemG3WI03skwAAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhCgAOAMIGAAAAACYmJisrK1hYWIaGhoiIiP///////yH5BAEKAAcALAAAAAAKAA4AAAMY
eLrc/jCeAkV4YtyWNR/gphRBGRBSqkoJADs=
"
	tablelist_${treeStyle}_collapsedActImg put "
R0lGODlhCgAOAMIGAAAAABzE9ybG9y/J9z/N+Hvc+v///////yH5BAEKAAcALAAAAAAKAA4AAAMa
eLrc/qzAIwgUZzxMHT9Bw30LpnnWI03skwAAOw==
"
	tablelist_${treeStyle}_expandedActImg put "
R0lGODlhCgAOAMIEAAAAAB3E92HW+YLf+////////////////yH5BAEKAAAALAAAAAAKAA4AAAMX
CLrc/jACAUN4YdyWNR/gpgiWRUloGiUAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs_125
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs_125 {{treeStyle "vistaAero"}} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAQCAYAAADNo/U5AAAAhElEQVQoz9XSMQrCUAwG4A9xL1jE
zcWtR3B3KIgg6OLk0YSOCqXg1rN4ABGF3qCLOJQnvoII/ltIvpAh/FXmSD4NDTr1FDnGfRDUWGLS
B91RYYtZLIIHCqyRxSJocMAGaSxKsMfpefIrwzdghB1KXLrNEEqxwhHX0MYQWuCM21c/4ndpAXQy
EDjRgV+jAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAQCAYAAADNo/U5AAAAT0lEQVQoz2NgGHlAkYGBwY9UDUcZ
GBhukqQhMjLyPzZNTDg0LImMjLTCZSITqRrQNRGlAVkT0RoYGBgYGKG0HwMDQzcONQsYGBjah3va
AgAg2BApacIJTgAAAABJRU5ErkJggg==
"
	tablelist_${treeStyle}_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAQCAYAAADNo/U5AAAArUlEQVQoz9XSIQ7CQBCF4T+0Zu8w
l8Cv4wIEV2QrMZBgapBgSEAUWSR1DRfAjecSe4dRTTANomlDcTBusvPNG7HwPyVqhahNP81NOv0c
qEVt9g0COAI3UUtGo+DdBciBUtTWY5MI3l2BLIKTqO1HoRZWDSyAXNTSUUjUkghq4NAmvyseAClQ
NLAJ3p2773EPWAE7IAveVX1L+5K2wDJ49xg6vYvuQBm8e/7GH30BhiMxHhSDo2EAAAAASUVORK5C
YII=
"
	tablelist_${treeStyle}_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAAA0AAAAQCAYAAADNo/U5AAAAUElEQVQoz2NgGGFA5sj3IJkj3zei
i7Pg08DAwDCHgYFBEF2OCZ+GNGkWQWzyTKRqwNBEjAYUTcRqgGsiRQNy6MUzMDAIznr6B5uaTSMh
eQEAgzAb/lYeOL4AAAAASUVORK5CYII=
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhDQAQAMIHAAAAAIGBgYuLi5OTk56enqenp8XFxf///yH5BAEKAAcALAAAAAANABAAAAMg
eLrc/tCZuEqh5xJ6z4jdIUDhETzhiCofeWxg+UxYjSUAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhDQAQAMIGAAAAACYmJjo6OllZWYaGhrGxsf///////yH5BAEKAAcALAAAAAANABAAAAMe
eLrc/jDKVqYIUgwM9e5DyDWe6JQmUwRsS0xwLDsJADs=
"
	tablelist_${treeStyle}_collapsedActImg put "
R0lGODlhDQAQAMIHAAAAAB7E9yTG9y/J9zTK9zjL+Hvc+v///yH5BAEKAAcALAAAAAANABAAAAMg
eLrc/tCZuEihh5xB9RGRdwSQOD4iiSpguXUXNWE0lgAAOw==
"
	tablelist_${treeStyle}_expandedActImg put "
R0lGODlhDQAQAMIFAAAAABzE9yvH92HW+YLf+////////////yH5BAEKAAcALAAAAAANABAAAAMe
eLrc/jDKNqYIUhAM9e5EyDWe6JQmMwRsW01wLDcJADs=
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs_150
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs_150 {{treeStyle "vistaAero"}} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAk0lEQVQ4y93TrwoCQRAH4A+5ZPMP
GCyCr2HVoEXhMPl4JhG0aPFlLAZBjWbLXpH1jtug4LSB+X0Msyx/VyO06gQab30fE3RTAThhil4q
8MAB87BRbQDu2CLHIAUokHVAhilAgeywRDMF6GCBDZ6xgawivAq3OH8aykrCeQhfylaMAW3MsMe1
6hljwBhH3L7yF35fL0eRFD0vdToiAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAVklEQVQ4y2NgGAV0Ae4MDAzllGi+
wsDAcJNszZGRkf/xGcCER3NvZGSkNiFbmCjRjM0AkjSjG0CyZmQDyNLMwMDAwAilyxkYGJLwqFvA
wMDQPpolsAMA67sS7mmtYFoAAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAkklEQVQ4y2NgGF5A5sj36TJHvgeR
oocJjR/NwMAwR+bI92hyDWBgYGCoYmBgmC5z5HsyOV74BKUzZI58/yZz5HsGWQagGVJAlgFkGYJu
AJIh/2WOfHckNhBRNDMwMPQxMDAUPrHh3E+/MKAoFqCaPxGbDhixuOAPAwND7hMbzqXEGMCCxl/K
wMCw+4kN57qhk4MBqw9f8e/1ZzoAAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABAAAAASCAYAAABSO15qAAAAVklEQVQ4y2NgGAW0BzJHvhfIHPm+
EZc8CyHNDAwM3fjUMRHSHC/JgtcSJkKa2Znwe5GJEs0YBpCqGcUAcjTDDSBXM3I0OjIwMLAsfP4H
l7pNozkCNwAAt+IfTnBR4NgAAAAASUVORK5CYII=
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhEAASAOMIAAAAAIaGhouLi5CQkJiYmKGhoaioqMPDw///////////////////////////
/////yH5BAEKAAAALAAAAAAQABIAAAQrEMhJq70426OrMd0EFiEAAkR4AkO3AoL2AkH2xvbUylLq
AiTVLMMpGY+ACAA7
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhEAASAMIGAAAAACYmJisrK1lZWYaGhoiIiP///////yH5BAEKAAcALAAAAAAQABIAAAMj
eLrc/jDKSWepR4Qqxp6dBw7kB4VlhKbPyjZFIM8Bgd14DiUAOw==
"
	tablelist_${treeStyle}_collapsedActImg put "
R0lGODlhEAASAMIFAAAAABzE9ybG9yvH93jc+v///////////yH5BAEKAAcALAAAAAAQABIAAAMj
eLrc/jA6IpsYdYmzc+8SCELj6JhBVIZa9XlcxmEyJd/4kQAAOw==
"
	tablelist_${treeStyle}_expandedActImg put "
R0lGODlhEAASAMIFAAAAAB3E92HW+Xvd+4Lf+////////////yH5BAEKAAcALAAAAAAQABIAAAMj
eLrc/jDKSaeoJ4Qaxp4d8UWhKJUmhKbOyjKCJmsXZt/4kwAAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs_175
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs_175 {{treeStyle "vistaAero"}} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAlElEQVQ4y+XTrQoCQRAA4A+5ZPMH
DBbB17Bq0KJwmHw8kwhatPgylguCGs2WvSLH3XEbFJw2sPMxO8PwNzFBp0lh6yMfYoZ+LAQXzDGI
hZ44YRk6bAzBA3ukGMVAObYN2DgGyrED1mjHQD2ssMOr7GFSgWzCrK5VX0tKkDQgWZ1hF0FdLHDE
re76i6Apzrh/5dZ+L96mrBQ93arVCgAAAABJRU5ErkJggg==
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAWElEQVQ4y2NgGAWDCrgzMDCUU8OQ
KwwMDDcpNiQyMvI/MQYx4TGkNzIyUptYW5moYQg2g8gyBN0gsg1BNogiQxgYGBgYoXQ5AwNDEh51
CxgYGNpHsxRlAAAzzRLucI72KAAAAABJRU5ErkJggg==
"
	tablelist_${treeStyle}_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAk0lEQVQ4y2NgGBlA5sj36TJHvgeR
o5cJjR/NwMAwR+bI92hKDWJgYGCoYmBgmC5z5HsyJV77BKUzZI58/yZz5HsGRQahGVZAkUEUGYZu
EJJh/2WOfHckNbBRDGFgYOhjYGAofGLDuX/gwogqsQY15BOp6YgRi4v+MDAw5D6x4VxKikEsaPyl
DAwMu5/YcK4b+iUHAMhVX/GmlHueAAAAAElFTkSuQmCC
"
	tablelist_${treeStyle}_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAAXUlEQVQ4y2NgGAWDB8gc+V4gc+T7
RkLqWAgZwsDA0E1IHQMDAwMTIUPiJVlYiHE5EyFD2JmICwImahiCYRC5hqAYRIkhcIMoNQQ5+h0Z
GBhYFj7/g0vdptEcRTkAAKPJH058YP1QAAAAAElFTkSuQmCC
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhEgASAOMIAAAAAIaGhouLi5CQkJiYmKGhoaioqMPDw///////////////////////////
/////yH5BAEKAAAALAAAAAASABIAAAQsEMhJq704a3m2NYZHhYUohQBhosAgsoDgwUCwwfI9ubOk
voDSirbpmI5ISgQAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhEgASAMIGAAAAACYmJisrK1lZWYaGhoiIiP///////yH5BAEKAAcALAAAAAASABIAAAMk
eLrc/jDKSSssVomQxeCV94VDCUqiOaVqxLZPEcx0QGR4rlsJADs=
"
	tablelist_${treeStyle}_collapsedActImg put "
R0lGODlhEgASAMIFAAAAABzE9ybG9yvH93jc+v///////////yH5BAEKAAcALAAAAAASABIAAAMl
eLrc/jBKRaYTwzJxuO6KZ4miVJYQGkznuKBp+HFwhH0Uru9KAgA7
"
	tablelist_${treeStyle}_expandedActImg put "
R0lGODlhEgASAMIFAAAAAB3E92HW+Xvd+4Lf+////////////yH5BAEKAAcALAAAAAASABIAAAMj
eLrc/jDKSSsUVoWQw+CVR4CTOFLmKaUqxLaOsM0blt14XiUAOw==
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaAeroTreeImgs_200
#------------------------------------------------------------------------------
proc tablelist::vistaAeroTreeImgs_200 {{treeStyle "vistaAero"}} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_${treeStyle}_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAASCAYAAAC0EpUuAAAAlUlEQVQ4y+3TrwoCQRAH4A+5ZPMP
GCyCr2HVoEXhMPl4JhG0aPFlLAZBjWbLXhEP93CDgr844WNmdpZ/njJA4xOg9qLWxQjtlCgcMEYn
JXrDDtPQeRIUrlgjRy8VWsDLAPdToQW8wRz1VGgLM6xwj0GzCHARdnuMHT97A+YBPFV5qDK0iQm2
OFc9qTJ0iD0uX/P3fycPZOQUPUGGEDQAAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAASCAYAAAC0EpUuAAAAWUlEQVQ4y2NgGAXDCrgzMDCUU9vA
KwwMDDepamBkZOR/UgxlImBgb2RkpDapLmGitoG4DKXIQGyGUmwguqFUMZCBgYGBEYldzsDAkIRH
7QIGBob20Sw7MAAA1EIS7m4d8XoAAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_collapsedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAASCAYAAAC0EpUuAAAAlUlEQVQ4y2NgGAXIQObI9+kyR74H
UWIGExaxaAYGhjkyR75HU9NQBgYGhioGBobpMke+J1PL+5+gdIbMke/fZI58z6CaoWgGF1DNUKoZ
jG4oksH/ZY58d6QkolAMZGBg6GNgYCh8YsO5f/CFKdVjH2rgJ3LTKSMOl/5hYGDIfWLDuZQcQ1mw
iC1lYGDY/cSGc93wL+kAdJtf8bMQS5gAAAAASUVORK5CYII=
"
	tablelist_${treeStyle}_expandedActImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAASCAYAAAC0EpUuAAAAXElEQVQ4y2NgGAXDB8gc+V4gc+T7
RmLVsxBjIAMDQzcxamGAiRgD4yVZWEjxGRMxBrIzkRZcTNQ2EKuhlBqIYSg1DEQxlFoGoicpRwYG
BpaFz//gUrtpNMcOHAAAiLgfTviWUiAAAAAASUVORK5CYII=
"
    } else {
	tablelist_${treeStyle}_collapsedImg put "
R0lGODlhFQASAOMIAAAAAIaGhouLi5CQkJiYmKGhoaioqMPDw///////////////////////////
/////yH5BAEKAAAALAAAAAAVABIAAAQvEMhJq7046w0Ox4bxWWIxUiJAnFIKDKwLCKcMBKNM5xNc
S6sYwMQChIoSD3LJjAAAOw==
"
	tablelist_${treeStyle}_expandedImg put "
R0lGODlhFQASAMIGAAAAACYmJisrK1lZWYaGhoiIiP///////yH5BAEKAAcALAAAAAAVABIAAAMl
eLrc/jDKSauV5TIRtBJDp4HhOJxiRaLWylLuiwV0HRBeru97AgA7
"
	tablelist_${treeStyle}_collapsedActImg put "
R0lGODlhFQASAMIFAAAAABzE9ybG9yvH93jc+v///////////yH5BAEKAAcALAAAAAAVABIAAAMn
eLrc/jDKeQiFYlwnTt/L94HjeJnmlAYbSoagp6RUR9darFh67y8JADs=
"
	tablelist_${treeStyle}_expandedActImg put "
R0lGODlhFQASAMIFAAAAAB3E92HW+Xvd+4Lf+////////////yH5BAEKAAcALAAAAAAVABIAAAMl
eLrc/jDKSauV4rIQtApDp4GEaJHlhabVyk7uGwlczWVeru96AgA7
"
    }
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs {{treeStyle "vistaClassic"}} {
    variable scalingpct
    vistaClassicTreeImgs_$scalingpct $treeStyle
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs_100
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs_100 {{treeStyle "vistaClassic"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    tablelist_${treeStyle}_collapsedImg put "
R0lGODlhCwAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAALAA4AAAIjnI+pm+H/TBC0iiAr
qHhMulHdBJTllYFcKoSoZ60eBDH2UgAAOw==
"
    tablelist_${treeStyle}_expandedImg put "
R0lGODlhCwAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAALAA4AAAIfnI+pm+H/TBC0iiBt
xWPqmwGiCHZf6Wlcaq0QxMRLAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs_125
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs_125 {{treeStyle "vistaClassic"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    tablelist_${treeStyle}_collapsedImg put "
R0lGODlhDgAQAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAOABAAAAIrnI+pyxoPYzhB2Hun
qRdgPXCWl1EYaYEVwLaeen5mJ29xaWN1KEnNDxwUAAA7
"
    tablelist_${treeStyle}_expandedImg put "
R0lGODlhDgAQAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAOABAAAAIonI+pyxoPYzhB2Hun
qRjrwXXWF4qkAKQqIJziSL3wJrexTEpSw/dDAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs_150
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs_150 {{treeStyle "vistaClassic"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    tablelist_${treeStyle}_collapsedImg put "
R0lGODlhEQASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAARABIAAAI3nI+py60Bo4woiIuz
CFUDzR1W9mWhMWIldg7ptV6tBdS2vXUkqKu86PmhgqaehlWZKFuOpnNQAAA7
"
    tablelist_${treeStyle}_expandedImg put "
R0lGODlhEQASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAARABIAAAIxnI+py60Bo4woiIuz
CFV7flheBhrieJXDiaoWAMfx1qFpbbv2He50v3NNhiqH8TgoAAA7
"
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs_175
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs_175 {{treeStyle "vistaClassic"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    tablelist_${treeStyle}_collapsedImg put "
R0lGODlhFAASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAUABIAAAI8nI+pyxgPo0xB2Itv
oLnb7XRABx5VNmalcWIptg7t9WqcAOS6/t0u6aMBQ6ihSWRkeZKypYoiiUIaVEUBADs=
"
    tablelist_${treeStyle}_expandedImg put "
R0lGODlhFAASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAUABIAAAI2nI+pyxgPo0xB2Itv
oLnb7XgdeFQiRhrm+XFsGwrATNNw+d5qLqTDyvIBT0JeMSeUKCGNpqIAADs=
"
}

#------------------------------------------------------------------------------
# tablelist::vistaClassicTreeImgs_200
#------------------------------------------------------------------------------
proc tablelist::vistaClassicTreeImgs_200 {{treeStyle "vistaClassic"}} {
    foreach mode {collapsed expanded} {
	variable ${treeStyle}_${mode}Img \
		 [image create photo tablelist_${treeStyle}_${mode}Img]
    }

    tablelist_${treeStyle}_collapsedImg put "
R0lGODlhFwASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAXABIAAAJHnI+pFu0Pmwqi2ovD
xPzqRGHAyH1IeI1AuYlk1qav16q2XZlHePd53cMJdAyOigUyAlawpItJc8qgFuIA1Wmesh1r5PtQ
FAAAOw==
"
    tablelist_${treeStyle}_expandedImg put "
R0lGODlhFwASAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAXABIAAAI+nI+pFu0Pmwqi2ovD
xPzqRHXdh4Ritp0oqK5lBcTyDFTkEdK6neo0z2pZbgzhMGUkDkxCJbPlNAJLkapDUQAAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::white100TreeImgs
#------------------------------------------------------------------------------
proc tablelist::white100TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable white100_${mode}Img \
		 [image create photo tablelist_white100_${mode}Img]
    }

    tablelist_white100_collapsedImg put "
R0lGODlhDAAKAIAAAP///////yH5BAEKAAEALAAAAAAMAAoAAAIUjI8IybB83INypmqjhGFzxxkZ
UgAAOw==
"
    tablelist_white100_expandedImg put "
R0lGODlhDAAKAIAAAP///////yH5BAEKAAEALAAAAAAMAAoAAAIQjI+py+D/EIxpNscMyLyHAgA7
"
}

#------------------------------------------------------------------------------
# tablelist::white125TreeImgs
#------------------------------------------------------------------------------
proc tablelist::white125TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable white125_${mode}Img \
		 [image create photo tablelist_white125_${mode}Img]
    }

    tablelist_white125_collapsedImg put "
R0lGODlhDwAMAIAAAP///////yH5BAEKAAEALAAAAAAPAAwAAAIXjI95oB3AHIJRPmovlnS3Xn2e
M5IhlxUAOw==
"
    tablelist_white125_expandedImg put "
R0lGODlhDwAMAIAAAP///////yH5BAEKAAEALAAAAAAPAAwAAAIVjI+pyw0PI0gyrjqZbAbyk33i
SBoFADs=
"
}

#------------------------------------------------------------------------------
# tablelist::white150TreeImgs
#------------------------------------------------------------------------------
proc tablelist::white150TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable white150_${mode}Img \
		 [image create photo tablelist_white150_${mode}Img]
    }

    tablelist_white150_collapsedImg put "
R0lGODlhEgAOAIAAAP///////yH5BAEKAAEALAAAAAASAA4AAAIejI+poI3AXINRPmovzoFu631O
WEkh14kghBps27UFADs=
"
    tablelist_white150_expandedImg put "
R0lGODlhEgAOAIAAAP///////yH5BAEKAAEALAAAAAASAA4AAAIYjI+py+2vgJx0xloZtm3DDAVc
KJLmiR4FADs=
"
}

#------------------------------------------------------------------------------
# tablelist::white175TreeImgs
#------------------------------------------------------------------------------
proc tablelist::white175TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable white175_${mode}Img \
		 [image create photo tablelist_white175_${mode}Img]
    }

    tablelist_white175_collapsedImg put "
R0lGODlhFQAQAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAVABAAAAIjhI+pGOsZ2ntRTlXt
PVnv7k1g6IwkBm5GqgJdu1ZwfIq1OBcAOw==
"
    tablelist_white175_expandedImg put "
R0lGODlhFQAQAKEBAAAAAP///////////yH5BAEKAAAALAAAAAAVABAAAAIehI+py+0PVZi02mXz
bLq+HkRaZFxkuZ1HqLbuCysFADs=
"
}

#------------------------------------------------------------------------------
# tablelist::white200TreeImgs
#------------------------------------------------------------------------------
proc tablelist::white200TreeImgs {} {
    foreach mode {collapsed expanded} {
	variable white200_${mode}Img \
		 [image create photo tablelist_white200_${mode}Img]
    }

    tablelist_white200_collapsedImg put "
R0lGODlhGAASAIAAAP///////yH5BAEKAAEALAAAAAAYABIAAAIpjI+pC+sO2psmSgotznon23kV
GIkjeW1oiK1pi5pBLJPy+YpsnZs9VgAAOw==
"
    tablelist_white200_expandedImg put "
R0lGODlhGAASAIAAAP///////yH5BAEKAAEALAAAAAAYABIAAAIijI+py+0Po5yg2osry1y3jkGg
J3ZTwJ1GqK5ki8LyTNdKAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::win7AeroTreeImgs
#------------------------------------------------------------------------------
proc tablelist::win7AeroTreeImgs {} {
    vistaAeroTreeImgs "win7Aero"
}

#------------------------------------------------------------------------------
# tablelist::win7ClassicTreeImgs
#------------------------------------------------------------------------------
proc tablelist::win7ClassicTreeImgs {} {
    vistaClassicTreeImgs "win7Classic"
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs {} {
    variable scalingpct
    win10TreeImgs_$scalingpct
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs_100
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs_100 {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable win10_${mode}Img \
		 [image create photo tablelist_win10_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_win10_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAKCAYAAABSfLWiAAAAZklEQVQoz63QsQmAQAwF0KeClYWF
jRPYOISjO4QD2AkOITYnHGLhnaZKAnmEz881Yso5LKO+Q58DVVG/RlAX5mQkG6oedisGtGHeUzK5
akKNDcubT4oHoA/A/DaT4itwz6TBkQrACcudDrpWA7yXAAAAAElFTkSuQmCC
"
	tablelist_win10_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABEAAAAKCAYAAABSfLWiAAAARUlEQVQoz2NgGEwgnoGBoQOHXAdU
Hi9gYmBg0GRgYDDHYlAHVFyTWNd0MDAw7EcyCJ3PQJJBPj4+/8k1gIFSF2AL6CEKAFm6Dd7JH9yK
AAAAAElFTkSuQmCC
"
    } else {
	tablelist_win10_collapsedImg put "
R0lGODlhEQAKAMIFAAAAAKampqysrL+/v9PT0////////////yH5BAEKAAcALAAAAAARAAoAAAMa
eLrcTMNJNUKcrl7MNG9CQHyURR4emZLQmQAAOw==
"
	tablelist_win10_expandedImg put "
R0lGODlhEQAKAMIFAAAAAEBAQExMTHd3d6CgoP///////////yH5BAEKAAcALAAAAAARAAoAAAMb
eLrc/o6MNggcYSqsHz8ftAVCJjLhuVhq64oJADs=
"
    }

    tablelist_win10_collapsedActImg put "
R0lGODlhEQAKAMIGAAAAAE7Q+VjS+Xra+5vh/Jri/P///////yH5BAEKAAcALAAAAAARAAoAAAMa
eLrcXMNJNUKcrl7MNG9CQHyURR4emZLQmQAAOw==
"
    tablelist_win10_expandedActImg put "
R0lGODlhEQAKAMIGAAAAABzE9yjH+FbS+YDb+4Lc+////////yH5BAEKAAcALAAAAAARAAoAAAMb
eLrc/o6MNgocYSqsHz8ftAVCJjLhuVhq64oJADs=
"
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs_125
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs_125 {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable win10_${mode}Img \
		 [image create photo tablelist_win10_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_win10_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAAMCAYAAACNzvbFAAAAbklEQVQoz73RwQ2AIAyF4R97kBsT
yAYu4sBu4BQcnYANvNTEECTBEnt7JflC+uCHWYHNikxFXoBghaXICYgKR81mdAgsL3sTLI23pMV5
xc+vRT3nLisDR89PXQMMCu69N3WjwRpqBmtFeWC2gAAX6rARzlVu5CMAAAAASUVORK5CYII=
"
	tablelist_win10_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABUAAAAMCAYAAACNzvbFAAAAU0lEQVQoz2NgGPEggYGBYT4BNfOh
6ogCTAwMDPYMDAwKeAyeD5W3J9ZQRjSNDxgYGBKxGIguTpSh2Awgy0B0Q5ENhgGSDcRmKAMlLiQE
6kdGwgcAYsgQgI4qe4AAAAAASUVORK5CYII=
"
    } else {
	tablelist_win10_collapsedImg put "
R0lGODlhFQAMAMIFAAAAAKamprW1tcTExNLS0v///////////yH5BAEKAAcALAAAAAAVAAwAAAMf
eLrcvkS8yUSQlFqc3+7TBzpBMIzVhS7i2qIvGq1HAgA7
"
	tablelist_win10_expandedImg put "
R0lGODlhFQAMAMIFAAAAAEBAQGBgYICAgJ+fn////////////yH5BAEKAAcALAAAAAAVAAwAAAMg
eLrc/jBKSMQTRIpg2e7Rt4jTIZKlGaxgqrbuMcR0HSUAOw==
"
    }

    tablelist_win10_collapsedActImg put "
R0lGODlhFQAMAMIGAAAAAE7Q+WfV+mjV+oHc+5ri/P///////yH5BAEKAAcALAAAAAAVAAwAAAMg
eLrcvkW8yUSQlFqcnx3d9IVPEBBkdaXLxiruG7/RmwAAOw==
"
    tablelist_win10_expandedActImg put "
R0lGODlhFQAMAMIGAAAAABzE9z7M+F/U+oDb+4Hc+////////yH5BAEKAAcALAAAAAAVAAwAAAMg
eLrc/jBKSMQTRYpg2e7Rt4jTIZKlGaxgqrbuMcR0HSUAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs_150
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs_150 {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable win10_${mode}Img \
		 [image create photo tablelist_win10_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_win10_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAABsAAAAQCAYAAADnEwSWAAAAi0lEQVQ4y83UIQuAMBCG4XcuGMRg
MS2I3Sj+/+if0LQugt1iENkczN1wbffBHnYHBz84RuJR7agNwAhUgJXEzAUBNKnBJ7ZfQCMButpo
pUDtqYuA+iVLDupAboEOKG/gAWwxWBHIJ6C+3Rdgjf2ZCkD9A5q/zEzlgnyYCOSamZGCfBtEAW1q
KPvWPwGNvhqpmBAh5QAAAABJRU5ErkJggg==
"
	tablelist_win10_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAABsAAAAQCAYAAADnEwSWAAAAk0lEQVQ4y+2Uuw2AMAxEHzAEE9DT
MwBihjTMQJEhmIQNKKnYgo5BoDFShAifyEIUXOVIJ7/48oFfyiqUfV7VwADYC58VXx0CSWSnjawz
IAVGD6iSOgcmYH4KmwWQnQBdEEAPdCGTIY19wCNQGxJj7NStNNpUGWMWLRBAdHE2aIHcGF3tI1UB
cfOa27ceevn/dZ/TCmPKG6Qk5tPpAAAAAElFTkSuQmCC
"
    } else {
	tablelist_win10_collapsedImg put "
R0lGODlhGwAQAMIHAAAAAKamprOzs8jIyNLS0t7e3uPj4////yH5BAEKAAcALAAAAAAbABAAAAMx
eLrc/szACUkYNCsTOtbU0F1gOH7lI3optJKtI4xFzLyojdvLzh8+Hof1U1hyRckvAQA7
"
	tablelist_win10_expandedImg put "
R0lGODlhGwAQAMIHAAAAAEBAQFtbW4mJiZ+fn7i4uMTExP///yH5BAEKAAcALAAAAAAbABAAAAMz
eLrc/jDKSZuJtx4SxhsBURlB6TFgmU1pt7RnBR+zprRC6dqvbvKNGhC1GzYKxqRyOUwAADs=
"
    }

    tablelist_win10_collapsedActImg put "
R0lGODlhGwAQAMIHAAAAAE7Q+WTV+oje+5ri/K3m/bbo/f///yH5BAEKAAcALAAAAAAbABAAAAMx
eLrc/szACUkYNCsTOtbU0F1gOH7lI3optJKtI4xFzLyojdvLzh8+Hof1U1hyRckvAQA7
"
    tablelist_win10_expandedActImg put "
R0lGODlhGwAQAOMJAAAAABzE9zjK+GnW+oDb+4Hc+5rh/Kfl/ajl/f//////////////////////
/////yH5BAEKAA8ALAAAAAAbABAAAAQ28MlJq704680ryl/3EMFwDUHRHUFrUmh7dHE51S/d2rh4
74JdzveouYiVHjJpW1oMzqh0uowAADs=
"
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs_175
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs_175 {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable win10_${mode}Img \
		 [image create photo tablelist_win10_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_win10_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAAB4AAAAQCAYAAAABOs/SAAAAiklEQVQ4y83VIQ+AIBCG4RcJBmew
mAjObnT+/+if0ER3bnaLwTGQoAfS7r7w7LgN4GfHSAPa0xuAEagAmwo2FwrQSOIuvF9YI437rtqm
wHWgL47rh0wU15HcAh1Q3vAD2N7CRSSfgPpWL8D6xcQqgvYOOn+1Y5UDDcHiqG/HJgUaerkU0Eqi
WX+nEw2kGqlLMldzAAAAAElFTkSuQmCC
"
	tablelist_win10_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAAB4AAAAQCAYAAAABOs/SAAAAkklEQVQ4y+2UsQmAMBBFnzqEE6S3
dwBxhjTOYJEhnMQNLK3cws5BtDkhiBohhiD4qgscedwPOfiJQPly3yMaYASMo89IX+MrzGSCVs4K
yIHpQlpLXQAzsPiIF5GpG7ktBRiA3ndiRHIlP5N2vlGnVt3JpTu11noNIQVIHG9JCKkdtc0x9tel
PPw6JsZSqf69+nk2EbYbpI72C58AAAAASUVORK5CYII=
"
    } else {
	tablelist_win10_collapsedImg put "
R0lGODlhHgAQAMIHAAAAAKamprOzs8jIyNLS0t7e3uPj4////yH5BAEKAAcALAAAAAAeABAAAAM0
eLrc/s/ASQ8Jo+plgs+bNnhYKJKgOY2fSrGlCwlkITtweiv5zvQ+Hiqo6LSIiosOKSEmAAA7
"
	tablelist_win10_expandedImg put "
R0lGODlhHgAQAMIHAAAAAEBAQFtbW4mJiZ+fn7i4uMTExP///yH5BAEKAAcALAAAAAAeABAAAAM1
eLrc/jDKSesxEdtFwnhDQGxXYH5MaGqW6i0uSsYHTcJmIOTyrbgnn8MmbIR6RUYhyWw6mQkAOw==
"
    }

    tablelist_win10_collapsedActImg put "
R0lGODlhHgAQAMIHAAAAAE7Q+WTV+oje+5ri/K3m/bbo/f///yH5BAEKAAcALAAAAAAeABAAAAM0
eLrc/s/ASQ8Jo+plgs+bNnhYKJKgOY2fSrGlCwlkITtweiv5zvQ+Hiqo6LSIiosOKSEmAAA7
"
    tablelist_win10_expandedActImg put "
R0lGODlhHgAQAOMJAAAAABzE9zjK+GnW+oDb+4Hc+5rh/Kfl/ajl/f//////////////////////
/////yH5BAEKAA8ALAAAAAAeABAAAAQ38MlJq7046837QxnoTUQwXENQjM8RvCeVvgc7m9Md2y+u
s7KeoLcDSm4wo+WnXOKaFwN0Sq1OIwA7
"
}

#------------------------------------------------------------------------------
# tablelist::win10TreeImgs_200
#------------------------------------------------------------------------------
proc tablelist::win10TreeImgs_200 {} {
    foreach mode {collapsed expanded collapsedAct expandedAct} {
	variable win10_${mode}Img \
		 [image create photo tablelist_win10_${mode}Img]
    }

    variable pngSupported
    if {$pngSupported} {
	tablelist_win10_collapsedImg put "
iVBORw0KGgoAAAANSUhEUgAAACMAAAASCAYAAADR/2dRAAAAc0lEQVRIx2NgwA10GOgMGPE4BOaY
FQPpGB0soUIXBzFhEbuCRSxiIKMJlwNWDJRj6O4gRiLU0M1BjESqo4uDGElQS3MHMTEMIjDkomnQ
JOBBk7UHTaFHd4fgyk06A+EQBgYGBmYsYq+gtBi9mxAMg6lxBQBTKRAWhaNStgAAAABJRU5ErkJg
gg==
"
	tablelist_win10_expandedImg put "
iVBORw0KGgoAAAANSUhEUgAAACMAAAASCAYAAADR/2dRAAAAb0lEQVRIx2NgGAVDDMTTSQ9Rhu6D
YmIBTD3VHMQINQzdQCciHIIMFkIxxY5hwBEiTkQ6hBjHk+QYYi2hmUPQHUPIMpo6BJtjGEhIxE7U
zkWMJKQLmjoEn2PwOYgmDiHkGGwOoplDSC3cRsEoGHQAAKAaEvmT/Wu2AAAAAElFTkSuQmCC
"
    } else {
	tablelist_win10_collapsedImg put "
R0lGODlhIwASAKEDAAAAAKenp9PT0////yH5BAEKAAMALAAAAAAjABIAAAIynC+ny+0SgptUwSir
bjjur3QZ+IkkaJ5bqlZs67zwIs9HbQ+4vc89fPHkGpfhJGE0FAAAOw==
"
	tablelist_win10_expandedImg put "
R0lGODlhIwASAKEDAAAAAEFBQaCgoP///yH5BAEKAAMALAAAAAAjABIAAAI1nI+py+0PozQC1olE
CG5frG3cIgbfVI5Iiq2lK7YJO9AynG43mav7bPspXsKGrohMKpfMRwEAOw==
"
    }

    tablelist_win10_collapsedActImg put "
R0lGODlhIwASAMIFAAAAAE7Q+VHQ+Zrh/Jri/P///////////yH5BAEKAAcALAAAAAAjABIAAAM7
eLqz/jDKEYS82NFQs5cC133kEnJWWZ6cuoqBS7Kx7NF2hucgzPeiX2QndLBSRZMImTxsRs0FARqV
VhMAOw==
"
    tablelist_win10_expandedActImg put "
R0lGODlhIwASAMIEAAAAAB3E94Db+4Hc+////////////////yH5BAEKAAAALAAAAAAjABIAAAM3
CLrc/jDKSatVg+bLRAjSt3HD90FmMF4p2LQcAy9zTKdKbd+tuT+90w+oG758xogwyWw6n1BJAgA7
"
}

#------------------------------------------------------------------------------
# tablelist::winnativeTreeImgs
#------------------------------------------------------------------------------
proc tablelist::winnativeTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable winnative_${mode}Img \
		 [image create photo tablelist_winnative_${mode}Img]
    }

    tablelist_winnative_collapsedImg put "
R0lGODlhDgAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAOAA4AAAIlnI+pyxoPYQqiWhGm
BTYjWnGVd1DAeWJa2K2CqH5X+0VRg+dHAQA7
"
    tablelist_winnative_expandedImg put "
R0lGODlhDgAOAKECAAAAAICAgP///////yH5BAEKAAMALAAAAAAOAA4AAAIinI+pyxoPYQqiWhHm
tRnRjWnAOIYeaB7f1qloa0RyQ9dHAQA7
"
}

#------------------------------------------------------------------------------
# tablelist::winxpBlueTreeImgs
#------------------------------------------------------------------------------
proc tablelist::winxpBlueTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable winxpBlue_${mode}Img \
		 [image create photo tablelist_winxpBlue_${mode}Img]
    }

    tablelist_winxpBlue_collapsedImg put "
R0lGODlhDgAOAIQeAAAAAHiYtbDC08C3psG4p8K4qMO6qsa+rs/Iu9LMv9LMwNbRxtjTydvWzNzY
z9/b0uPg2eTh2eXh2urp4+3t5/Hw6/Dw7PLy7vX18ff28/b29Pf39fz8+vz8+////////yH5BAEK
AB8ALAAAAAAOAA4AAAVJ4CeOZGmeqCkEbBsIZeDNtBfEXQ50XHaTgc1GA9BUJL9RAANoNh9JUeBi
oQAmkEb0E4g4GICFArENJA4FAmFg2K5cLFhqTheFAAA7
"
    tablelist_winxpBlue_expandedImg put "
R0lGODlhDgAOAKUgAAAAAHiYtbDC08C3psG4p8K4qMO6qsa+rs/Iu9LMv9LMwNbRxtfSx9jTydvW
zNzYz9/b0uPg2eTh2eXh2urp4+zr5u3t5/Hw6/Dw7PLy7vX18ff28/b29Pf39fz8+vz8+///////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKAD8ALAAAAAAOAA4AAAZNwJ9w
SCwaj0ijIMBsBgTFAGhKBQWin2zWs7kSA50OZ3yZeIcBDWC9hpyFgQzGUqFEHO9fQPJoMBYKCHkB
CQcFBAQDBnlLTkxQSZGSQkEAOw==
"
}

#------------------------------------------------------------------------------
# tablelist::winxpOliveTreeImgs
#------------------------------------------------------------------------------
proc tablelist::winxpOliveTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable winxpOlive_${mode}Img \
		 [image create photo tablelist_winxpOlive_${mode}Img]
    }

    tablelist_winxpOlive_collapsedImg put "
R0lGODlhDgAOAIQdAAAAAI6ZfcC3psG4p8K4qMO6qsa+rs/Iu9LMv9LMwNbRxtjTydvWzNzYz9/b
0uPg2eTh2eXh2urp4+3t5/Hw6/Dw7PLy7vX18ff28/b29Pf39fz8+vz8+////////////yH5BAEK
AB8ALAAAAAAOAA4AAAVF4CeOZGme6BmsbGAGXSx3LhlwOMBtWD0GGk0GkKFEfKLABcBkOpCfgKUy
AUgeDGgA0lgAFImDFmEgDAaCAjTaWqXecFIIADs=
"
    tablelist_winxpOlive_expandedImg put "
R0lGODlhDgAOAKUfAAAAAI6ZfcC3psG4p8K4qMO6qsa+rs/Iu9LMv9LMwNbRxtfSx9jTydvWzNzY
z9/b0uPg2eTh2eXh2urp4+zr5u3t5/Hw6/Dw7PLy7vX18ff28/b29Pf39fz8+vz8+///////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////yH5BAEKACAALAAAAAAOAA4AAAZJQJBw
SCwaj8hjYMkMGAOfqPTjJAY8WGxHUx0GOJyN2CLpCgMZgFr9MIMCmEuFMoE03IGIg7FQJA54CAYE
AwMCBW5vTUtJjY5EQQA7
"
}

#------------------------------------------------------------------------------
# tablelist::winxpSilverTreeImgs
#------------------------------------------------------------------------------
proc tablelist::winxpSilverTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable winxpSilver_${mode}Img \
		 [image create photo tablelist_winxpSilver_${mode}Img]
    }

    tablelist_winxpSilver_collapsedImg put "
R0lGODlhDgAOAIQXAAAAAJSVosTO2MXP2cbO2svT3NPZ4tXb5Nnf5trg593i6d/l6uDm6+bq7ufr
7+zv8+/y9PLz9vT39/b3+ff4+vn6+v39/f///////////////////////////////////yH5BAEK
AB8ALAAAAAAOAA4AAAVD4CeOZGme6BmsbGAGVyxfLhlYOIBT9RhUFQqAEnH0RIEJYLlkHD8BSQQC
eDQUz0BjkQAgDobsoTAoCwhPaGuVartJIQA7
"
    tablelist_winxpSilver_expandedImg put "
R0lGODlhDgAOAIQYAAAAAJSVosTO2MXP2cbO2svT3NPZ4tXb5Nnf5trg593i6d/l6uDm6+bq7ufr
7+zv8+/x8+/y9PLz9vT39/b3+ff4+vn6+v39/f///////////////////////////////yH5BAEK
AB8ALAAAAAAOAA4AAAVC4CeOZGme6BmsbGAGWCxjLhlceF7VY2BZlaDEwRMFKIBkklH8BCaSCOTR
UDQDjUUigTgYrofCYCwgNJ2tVWrNJoUAADs=
"
}

#------------------------------------------------------------------------------
# tablelist::yuyoTreeImgs
#------------------------------------------------------------------------------
proc tablelist::yuyoTreeImgs {} {
    foreach mode {collapsed expanded} {
	variable yuyo_${mode}Img \
		 [image create photo tablelist_yuyo_${mode}Img]
    }

    tablelist_yuyo_collapsedImg put "
R0lGODlhDwAOAOMKAAAAAIiKhby9ur7AvMDBvsrMyd3e3eHi4OHi4f7+/v//////////////////
/////yH5BAEKAA8ALAAAAAAPAA4AAARA8MlJq72zjM1HqQWSKCSZIN80jORRJgM1lEpAxyptl7g0
E4Fg0KDoPWalHcmIJCmLMpZC8DKGpCYUqMNJYb6PCAA7
"
    tablelist_yuyo_expandedImg put "
R0lGODlhDwAOAOMIAAAAAIiKhb7AvMDBvsrMyd3e3eHi4f7+/v//////////////////////////
/////yH5BAEKAA8ALAAAAAAPAA4AAAQ58MlJq72TiM0FqYRxICR5GN8kjGV5CJTQzrA6t7UkD0Hf
F4jcQ3YjCYnFI2v2ooSWJhSow0lhro8IADs=
"
}

#------------------------------------------------------------------------------
# tablelist::createTreeImgs
#------------------------------------------------------------------------------
proc tablelist::createTreeImgs {treeStyle depth} {
    #
    # Get the width of the images to create for the specified depth and
    # the destination x coordinate for copying the base images into them
    #
    set baseWidth  [image width  tablelist_${treeStyle}_collapsedImg]
    set baseHeight [image height tablelist_${treeStyle}_collapsedImg]
    set step $baseWidth
    switch -regexp -- $treeStyle {
	^win10$ {
	    variable scalingpct
	    switch $scalingpct {
		100 { incr step -9 }
		125 { incr step -11 }
		150 { incr step -15 }
		175 { incr step -16 }
		200 { incr step -19 }
	    }
	}
	^(vistaAero|win7Aero)$ {
	    variable scalingpct
	    switch $scalingpct {
		100 { incr step  0 }
		125 { incr step -3 }
		150 { incr step -6 }
		175 { incr step -8 }
		200 { incr step -11 }
	    }
	}
	^(vistaClassic|win7Classic)$ {
	    variable scalingpct
	    switch $scalingpct {
		100 { incr step -1 }
		125 { incr step -4 }
		150 { incr step -7 }
		175 { incr step -10 }
		200 { incr step -13 }
	    }
	}
	^ubuntu$					      { incr step -2 }
	^(mate|mint2)$					      { incr step -1 }
	^(blueMenta|menta|mint|newWave|ubuntu2|ubuntuMate)$   { incr step  1 }
	^ubuntu3$					      { incr step  2 }
	^plasti.+$					      { incr step  3 }
	^(adwaita|aqua|arc)$				      { incr step  4 }
	^(oxygen.|phase|winnative|winxp.+)$		      { incr step  5 }
	^(baghira|klearlooks)$				      { incr step  7 }
	^.+100$						      { incr step  6 }
	^.+125$						      { incr step  8 }
	^.+150$						      { incr step  9 }
	^.+175$						      { incr step  11 }
	^.+200$						      { incr step  12 }
    }
    set x [expr {($depth - 1) * $step}]
    set width [expr {$x + $baseWidth}]

    #
    # Create the images for the given depth and copy the base images into them
    #
    foreach mode {indented collapsed expanded} {
	image create photo tablelist_${treeStyle}_${mode}Img$depth \
	    -width $width -height $baseHeight
    }
    foreach mode {collapsed expanded} {
	tablelist_${treeStyle}_${mode}Img$depth copy \
	    tablelist_${treeStyle}_${mode}Img -to $x 0

	foreach modif {Sel Act SelAct} {
	    variable ${treeStyle}_${mode}${modif}Img
	    if {[info exists ${treeStyle}_${mode}${modif}Img]} {
		image create photo \
		    tablelist_${treeStyle}_${mode}${modif}Img$depth \
		    -width $width -height $baseHeight
		tablelist_${treeStyle}_${mode}${modif}Img$depth copy \
		    tablelist_${treeStyle}_${mode}${modif}Img -to $x 0
	    }
	}
    }
}
