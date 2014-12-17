//
//  FileViewController.h
//  TableTopClient
//
//  Created by student on 14/11/20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AssetsAccessor.h"
#import "AppDelegate.h"
#import "CustomTableViewCellForShowImage.h"
#import "TableViewConst.h"
#import "TableViewController.h"
@class CustomTableViewCellForShowImage;
@interface FileViewController : UIViewController<UIImagePickerControllerDelegate,UITabBarControllerDelegate,AssetsAccessorDelegate>
{
    IBOutlet UITableView *showFile;
}
@property (nonatomic, retain) NSArray *photoAssets;
@property (nonatomic, retain) NSArray *videoAssets;
+ (NSString *)nowTime;
@end
