//
//  FileViewController.m
//  TableTopClient
//
//  Created by student on 14/11/20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "FileViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "ViewController.m"

@interface FileViewController ()<UITableViewDelegate, UITableViewDataSource,UITabBarControllerDelegate>

@end

@implementation FileViewController

AppDelegate *appDelegate;
static int numberOfSentImages = 0; 

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
    showFile.delegate = self;
    showFile.dataSource = self;
    appDelegate = [[UIApplication sharedApplication] delegate];
    UINib *nibfi = [UINib nibWithNibName:CustomTableViewCellForImageIdentifier bundle:nil];
    [showFile registerNib:nibfi forCellReuseIdentifier:CustomTableViewCellForImageIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:nibfi forCellReuseIdentifier:CustomTableViewCellForImageIdentifier];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
//選択した写真を送信
- (void)sendImage:(UIButton *)button event:(UIEvent*)event
{
    if(appDelegate.isUploadAvailable){
        //CustomTableViewCellForShowImage *cell = [tableView dequeueReusableCellWithIdentifier:CustomTableViewCellForImageIdentifier];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:showFile];
    NSIndexPath *indexPath = [showFile indexPathForRowAtPoint:point];
    int row = indexPath.row*4;
    switch(indexPath.section) {
        case 0: // 1個目のセクションの場合
        {
            UIImage* image = [[UIImage alloc] initWithCGImage:[[self.photoAssets[row+button.tag] defaultRepresentation] fullScreenImage]];
            //指定画像をリサイズ
            CGFloat rate;
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            NSString *imageSize = [NSString stringWithFormat:@"Image Size: %0.fx%0.f",width,height];
            if(height<=width){
                rate = 600 / width;
                if (rate < 1) {
                    width = 600; // リサイズ後幅のサイズ
                    height = rate * height;  // リサイズ後高さのサイズ
                }
            }
            else{
                rate = 600 / height;
                if (rate < 1) {
                    width = rate * width; // リサイズ後幅のサイズ
                    height = 600;  // リサイズ後高さのサイズ
                }
            }
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
            [image drawInRect:CGRectMake(0, 0, width, height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            NSData *data = UIImageJPEGRepresentation(image, 0.3);
            NSString * time = [FileViewController nowTime];
            NSString *number = [NSString stringWithFormat:@"%d",numberOfSentImages];
            [appDelegate.imageDataInfo addObject:image];     //IMAGE
            [appDelegate.imageDataInfo addObject:imageSize]; //IMAGEサイズをタイトルにする
            [appDelegate.imageDataInfo addObject:[NSString stringWithFormat:@"VISIBLE"]]; //IMAGE表示/非表示パラメータ
            [appDelegate.imageDataInfo addObject:time];  //IMAGEを送信した時刻を保存する
            [appDelegate.imageDataInfo addObject:number]; //何回目の送信を記録
            numberOfSentImages++;
            NSString *item = [NSString stringWithFormat:@"IMAGE,%@",number];
            [self stringToUint8_t:item];
            appDelegate.sentBytes += data.length;
            [self performSelector:@selector(send:) withObject:data afterDelay:0.05];
            break;
        }
        case 1: // 2個目のセクションの場合，選択した動画を送信
        {
            ALAssetRepresentation *rep = [self.videoAssets[row+button.tag] defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            NSString *number = [NSString stringWithFormat:@"%d",numberOfSentImages];
            NSString *item = [NSString stringWithFormat:@"VIDEO,%@,%d",number,data.length];
            numberOfSentImages++;
            [self stringToUint8_t:item];
            //NSLog(@"%d",data.length);
            [self performSelector:@selector(sendVideo:) withObject:data afterDelay:0.5];
            break;
        }
    }
    }
}
//送信用メソッド
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

//送信用関数
-(void) writeToServer:(const uint8_t *) buf {
    [appDelegate.oStream write:buf maxLength:strlen((char*)buf)];
}

-(void)stringToUint8_t:(NSString *)str
{
    const uint8_t * item =
    (uint8_t *) [str cStringUsingEncoding:NSASCIIStringEncoding];
    [self writeData:item length:strlen((char *)item)];
    
}

//遅延送信
-(void)send:(NSData *)data_
{
    [appDelegate.oStream write:[data_ bytes] maxLength:[data_ length]];
}
//動画を送信するメソッド
-(void)sendVideo:(NSData *)data_
{
    NSInteger leftlen = data_.length;
    NSInteger start =0;
    //NSInteger bufferSize = 1024*50;
    while (TRUE) {
        if([appDelegate.oStream hasSpaceAvailable]){
            // 書き出し可能
            
            NSInteger count = [appDelegate.oStream write:[[data_ subdataWithRange:NSMakeRange(start, leftlen-1)] bytes] maxLength:leftlen];
             
            if(count >= 0){
                leftlen -= count;
                start+=count;
                if(leftlen <= 0)
                    break;
            }
            NSLog(@"%d",leftlen);
            //[NSThread sleepForTimeInterval:0.2f];
        }
    }
    NSLog(@"%d",leftlen);
    [NSThread sleepForTimeInterval:0.2f];
    NSString *item = [NSString stringWithFormat:@"FINISH"];
    [self stringToUint8_t:item];
}
//アルバム選択画面に戻る
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//リストの行数を取得
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger dataCount = 0;
    if(section==0){
        if (self.photoAssets.count!=0) {
            dataCount = (self.photoAssets.count)/4;
            if(self.photoAssets.count% 4 != 0)
                dataCount +=1;
        }
    }
    else if(section ==1){
        if (self.videoAssets.count!=0) {
            dataCount = (self.videoAssets.count)/4;
            if(self.videoAssets.count% 4 != 0)
                dataCount +=1;
        }
    }
    return dataCount;
}
//セルの高さを取得
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCellForShowImage rowHeight];
}
//セルに情報をセットする
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 再利用できるセルがあれば再利用する
    CustomTableViewCellForShowImage *cell = [tableView dequeueReusableCellWithIdentifier:CustomTableViewCellForImageIdentifier];
    int row = indexPath.row *4;
    switch(indexPath.section) {
        case 0: // 1個目のセクションの場合，写真をセット
            [cell.image1 setImage:[[UIImage alloc] initWithCGImage:[self.photoAssets[row] thumbnail]]  forState:UIControlStateNormal];
            cell.label1.hidden = YES;
            if(self.photoAssets.count-indexPath.row * 4 >1){
                [cell.image2 setImage:[[UIImage alloc] initWithCGImage:[self.photoAssets[row+1] thumbnail]] forState:UIControlStateNormal];
                cell.label2.hidden = YES;
            }
            if(self.photoAssets.count-indexPath.row * 4>2){
                [cell.image3 setImage:[[UIImage alloc] initWithCGImage:[self.photoAssets[row+2] thumbnail]] forState:UIControlStateNormal];
                cell.label3.hidden = YES;
            }
            if(self.photoAssets.count-indexPath.row * 4>3)
            {
                [cell.image4 setImage:[[UIImage alloc] initWithCGImage:[self.photoAssets[row+3] thumbnail]] forState:UIControlStateNormal];
                cell.label4.hidden = YES;
            }
            [cell.image1 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image2 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image3 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image4 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            return cell;
            break;
        case 1: // 2個目のセクションの場合，動画をセット
            [cell.image1 setImage:[[UIImage alloc] initWithCGImage:[self.videoAssets[row] thumbnail]]  forState:UIControlStateNormal];
            CMTime t = [[[AVURLAsset alloc] initWithURL:[[self.videoAssets[row] defaultRepresentation] url] options:nil] duration];
            cell.label1.text = [self timeFormatted:(int32_t)t.value/t.timescale];
            cell.label1.hidden = NO;
            if(self.videoAssets.count-indexPath.row * 4 >1){
                [cell.image2 setImage:[[UIImage alloc] initWithCGImage:[self.videoAssets[row+1] thumbnail]] forState:UIControlStateNormal];
                CMTime t = [[[AVURLAsset alloc] initWithURL:[[self.videoAssets[row+1] defaultRepresentation] url] options:nil] duration];
                cell.label2.text = [self timeFormatted:(int32_t)t.value/t.timescale];
                cell.label2.hidden = NO;
            }
            if(self.videoAssets.count-indexPath.row * 4>2){
                [cell.image3 setImage:[[UIImage alloc] initWithCGImage:[self.videoAssets[row+2] thumbnail]] forState:UIControlStateNormal];
                CMTime t = [[[AVURLAsset alloc] initWithURL:[[self.videoAssets[row+2] defaultRepresentation] url] options:nil] duration];
                cell.label3.text = [self timeFormatted:(int32_t)t.value/t.timescale];
                cell.label3.hidden = NO;
            }
            if(self.videoAssets.count-indexPath.row * 4>3)
            {
                [cell.image4 setImage:[[UIImage alloc] initWithCGImage:[self.videoAssets[row+3] thumbnail]] forState:UIControlStateNormal];
                CMTime t = [[[AVURLAsset alloc] initWithURL:[[self.videoAssets[row+3] defaultRepresentation] url] options:nil] duration];
                cell.label4.text = [self timeFormatted:(int32_t)t.value/t.timescale];
                cell.label4.hidden = NO;
            }
            [cell.image1 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image2 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image3 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            [cell.image4 addTarget:self action:@selector(sendImage:event:)
                  forControlEvents:UIControlEventTouchUpInside];
            return cell;
            break;
    }
    return cell;
}
//セクションのタイトルを設定
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0: // 1個目のセクションの場合
            return @"Photo";
            break;
        case 1: // 2個目のセクションの場合
            return @"Video";
            break;
    }
    return nil; //ビルド警告回避用 //ビルド警告回避用
}
//セクション数を取得
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//動画の長さ（時間）の表示方
- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    //int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

//現在時刻を取得
+(NSString *)nowTime
{
    NSDate *now = [NSDate date];
    
    // NsDate→NSString変換用のフォーマッタを作成
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    // 日付から文字列に変換
    NSString *strNow = [outputFormatter stringFromDate:now];
    // フォーマットを解放
    [outputFormatter release];
    return strNow;
}

- (void)dealloc {
    [showFile release];
    [super dealloc];
}
- (void)viewDidUnload {
    [showFile release];
    showFile = nil;
    [super viewDidUnload];
}
@end
