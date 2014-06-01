//
//  IBAViewController.m
//  iBeaconApp
//
//  Created by shn on 2014/06/02.
//  Copyright (c) 2014年 pollseed. All rights reserved.
//

#import "IBAViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface IBAViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CLBeacon *nearestBeacon;

@end

@implementation IBAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
    {
        // CLLocationManagerの生成とデリゲートの設定
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        
        // 生成したUUID => NSUUID
        //
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"79D2AA27-F2F3-477A-BA0E-A3AF88FB8CA1"];
        
        // CLBeaconRegion作成
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID identifier:@"jp.classmethod.testregion"];
        
        // Beaconから領域観測を開始
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    // ローカル通知
    [self sendLocalNotificationForMessage:@"Enter Region"];
    
    // Beaconの距離測定を開始
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable])
    {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable])
    {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0)
    {
        //最も距離の近いBeaconについて処理
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        // Beaconの距離でメッセージを変える
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
//            case CLProximityUnknown:
//                rangeMessage = @"Range Unknown: ";
//                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        
        // ローカル通知
        NSString *message = [NSString stringWithFormat:@"mager:%@, minor:%@, accuracy:%f, rssi:%ld", nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
    }
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
