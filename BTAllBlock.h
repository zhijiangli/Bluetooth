
//
//  BTAllBlock.h
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#ifndef BTAllBlock_h
#define BTAllBlock_h

/** 蓝牙状态改变的block */
typedef void(^BluetoothStateUpdateBlock)(CBCentralManager *central);
/** 发现一个蓝牙外设的block */
typedef void(^DiscoverPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI);
/** 连接完成的block*/
typedef void(^ConnectSuccessBlock)(CBPeripheral *peripheral,CBService *service, CBCharacteristic *character);
/** 连接失败的block*/
typedef void(^ConnectFailedBlock)(CBPeripheral *peripheral, NSError *error);
/** 断开连接的block*/
typedef void(^DisConnectBlock)(CBPeripheral *peripheral, NSError *error);
/** 往特性中写入数据的回调 */
typedef void(^WriteToCharacteristicBlock)(CBCharacteristic *characteristic, NSError *error);
/** 设备返回数据的回调 */
typedef void(^EquipmentReturnBlock)(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSData *returnData, NSError *error);

#endif /* BTAllBlock_h */
