//
//  BTString.h
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTString : NSObject
+(BTString *)share;
/**data转换为十六进制的string*/
- (NSString *)hexStringFromData:(NSData *)myD;
/** 十六进制字符串转data*/
-(NSData *)byteDataWithHexString:(NSString *)hexString;
/**16进制转10进制
 @param hexString 16进制字符串
 @return 10进制字符串
 */
-(NSString *)sixStrFromeHexString:(NSString *)hexString;

/**10进制转16进制
 @param decimal 10进制数字
 @return 16进制字符串
 */
- (NSString *)hexStringFromSixInt:(NSInteger)decimal;
/** 字符串一个一个分开转*/
- (NSString *)hexStringFromSixString:(NSString*)decimal;
@end
