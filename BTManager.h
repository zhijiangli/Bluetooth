//
//  BTManager.h
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BTAllBlock.h"
#import "BTString.h"
#define BtServiceUUID @"FFE0"  // 服务 UUID
#define BtCharacteristicUUID @"FFE1" // 特征透传通道UUID
@interface BTManager : NSObject <CBPeripheralDelegate,CBCentralManagerDelegate>
{
    /** 蓝牙状态*/
    BluetoothStateUpdateBlock  btStateUpdateBlock;
    /** 发现一个蓝牙外设的回调 */
    DiscoverPeripheralBlock    btDiscoverPeripheralBlcok;
    /** 连接外设完成的回调 */
    ConnectSuccessBlock        btConnectSuccessBlock;
    /** 连接外设失败的回调 */
    ConnectFailedBlock         btConnectFailBlock;
    /** 连接断开的回调 */
    DisConnectBlock            btDisConnectBlock;
    /** 将数据写入特性中的回调*/
    WriteToCharacteristicBlock btWriteToCharacteristicBlock;
    /** 设备响应数据回调*/
    EquipmentReturnBlock       btEquipmentReturnBlock;
}
+(instancetype)share;
/**系统当前蓝牙的状态
 * @param stateBlock 实时返回当前蓝牙状态
 */
- (void)returnBluetoothStateWithBlock:(BluetoothStateUpdateBlock)stateBlock;
/**开始搜索蓝牙外设，每次在block中返回一个蓝牙外设信息
 * @param macHexStr  模糊搜索设备amc，目标设备名称包含字段(该参数视需求而定)
 * 返回的block参数可参考CBCentralManager 的 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 * @param discoverBlock 搜索到蓝牙外设后的回调
 */
- (void)scanForPeripheralsWithMacHexString:(NSString *)macHexStr
                        discoverPeripheral:(DiscoverPeripheralBlock)discoverBlock;
/**连接某个蓝牙外设，并查询服务，特性，特性描述
 * @param completionBlock     操作执行完的回调
 */
- (void)connectPeripheralCompleteBlock:(ConnectSuccessBlock)completionBlock
                             failBlock:(ConnectFailedBlock)failBlock
                       disConnectBlick:(DisConnectBlock)disConnectBlick;
/**往某个特性中写入数据，自动识别数据长度超过限制分段传输
 * @param hexStr       写入的十六进制数据（0C22FF）
 * @param completionBlock 写入完成后的回调,只有type为CBCharacteristicWriteWithResponse时，才会回调
 */
- (void)writeValueHexString:(NSString *)hexStr completionBlock:(WriteToCharacteristicBlock)completionBlock returnBlock:(EquipmentReturnBlock)equipmentBlock;
/**
 * 停止扫描
 */
- (void)stopScan;
/**
 * 断开蓝牙连接
 */
- (void)cancelPeripheralConnection;
@end
