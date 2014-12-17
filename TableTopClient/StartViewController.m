//
//  StartViewController.m
//  TableTopClient
//
//  Created by student on 14/11/20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    [self initForStart];
    
    //[self.navigationController.navigationBar setHidden:YES];
	// Do any additional setup after loading the view.
}

-(void)initForStart
{
    //グロバル変数初期化
    appDelegate._motionManager = [CMMotionManager new];
    appDelegate.imageDataInfo = [NSMutableArray new];
    appDelegate.selectImage = [NSMutableArray new];
    appDelegate.recievedImage = [NSMutableArray new];
    appDelegate.selectedCell = NULL;
    appDelegate.accFlag = 0;
    appDelegate.ipAddress_ = NULL;
    appDelegate.portNo_ = 0;
    appDelegate.userName_ = NULL;
    appDelegate.yaw = 181;
    appDelegate.isUploadAvailable = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_startButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setStartButton:nil];
    [super viewDidUnload];
}
@end
