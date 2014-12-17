//
//  ConnectionViewController.h
//  TableTopClient
//
//  Created by student on 14/11/26.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NSStreamAdditions.h"
#import "FileViewController.h"
#import "SettingViewController.h"

@interface ConnectionViewController : UIViewController<NSStreamDelegate>
{
    //接続用のパラメータを宣言
    IBOutlet UILabel *upload;
    IBOutlet UITextField *ipAddress;                //ipaddressのテキストフィルド
    IBOutlet UITextField *portNo;                   //port番号のテキストフィルド
    IBOutlet UITextField *userName;
    IBOutlet UITextField *markerNo;
    IBOutlet UIButton *conOrCan;                    //接続また切断するボタン
    IBOutlet UILabel *status;
    IBOutlet UILabel *sent;
    IBOutlet UILabel *received;
    IBOutlet UIButton *goToMain;
    
    AppDelegate *appDelegate;    
    NSMutableData *data;
    NSMutableData * recievedData;      
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
}
//タッブ場所を識別するためのrecognizer
@property(nonatomic,strong) UITapGestureRecognizer *singleTap;
//@property (nonatomic) NSInteger timeoutSec;

@end
