//
//  SettingViewController.m
//  TableTopClient
//
//  Created by student on 14/11/26.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
	// Do any additional setup after loading the view.
    appDelegate = [[UIApplication sharedApplication] delegate];
    timesLabel.text = [NSString stringWithFormat:@"%.2f",timesController.value];
    
}
//スライドボタンの状態を表示
- (IBAction)timesChanged:(id)sender {
    timesLabel.text = [NSString stringWithFormat:@"%.2f",timesController.value];
}
//値を送信する
- (IBAction)sendTimes:(id)sender {
    NSString *item = [NSString stringWithFormat:@"TIMES,%.2f",timesController.value];
    [self stringToUint8_t:item];
}


-(BOOL)writeData:(const void*)data_ length:(NSUInteger)len
{
    appDelegate.sentBytes +=len;
    BOOL ret = NO;
    NSInteger leftlen = len;
    if(leftlen <= 0) return YES;
    while(TRUE){
        NSStreamStatus stat = appDelegate.oStream.streamStatus;
        if(stat == NSStreamStatusOpen || stat == NSStreamStatusWriting){
            if([appDelegate.oStream hasSpaceAvailable]){
                // 書き出し可能
                NSInteger count = [appDelegate.oStream write:(data_ + (len - leftlen)) maxLength:leftlen];
                if(count >= 0){
                    leftlen -= count;
                    if(leftlen <= 0){
                        ret = YES;
                        break;
                    }
                }else{
                    NSLog(@"writeData error %@",appDelegate.oStream.streamError.description);
                    break;
                }
            }
        }else{
            NSLog(@"writeData error %u",stat);
            break; // エラー
        }
    }
    return ret;
}



-(void)stringToUint8_t:(NSString *)str
{
    const uint8_t * item =
    (uint8_t *) [str cStringUsingEncoding:NSASCIIStringEncoding];
    [self writeData:item length:strlen((char *)item)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [timesLabel release];
    [timesController release];
    [super dealloc];
}
- (void)viewDidUnload {
    [timesLabel release];
    timesLabel = nil;
    [timesController release];
    timesController = nil;
    [super viewDidUnload];
}
@end
