//
//  CRC8Check.m
//  CGLayerTest
//
//  Created by 小黎 on 2017/12/14.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import "CRC8Check.h"

@implementation CRC8Check
+(NSString *)crc8_maxin_charCheckWithHexString:(NSString*)hexString{
    //NSString * tempStr = @"11 01 11 22 33 44 55 66 01 06 01 02 03 04 05 06";
    NSString * tempStr = hexString;
    NSArray  * tempArray = [tempStr componentsSeparatedByString:@" "];//分隔符
    unsigned char testChars[(int)tempArray.count];
    for(int i=0;i<tempArray.count;i++){
        NSString * string = tempArray[i];
        unsigned char fristChar = [self hexHighFromChar:[string characterAtIndex:0]];
        unsigned char lastChar  = [self hexLowFromChar:[string characterAtIndex:1]];
        unsigned char temp = fristChar+lastChar;
        testChars[i] = temp;
    }
    unsigned char res = [self crc8_maxin_checkWithChars:testChars length:(int)tempArray.count];
    return [NSString stringWithFormat:@"%x", res];
}
+(unsigned char)hexHighFromChar:(unsigned char) tempChar{
    unsigned char temp = 0x00;
    switch (tempChar) {
        case 'a':temp = 0xa0;break;
        case 'A':temp = 0xA0;break;
        case 'b':temp = 0xb0;break;
        case 'B':temp = 0xB0;break;
        case 'c':temp = 0xc0;break;
        case 'C':temp = 0xC0;break;
        case 'd':temp = 0xd0;break;
        case 'D':temp = 0xD0;break;
        case 'e':temp = 0xe0;break;
        case 'E':temp = 0xE0;break;
        case 'f':temp = 0xf0;break;
        case 'F':temp = 0xF0;break;
        case '1':temp = 0x10;break;
        case '2':temp = 0x20;break;
        case '3':temp = 0x30;break;
        case '4':temp = 0x40;break;
        case '5':temp = 0x50;break;
        case '6':temp = 0x60;break;
        case '7':temp = 0x70;break;
        case '8':temp = 0x80;break;
        case '9':temp = 0x90;break;
        default:temp = 0x00;break;
    }
    return temp;
}
+(unsigned char)hexLowFromChar:(unsigned char) tempChar{
    unsigned char temp = 0x00;
    switch (tempChar) {
        case 'a':temp = 0x0a;break;
        case 'A':temp = 0x0A;break;
        case 'b':temp = 0x0b;break;
        case 'B':temp = 0x0B;break;
        case 'c':temp = 0x0c;break;
        case 'C':temp = 0x0C;break;
        case 'd':temp = 0x0d;break;
        case 'D':temp = 0x0D;break;
        case 'e':temp = 0x0e;break;
        case 'E':temp = 0x0E;break;
        case 'f':temp = 0x0f;break;
        case 'F':temp = 0x0F;break;
        case '1':temp = 0x01;break;
        case '2':temp = 0x02;break;
        case '3':temp = 0x03;break;
        case '4':temp = 0x04;break;
        case '5':temp = 0x05;break;
        case '6':temp = 0x06;break;
        case '7':temp = 0x07;break;
        case '8':temp = 0x08;break;
        case '9':temp = 0x09;break;
        default:temp = 0x00;break;
    }
    return temp;
}
+(char)crc8_maxin_checkWithChars:(unsigned char *)chars length:(int)len{
    unsigned char i;
    unsigned char crc=0x00; /* 计算的初始crc值 */
    unsigned char *ptr = chars;
    
    while(len--)
    {
        crc ^= *ptr++;
        for(i = 0;i < 8;i++)
        {
            if(crc & 0x01)
            {
                crc = (crc >> 1) ^ 0x8C;
            }else crc >>= 1;
        }
        
    }
    return crc;
}
+(NSString *)crc8_maxin_byteCheckWithHexString:(NSString*)hexString{
    //NSString *hexString = @"0c81112233445566020c01"; //16进制字符串
    int j=0;
    Byte bytes[128];
    ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else{
            
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        }
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else{
            
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        }
        int_ch = int_ch1+int_ch2;
        //NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    unsigned char res = [self crc8_maxin_checkWithBytes:bytes length:j];
    return  [NSString stringWithFormat:@"%.2x", res];;
}
+( unsigned char)crc8_maxin_checkWithBytes:(Byte *)bytes length:(int)len { // 0c 81 11 22 33 44 55 66  02 0c 01
    Byte i;
    unsigned char crc=0x00; /* 计算的初始crc值 */
    Byte *ptr = bytes;
    while(len--)
    {
        crc ^= *ptr++;
        for(i = 0;i < 8;i++)
        {
            if(crc & 0x01)
            {
                crc = (crc >> 1) ^ 0x8C;
            }else crc >>= 1;
        }
        
    }
    //NSLog(@"res= %.2x",crc);
    return crc;
}

@end
