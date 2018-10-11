//
//  BTString.m
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import "BTString.h"

@implementation BTString
//创建一个单例
static BTString *dbManger=nil;
+(BTString *)share
{
    @synchronized(self){
        if (nil==dbManger) {
            dbManger=[[BTString alloc]init];
        }
        return dbManger;
    }
}
/**data转换为十六进制的string*/
- (NSString *)hexStringFromData:(NSData *)myD{
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++){
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }else{
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}
/** 十六进制字符串转data*/
-(NSData *)byteDataWithHexString:(NSString *)hexString{
    if (!hexString || [hexString length] == 0) {
        return nil;
    }
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= hexString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
/**16进制转10进制*/
-(NSString *)sixStrFromeHexString:(NSString *)hexString{
     NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([hexString UTF8String],0,16)];
    return temp10;
}
/**10进制转16进制*/
- (NSString *)hexStringFromSixInt:(NSInteger)decimal{
    return  [self hexStrFromSixInt:decimal];
}
- (NSString *)hexStringFromSixString:(NSString*)sixString{
    NSString * hexString = @"";
    for(int i=0;i<sixString.length;i++){
        NSString * tempStr = [sixString substringWithRange:NSMakeRange(i, 1)];
        NSString * hexStr = [self hexStrFromSixInt:[tempStr intValue]];
        hexString = [hexString stringByAppendingString:hexStr];
    }
    return hexString;
}
- (NSString *)hexStrFromSixInt:(NSInteger)decimal{
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter =@"a"; break;
            case 11:
                letter =@"b"; break;
            case 12:
                letter =@"c"; break;
            case 13:
                letter =@"d"; break;
            case 14:
                letter =@"e"; break;
            case 15:
                letter =@"f"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", (long)number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    if (hex.length == 1) {
        hex = [NSString stringWithFormat:@"0%@",hex];
    }
    return hex;
}
@end
