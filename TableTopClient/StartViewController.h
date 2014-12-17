//
//  StartViewController.h
//  TableTopClient
//
//  Created by student on 14/11/20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface StartViewController : UIViewController
{
    AppDelegate *appDelegate;
}

@property (retain, nonatomic) IBOutlet UIButton *startButton;
@end
