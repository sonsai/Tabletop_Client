//
//  ModalViewController.m
//  TableTopClient
//
//  Created by student on 14/12/04.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "ModalViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ModalViewController ()

@end

@implementation ModalViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backToRecievedList:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)saveImageToAlbum:(id)sender {
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
}

// 完了を知らせる
- (void) savingImageIsFinished:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo
{
    if(_error){//エラーのとき
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                        message:@"Save failed"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil
                              ];
        
        [alert show];
        [alert release];
        
    }else{//保存できたとき
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Message" message:@"Image Saved"
                                  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    scrollView = [[UIScrollView alloc]init];
    
    scrollView.bounces = NO;
    CGRect rect = CGRectMake(0, 0, 320, (self._image.size.height/self._image.size.width)*320);
    imageView.frame = rect;
    imageView.image = self._image;
    
    imageSize.center = CGPointMake(110, 15+imageView.frame.size.height);
    imageSize.text = self._imageSize;
    recievedTime.center = CGPointMake(110, 46+imageView.frame.size.height);
    recievedTime.text = self._recievedTime;
    sender.center = CGPointMake(110, 77+imageView.frame.size.height);
    sender.text = self._sender;
    
    CGRect frame = CGRectMake(0, 50, 320, 410);
    CGRect contentSize = CGRectMake(0, 0, 320, 108+imageView.frame.size.height);
    scrollView.frame = frame;
    scrollView.contentSize = contentSize.size;
    [scrollView addSubview:imageView];
    [scrollView addSubview:imageSize];
    [scrollView addSubview:recievedTime];
    // UIScrollViewのインスタンスをビューに追加
    [self.view addSubview:scrollView];
    
    // 表示されたときスクロールバーを点滅
    [scrollView flashScrollIndicators];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (void)dealloc {
    [imageView release];
    [imageSize release];
    [recievedTime release];
    [sender release];
    [scrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [imageView release];
    imageView = nil;
    [imageSize release];
    imageSize = nil;
    [recievedTime release];
    recievedTime = nil;
    [sender release];
    sender = nil;
    [scrollView release];
    scrollView = nil;
    [super viewDidUnload];
}
@end
