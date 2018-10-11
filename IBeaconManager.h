//
//  IBeaconManager.h
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef void (^BluetoothStateUpdateBlock)(CBCentralManager *central);
typedef void (^DiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
@interface IBeaconManager : NSObject<CBCentralManagerDelegate>
{
    /** 蓝牙状态*/
    BluetoothStateUpdateBlock btStateUpdateBlock;
    /** 发现一个蓝牙外设的回调 */
    DiscoverPeripheralBlock btDiscoverPeripheralBlcok;
}
+(instancetype)share;
/**系统当前蓝牙的状态
 * @param stateBlock 实时返回当前蓝牙状态
 */
- (void)returnBluetoothStateWithBlock:(BluetoothStateUpdateBlock)stateBlock;
/**开始搜索蓝牙外设，每次在block中返回一个蓝牙外设信息
 * @param nameStr  模糊搜索设备 目标设备名称包含字段(该参数视需求而定)
 * 返回的block参数可参考CBCentralManager 的 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 * @param discoverBlock 搜索到蓝牙外设后的回调
 */
- (void)scanForPeripheralsWithPrefixNameString:(NSString *)nameStr
                        discoverPeripheral:(DiscoverPeripheralBlock)discoverBlock;
/**
 * 停止扫描
 */
- (void)stopScan;
@end
