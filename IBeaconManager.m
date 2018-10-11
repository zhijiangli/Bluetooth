//
//  IBeaconManager.m
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import "IBeaconManager.h"
@implementation IBeaconManager
{
    CBCentralManager *btCentralManager;
    // 模糊搜索参数
    NSString * btNameString;
}
static IBeaconManager *shareManager = nil;
+(instancetype)share{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shareManager = [[IBeaconManager alloc]init];
    });
    return shareManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        btCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}
- (void)dealloc
{
    btCentralManager.delegate = nil;
    btCentralManager = nil;
}
#pragma mark -
//主设备状态改变
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if(btStateUpdateBlock){
        btStateUpdateBlock(central);
    }
}
//扫描到设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString * name = @"";
    for(NSString *key in [advertisementData allKeys]){
        if([key isEqual:@"kCBAdvDataLocalName"]){
            name = advertisementData[key];
        }
    }
    if([name containsString:btNameString] && btDiscoverPeripheralBlcok){
        btDiscoverPeripheralBlcok(central,peripheral,advertisementData,RSSI);
    }else if([name containsString:@"JDY"] && btDiscoverPeripheralBlcok){
        btDiscoverPeripheralBlcok(central,peripheral,advertisementData,RSSI);
    }
}
#pragma mark -
/**系统当前蓝牙的状态*/
- (void)returnBluetoothStateWithBlock:(BluetoothStateUpdateBlock)stateBlock{
    btStateUpdateBlock = stateBlock;
    btCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
/**开始搜索蓝牙外设，每次在block中返回一个蓝牙外设信息*/
- (void)scanForPeripheralsWithPrefixNameString:(NSString *)nameStr
                            discoverPeripheral:(DiscoverPeripheralBlock)discoverBlock{
    btNameString = nameStr;
    btDiscoverPeripheralBlcok = discoverBlock;
    [btCentralManager scanForPeripheralsWithServices:nil options:nil];
}
// 停止扫描
- (void)stopScan{
    [btCentralManager stopScan];
}
#pragma mark -
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
@end
