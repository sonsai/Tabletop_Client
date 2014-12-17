//
//  SentViewController.h
//  TableTopClient
//
//  Created by student on 14/10/13.
//  Copyright (c) 2014年 student. All rights reserved.
//
@class CustomTableViewCell;
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsAccessor.h"
#import "TableViewConst.h"
#import "CustomTableViewCell.h"
#import "AppDelegate.h"
#import "ConnectionViewController.h"


@interface SentViewController : UIViewController <UIImagePickerControllerDelegate,UITabBarControllerDelegate,AssetsAccessorDelegate>
{
    NSString *accState;
    //通信用パラメータ
    NSIndexPath* openedIndexPath_;
    ALAssetsLibrary *library;
    AssetsAccessor *assetsAccessor;
    
}

@property (nonatomic, retain) NSIndexPath* openedIndexPath;
@property (retain,  nonatomic) IBOutlet UITableView *tableView;

- (void)stringToUint8_t:(NSString*)str;

@end
