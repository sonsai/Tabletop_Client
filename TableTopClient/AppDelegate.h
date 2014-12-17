//
//  AppDelegate.h
//  TableTopClient
//
//  Created by student on 14/10/13.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreMotion/CoreMotion.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSMutableArray * imageDataInfo;
    NSMutableArray * selectImage;
    NSMutableArray * recievedImage;
    NSMutableArray * sendInfo;
    NSIndexPath * selectedCell;
    CMMotionManager *_motionManager;
    int accFlag;
    float yaw;
    bool status;

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray * imageDataInfo;
@property (nonatomic, retain) NSMutableArray * selectImage;
@property (nonatomic, retain) NSMutableArray * recievedImage;
@property (nonatomic, retain) NSMutableArray * sendInfo;
@property (nonatomic, retain) NSIndexPath * selectedCell;
@property (nonatomic, retain) NSString * ipAddress_;
@property (nonatomic, retain) NSString * portNo_;
@property (nonatomic, retain) NSString * userName_;
@property (nonatomic, retain) CMMotionManager *_motionManager;
@property (nonatomic,retain) NSInputStream *iStream;
@property (nonatomic,retain) NSOutputStream *oStream;
@property int sentBytes;
@property int recievedBytes;
@property int accFlag;
@property float yaw;
@property bool status;
@property BOOL isUploadAvailable;



@end
