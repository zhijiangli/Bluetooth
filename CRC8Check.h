//
//  CRC8Check.h
//  CGLayerTest
//
//  Created by 小黎 on 2017/12/14.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRC8Check : NSObject
/** crc8 x8+x5+x4+1算法校验
 * @pram hexString 十六进制字符串 @"0c 81 11 22 33 44 55 66 02 0c 01"
 */
+(NSString *)crc8_maxin_charCheckWithHexString:(NSString*)hexString;
/** crc8 x8+x5+x4+1算法校验
 * @pram hexString 十六进制字符串 @"0c81112233445566020c01"
 */
+(NSString *)crc8_maxin_byteCheckWithHexString:(NSString*)hexString;
@end
