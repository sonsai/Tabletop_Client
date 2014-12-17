//
//  SentViewController.m
//  TableTopClient
//
//  Created by student on 14/10/13.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "SentViewController.h"

@interface SentViewController ()<UITableViewDelegate, UITableViewDataSource,UITabBarControllerDelegate>

@end

@implementation SentViewController
@synthesize tableView;
@synthesize openedIndexPath;

AppDelegate *appDelegate;

//ImageInfo配列の中にimageData,imageTitle,visible,sendtime,idが入っている
//image=row,title=row+1,visible=row+2,time=row+3,id=row+4
static int const numberOfImageInfo = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    assetsAccessor = [[AssetsAccessor alloc] initWithDelegate:self];
    appDelegate = [[UIApplication sharedApplication] delegate];
    self.tabBarController.delegate = self;
    // テーブルに表示したいデータソースをセット
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //加速度センサー起動
    [self startAccelerometer];
    
        
    //swipeジェスチャを登録
    UISwipeGestureRecognizer* swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.tableView addGestureRecognizer:swipeGesture];
    
    [swipeGesture release];
    
    swipeGesture =
    [[UISwipeGestureRecognizer alloc]
     initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:swipeGesture];
    [swipeGesture release];
    
    // カスタマイズしたセルをテーブルビューにセット
    UINib *nib = [UINib nibWithNibName:CustomTableViewCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CustomTableViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:CustomTableViewCellIdentifier];
    
    
    
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//////////////////////////////////////////
//送受信関連
//
//
//
//////////////////////////////////////////

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

//HIDDEN/NOTHIDDEN情報送信
-(void)sendVisible:(CustomTableViewCell *)cell{
    
    NSIndexPath * indexpath = [self.tableView indexPathForCell:cell];
    int row = indexpath.row * numberOfImageInfo;
    NSString *visible;
    if([appDelegate.imageDataInfo objectAtIndex:row+2]==@"VISIBLE")
        visible = @"YES";
    else
        visible = @"NO";
    
    NSString *item = [NSString stringWithFormat:@"VISIBLE,%@,%@",[appDelegate.imageDataInfo objectAtIndex:row+4],visible];
    [self stringToUint8_t:item];
}
//ファイルが選択されたかどうかの情報を送信
-(void)sendDidSelect:(CustomTableViewCell *)cell{
    NSIndexPath * indexpath = [self.tableView indexPathForCell:cell];
    int row = indexpath.row * numberOfImageInfo;
    NSString *didSelect;
    if(cell.IsSelected_)
        didSelect = @"YES";
    else
        didSelect = @"NO";
    NSString *item = [NSString stringWithFormat:@"SELECT,%@,%@",[appDelegate.imageDataInfo objectAtIndex:row+4],didSelect];
    [self stringToUint8_t:item];
}

//ジャイロセンサーによりファイルの移動や回転情報を送信
-(void)controlSelected:(float)angle:(float)x:(float)y
{
    //int row = appDelegate.selectedCell.row * numberOfImageInfo;
    NSString *item = [NSString stringWithFormat:@"MOVE,%f,%f,%f,",angle,x,y];
    [self stringToUint8_t:item];
}

//////////////////////////////////////////
//リストの表示及びリストに対する操作関連
//
//
//
//////////////////////////////////////////
//swipeしたら，方向によってセルの開け閉めを行う
- (void)didSwipeCell:(UISwipeGestureRecognizer*)swipeRecognizer
{
    CGPoint loc = [swipeRecognizer locationInView:self.tableView];
    NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:loc];
    CustomTableViewCell* cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    int row = indexPath.row*numberOfImageInfo;
    
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            // close cell
        if(cell.slideOpened_ == YES){
            [appDelegate.imageDataInfo replaceObjectAtIndex:row+2 withObject:@"VISIBLE"];
            cell.slideOpened_ =NO;
            [self sendVisible:cell];
            
        }
    } else if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if(cell.slideOpened_ == NO){
            // open new cell
            if(appDelegate.selectedCell.row == indexPath.row)
                appDelegate.selectedCell = NULL;
            [appDelegate.imageDataInfo replaceObjectAtIndex:row+2 withObject:@"INVISIBLE"];
            cell.slideOpened_ = YES;
            cell.IsSelected_ = NO;
            [self sendVisible:cell];
        }

    }
    [self.tableView reloadData];
    
}

//リストの行数を取得
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger dataCount = appDelegate.imageDataInfo.count / numberOfImageInfo;
    return dataCount;

}
//リストのセルの高さを取得
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}
//セルの情報をセット
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    //static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CustomTableViewCellIdentifier];
    int row = indexPath.row * numberOfImageInfo;

    switch (indexPath.section) {
        case 0:
            cell.imageInList.image = [appDelegate.imageDataInfo objectAtIndex:row];            
            cell.titleInList.text = [appDelegate.imageDataInfo objectAtIndex:row+1];
            cell.idInList.text =[appDelegate.imageDataInfo objectAtIndex:row+3];
            if([[appDelegate.imageDataInfo objectAtIndex:row+2] isEqualToString:@"VISIBLE"]){
                cell.slideOpened_ = NO;
            }
            else{
                cell.slideOpened_ = YES;
                cell.IsSelected_ = NO;
            }
            [cell setSlideOpened];
            break;
        default:
            break;
    }
    // タッチイベントを追加
    [cell.cellDelete addTarget:self action:@selector(listDelete:event:)
            forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil; //ビルド警告回避用
}
//セルを選択するときの処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell* cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    int row = indexPath.row * numberOfImageInfo;
    if(cell.IsSelected_)
    {
        cell.IsSelected_=NO;
        [appDelegate._motionManager stopDeviceMotionUpdates];
        appDelegate.selectedCell = NULL;
        [self sendDidSelect:cell];
    }
    else if(cell.slideOpened_)
    {
        [appDelegate.imageDataInfo replaceObjectAtIndex:row+2 withObject:@"VISIBLE"];
        [self sendVisible:cell];
        cell.slideOpened_ = NO;
        cell.IsSelected_ = YES;
        [self attiude];
        appDelegate.yaw=181;
        [self sendDidSelect:cell];
        if(appDelegate.selectedCell!=NULL)
        {
            cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:appDelegate.selectedCell];
            cell.IsSelected_ = NO;
        }
        appDelegate.selectedCell = indexPath;
    }
    else{
        cell.IsSelected_=YES;
        [self attiude];
        appDelegate.yaw=181;
        [self sendDidSelect:cell];
        if (appDelegate.selectedCell!=NULL) {
            cell = (CustomTableViewCell*)[self.tableView cellForRowAtIndexPath:appDelegate.selectedCell];
            cell.IsSelected_ = NO;
        }        
        appDelegate.selectedCell = indexPath;
        
    }
    
    [self.tableView reloadData];
    
}
- (NSIndexPath*)_indexPathForEvent:(UIEvent*)event
{
    UITouch* touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:p];
}

//テーブルに表示するセクション（区切り）の件数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//セルを削除する
- (IBAction)listDelete:(id)sender event:(UIEvent*)event 
{
    
    NSIndexPath* indexPath = [self _indexPathForEvent:event];
    int row = indexPath.row*numberOfImageInfo;
    if(indexPath.section==0)
    {
        //FLAGと番号を送信
        NSString *item = [NSString stringWithFormat:@"DELETE,%@",[appDelegate.imageDataInfo objectAtIndex:row+4]];
        [self stringToUint8_t:item];
    }
    switch (indexPath.section) {
        case 0:
            for (int i= 0; i<numberOfImageInfo; i++) {
                [appDelegate.imageDataInfo removeObjectAtIndex:row];
            }
            break;
        default:
            break;
    }
    if(appDelegate.imageDataInfo.count!=0)
        self.tableView.userInteractionEnabled = YES;
    else{
        self.tableView.userInteractionEnabled =NO;
    }
    [self.tableView reloadData];
}

//////////////////////////////////////////
//センサ関係
//
//
//
//////////////////////////////////////////

//加速度センサー処理
-(void)startAccelerometer
{
    if (appDelegate._motionManager.accelerometerAvailable)
    {
        // センサーの更新間隔の指定
       appDelegate._motionManager.accelerometerUpdateInterval = 0.4f;  // 10Hz
        
        // ハンドラを指定
        [appDelegate._motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *data, NSError *error)
        {
            //NSLog(@"%d",[oStream streamStatus]);
            appDelegate.status = NO;
            if([SentViewController check:0.00f acc:data.acceleration.x]&&[SentViewController check:0.00 acc:data.acceleration.y]&&[SentViewController check:-1.00 acc:data.acceleration.z]&&appDelegate.imageDataInfo.count!=0)
            {
                
                
                appDelegate.status = YES;
                if(appDelegate.accFlag==1){
                    appDelegate.accFlag = 0;
                    
                    NSString *item = [NSString stringWithFormat:@"VISIBLE,YES"];
                    [self stringToUint8_t:item];
                    
                    for (int i = 2; i<appDelegate.imageDataInfo.count; i+=numberOfImageInfo) {
                        [appDelegate.imageDataInfo replaceObjectAtIndex:i withObject:@"VISIBLE"];
                    }
                }
                [self.tableView reloadData];
                
                
                
            }
            if([SentViewController check:0.00f acc:data.acceleration.x]&&[SentViewController check:0.00 acc:data.acceleration.y]&&[SentViewController check:1.00 acc:data.acceleration.z]&&appDelegate.imageDataInfo.count!=0)
            {
                
                if(appDelegate.accFlag==0){
                    appDelegate.accFlag = 1;
                    
                    NSString *item = [NSString stringWithFormat:@"VISIBLE,NO"];
                    [self stringToUint8_t:item];
                    for (int i = 2; i<appDelegate.imageDataInfo.count; i+=numberOfImageInfo) {
                        [appDelegate.imageDataInfo replaceObjectAtIndex:i withObject:@"INVISIBLE"];
                    }
                    
                }
            [self.tableView reloadData];
            }
            
            
        }];
    }

}
+(BOOL)check:(float)num acc:(float) acc
{
    if(acc < num+0.02 && acc> num-0.02)
        return YES;
    else
        return NO;
}
//ジャイロセンサ処理
- (void)attiude
{
    if (appDelegate._motionManager.deviceMotionAvailable) {
        
        //__weak MasterViewController *viewController = self;
        appDelegate._motionManager.deviceMotionUpdateInterval = 1/10;
        // 向きの更新通知を開始する
        [appDelegate._motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error)
         {
             bool flag = NO;//状態が変わらなかったら，送信しない
             float change = 0.0;
             float x = 0.0;
             float y = 0.0;
             
             
             float pitch = motion.attitude.pitch * 180 / M_PI;
             float roll = motion.attitude.roll * 180 / M_PI;
             if(pitch > 20||pitch < -20)
             {
                 y = pitch;
                 flag = YES;
             }
             if(roll > 20||roll < -20)
             {
                 x = roll;
                 flag = YES;
             }
             if(appDelegate.yaw==181){
                 appDelegate.yaw = motion.attitude.yaw * 180 / M_PI;
             }
             else{
                 float changed = motion.attitude.yaw * 180 / M_PI - appDelegate.yaw;
                 if(changed<180&&changed>-180&&(changed<-0.3||changed>0.3)&&appDelegate.status)
                 {
                     change = changed;
                     flag = YES;
                     //NSLog(@"%f",motion.attitude.yaw * 180/ M_PI);
                 }
                 appDelegate.yaw = motion.attitude.yaw * 180 / M_PI;
             }
             if(flag)
                 [self controlSelected:change:x:y];
         }];
    }
}
//////////////////////////////////////////
//その他
//
//
//
//////////////////////////////////////////

//メモリ釈放
- (void)dealloc {
    [self.tableView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

//画面が切り替わるとき，接続状態によるボタンの状態変更
- (void)viewWillAppear:(BOOL)animated{
    NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
    if(selection){
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

@end
