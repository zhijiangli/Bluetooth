//
//  BTManager.m
//  Bluetooth
//
//  Created by 小黎 on 2017/12/16.
//  Copyright © 2017年 小黎. All rights reserved.
//

#import "BTManager.h"

@implementation BTManager
{
    CBCentralManager *btCentralManager;
    // 模糊搜索参数
    NSString * btMaxHexStr;
    //
    CBPeripheral * btPeripheral;
    CBService    * btService;
    CBCharacteristic * btCharacteristic;
    // 写入数据是否回复
    BOOL btIsResponse;
    NSError * error;
    
}
static BTManager *shareManager = nil;
+(instancetype)share{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        shareManager = [[BTManager alloc]init];
    });
    return shareManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        btCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        btIsResponse = NO;
    }
    return self;
}
- (void)dealloc
{
    btCentralManager.delegate = nil;
    btPeripheral.delegate = nil;
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
    NSString * mac = @"";
    for(NSString * key in [advertisementData allKeys]){
        if([key isEqualToString:@"kCBAdvDataManufacturerData"]){
            NSString * hexString = [[BTString share] hexStringFromData:advertisementData[key]];
            //NSLog(@"hexString = %@",hexString);
            if(hexString.length == 20){
                mac = [hexString substringFromIndex:8];
            }
        }
    }
    NSString * sixString1 = [[BTString share] sixStrFromeHexString:mac];
    NSString * sixString2 = [[BTString share] sixStrFromeHexString:btMaxHexStr];
    if(btMaxHexStr.length>0&&[sixString1 isEqualToString:sixString2]){
        btPeripheral = peripheral;
        if(btDiscoverPeripheralBlcok){
            btDiscoverPeripheralBlcok(central,peripheral,advertisementData,RSSI);
        }
    }
    //NSLog(@" === : %@",advertisementData);
}

//连接到Peripherals-成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{   //设置的peripheral委托CBPeripheralDelegate
    [peripheral setDelegate:self];
    //扫描外设Services
    [peripheral discoverServices:nil];
}
//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if(btConnectFailBlock){
        btConnectFailBlock(peripheral,error);
    }
}
//Peripherals断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(btDisConnectBlock){
        btDisConnectBlock(peripheral,error);
    }
    btPeripheral = nil;
    btCharacteristic = nil;
}
//扫描到Services 1
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error){
        if(btConnectFailBlock){
            btConnectFailBlock(peripheral,error);
        }
        return;
    }
    for (CBService *service in peripheral.services) {
        NSString * serverId = [[NSUserDefaults standardUserDefaults] objectForKey:@"BLEService"];
        serverId = [self UUIDWithString:serverId isServerId:YES];
        if([service.UUID.UUIDString isEqualToString:serverId]){
            btService = service;
            //扫描每个service的Characteristics
            [peripheral discoverCharacteristics:nil forService:service];
        }
        //NSLog(@"service == %@",service.UUID.UUIDString);
    }
}
//扫描到Characteristics
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error){
        if(btConnectFailBlock){
            btConnectFailBlock(peripheral,error);
        }
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics){
        NSString * characteristicId = [[NSUserDefaults standardUserDefaults] objectForKey:@"BLECharacteristic"];
        characteristicId = [self UUIDWithString:characteristicId isServerId:NO];
        if([characteristic.UUID.UUIDString isEqualToString:characteristicId]){ // 透传通道
            //[peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            btCharacteristic = characteristic;
            if(btConnectSuccessBlock){
                btConnectSuccessBlock(peripheral,service,characteristic);
            }
        }
        //NSLog(@"characteristic == %@",characteristic.UUID.UUIDString);
    }
    //搜索Characteristic的Descriptors
//    for (CBCharacteristic *characteristic in service.characteristics){
//       // [peripheral discoverDescriptorsForCharacteristic:characteristic];
//    }
}
//获取的charateristic的值  //获取到特征的值时回调, 蓝牙回复
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(btEquipmentReturnBlock && error==nil && characteristic.value != [NSData data] ){
        btEquipmentReturnBlock(peripheral,characteristic,characteristic.value,error);
        btIsResponse = YES;
    }
    //NSLog(@"value = %@ ,data = %@",characteristic.value,[NSData data]);
}

// 写入是否成功
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError *)error{
    btWriteToCharacteristicBlock(characteristic,error);
}

//订阅的特征值有新的数据时回调
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark -
/** 蓝牙的状态*/
- (void)returnBluetoothStateWithBlock:(BluetoothStateUpdateBlock)stateBlock{
    btStateUpdateBlock = stateBlock;
    btCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}
//搜索蓝牙外设
- (void)scanForPeripheralsWithMacHexString:(NSString *)macHexStr discoverPeripheral:(DiscoverPeripheralBlock)discoverBlock{
    btMaxHexStr  = macHexStr;
    btDiscoverPeripheralBlcok = discoverBlock;
    // 搜索
    [btCentralManager scanForPeripheralsWithServices:nil options:nil];
}
// 连接
- (void)connectPeripheralCompleteBlock:(ConnectSuccessBlock)completionBlock
                             failBlock:(ConnectFailedBlock)failBlock
                       disConnectBlick:(DisConnectBlock)disConnectBlick{
    btConnectSuccessBlock = completionBlock;
    btConnectFailBlock    = failBlock;
    btDisConnectBlock = disConnectBlick;
    if(btPeripheral){
        //连接设备
        [btCentralManager connectPeripheral:btPeripheral options:nil];
    }else{
        failBlock(nil,error);
    }
}
// 写数据
- (void)writeValueHexString:(NSString *)hexStr completionBlock:(WriteToCharacteristicBlock)completionBlock returnBlock:(EquipmentReturnBlock)equipmentBlock{
    btWriteToCharacteristicBlock = completionBlock;
    btEquipmentReturnBlock = equipmentBlock;
    NSData * data = [[BTString share] byteDataWithHexString:hexStr];
    if(btPeripheral && btCharacteristic){
        btIsResponse = NO;
        [btPeripheral writeValue:data forCharacteristic:btCharacteristic type:CBCharacteristicWriteWithResponse];//
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(1.5);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(btIsResponse == NO){
                    equipmentBlock(btPeripheral,btCharacteristic,[NSData data],error);
                }
            });
        });
    }else{
        completionBlock(nil,error);
    }
}
// 停止扫描
- (void)stopScan{
    [btCentralManager stopScan];
}
//断开蓝牙连接
- (void)cancelPeripheralConnection
{
    if (btPeripheral) {
        [btCentralManager cancelPeripheralConnection:btPeripheral];
    }
}

// 处理UIUID
-(NSString *)UUIDWithString:(NSString *) string isServerId:(BOOL) isSer{
    //NSLog(@"UUID = %@",string);
    NSString * resString = isSer == YES ? BtServiceUUID:BtCharacteristicUUID;
    if(string.length>=8){
        NSRange range = NSMakeRange(4, 4);
        string = [string substringWithRange:range];//截取范围内的字符串
        // 小写
        NSString *lower = [string lowercaseString];
        // 大写
        NSString *upper = [lower uppercaseString];
        
        resString = upper;
    }
    return  resString;
}

@end
