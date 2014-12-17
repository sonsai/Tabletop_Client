//
//  RecievedViewController.h
//  TableTopClient
//
//  Created by student on 14/11/21.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TableViewConst.h"
#import "SentViewController.h"
#import "CustomTableViewCell.h"
#import "TableViewController.h"
@class CustomTableViewCell;
@interface RecievedViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *recievedImage;
}

//-(void)tableReload;


@end
