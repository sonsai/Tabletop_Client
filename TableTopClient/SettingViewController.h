//
//  SettingViewController.h
//  TableTopClient
//
//  Created by student on 14/11/26.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface SettingViewController : UIViewController
{

    IBOutlet UILabel *timesLabel;
    IBOutlet UISlider *timesController;
    AppDelegate *appDelegate;
}
@end
