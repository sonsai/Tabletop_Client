//
//  ConnectionViewController.m
//  TableTopClient
//
//  Created by student on 14/11/26.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "ConnectionViewController.h"


@interface ConnectionViewController ()

@end

@implementation ConnectionViewController
@synthesize singleTap;
//接続のtimeoutを計る
//dispatch_semaphore_t _semaphore;
//接続状態を保つ Connected=YES;Disconnected=NO;
BOOL didConnect;
//接続後に名前を送信したかどうかをチェックするFlag
BOOL didSendName;

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
    //空きスペイスでタッブすると開いているキーボードを閉じる
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = (id)self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    //接続の情報を初期化
    ipAddress.text = @"192.168.1.29";
    portNo.text =@"2222";
    userName.text = @"SUN SAI";
    markerNo.text = @"1";
    appDelegate = [[UIApplication sharedApplication] delegate];
    

}

//サーバに接続用関数
-(void)connectToServerUsingCFStream:(NSString *) urlStr portNo: (uint) pNo {
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                       (CFStringRef) urlStr,
                                       pNo,
                                       &readStream,
                                       &writeStream);
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyShouldCloseNativeSocket,
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream,
                                 kCFStreamPropertyShouldCloseNativeSocket,
                                 kCFBooleanTrue);
        
        appDelegate.iStream = (NSInputStream *)readStream;
        [appDelegate.iStream retain];
        [appDelegate.iStream setDelegate:self];
        [appDelegate.iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [appDelegate.iStream open];
        
        appDelegate.oStream = (NSOutputStream *)writeStream;
        [appDelegate.oStream retain];
        [appDelegate.oStream setDelegate:self];
        [appDelegate.oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
        [appDelegate.oStream open];
        
    }
}

//接続ボタンイベント
- (IBAction)pressConnectionButton:(id)sende{
    if (!didConnect) {
        [self connectToServerUsingCFStream:ipAddress.text portNo:portNo.text.integerValue];
    }else{
        [self disconnect];
        [self settingForDisconnection];
    }
}

- (IBAction)goToMain:(id)sender {
    [self performSegueWithIdentifier:@"ToMain" sender:nil];
}

//接続を切る関数
- (void)disconnect{
    appDelegate.imageDataInfo = [NSMutableArray new];
    appDelegate.selectImage = [NSMutableArray new];
    appDelegate.iStream.delegate = nil;
    [appDelegate.iStream close];
    [appDelegate.iStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    appDelegate.iStream = nil;
    appDelegate.oStream.delegate = nil;
    [appDelegate.oStream close];
    [appDelegate.oStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    appDelegate.oStream = nil;
}

//IPADDRESS入力補助
- (void)inputIPAddress:(id)sender{
    ipAddress.text = @"192.168.1.23";
    portNo.text =@"2222";
    userName.text = @"SUN SAI";
}

//接続状態を検出
-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    
    NSString *event;
    switch (streamEvent)
    {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            status.text =  @"Connection failed";
            
            [self disconnect];
            [self settingForDisconnection];
            break;
            
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            status.text = @"Connected";
            appDelegate.ipAddress_ = ipAddress.text;
            appDelegate.portNo_ = portNo.text;
            appDelegate.userName_ = userName.text;
            [self settingForConnection];
            break;
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            status.text = @"Connection failed";
            [self disconnect];
            [self settingForDisconnection];
            break;
            
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
            status.text = @"Connection closed";
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"Connection closed" message:nil
                                      delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [self disconnect];
            [self settingForDisconnection];
            break;
        case NSStreamEventHasBytesAvailable:
            //利用可能のデータがあるときに受信を行う
            if(theStream == appDelegate.iStream&&[appDelegate.iStream hasBytesAvailable])
            {
                Byte buf[256];
                unsigned int len = 0;
                len = [appDelegate.iStream read:buf maxLength:256];
                if(len > 0) {
                    NSMutableData* rdata = [NSMutableData alloc];
                    
                    [rdata appendBytes:buf length:len];
                    //受信したデータを文字列に変換し，”，”で区切ったデータを配列に入れる
                    NSString *s = [[NSString alloc] initWithData:rdata encoding:NSASCIIStringEncoding];
                    NSArray *array = [s componentsSeparatedByString:@","];
                    //ファイルの送信を可能にする
                    if([array[0] isEqual:@"Upload is available"]){
                        appDelegate.isUploadAvailable = YES;
                        [self isUploadAvailable];
                    }
                    //ファイルの送信を不可にする
                    else if([array[0] isEqual:@"Upload is not available"]){
                        appDelegate.isUploadAvailable =NO;
                        [self isUploadAvailable];
                    }
                    //画像ファイルを受信する
                    if([array[0] isEqualToString:@"IMAGE"])
                    {
                        recievedData = [[NSMutableData alloc] initWithLength:0];
                        
                        if ([self readData:recievedData length:[array[1] integerValue]]) {
                            UIImage *img = [[UIImage alloc] initWithData:recievedData];
                            NSString *imageSize = [NSString stringWithFormat:@"Image Size: %0.fx%0.f",img.size.width,img.size.height];
                            NSString * time = [FileViewController nowTime];
                            //受信した画像ファイルのサイズと受信した時刻を記録
                            [appDelegate.recievedImage addObject:img];
                            [appDelegate.recievedImage addObject:imageSize];
                            [appDelegate.recievedImage addObject:time];
                        }
                    }
                    //名前が重複した場合，サーバは名前を変更する
                    else if([array[0] isEqualToString:@"NAMECHANGED"])
                    {
                        appDelegate.userName_ = array[1];
                        userName.text = appDelegate.userName_;
                    }
                    //卓上に端末が置かれてない場合，送信したファイルの情報をリストから作条する
                    else if([array[0] isEqualToString:@"REMOVELIST"])
                    {
                        appDelegate.imageDataInfo = [NSMutableArray new];
                    }
                    
                    [rdata release];
                }
            }
        case NSStreamEventHasSpaceAvailable:
            //ユーザ名を送信する
            [self setSentBytes];
            if(theStream == appDelegate.oStream) {
                if(!didSendName){
                    NSString *marker = markerNo.text;
                    NSString *item = [NSString stringWithFormat:@"USERNAME,%@,%@",appDelegate.userName_,marker];
                    [self stringToUint8_t:item];
                    didSendName = YES;
                    NSLog(@"%@",appDelegate.userName_);
                }
            }
            break;
            
        default:
            event = @"** Unknown";
            break;
    }
}

-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        
    }
    
}




//接続時のパラメーターやボタンなどのUI状態を設定
-(void)settingForConnection{
    didConnect = YES;
    [conOrCan setTitle:@"Disconnect" forState:UIControlStateNormal];
    status.textColor = [UIColor blueColor];
    status.text = @"Connected";
    ipAddress.text = appDelegate.ipAddress_;
    ipAddress.enabled = FALSE;
    ipAddress.textColor = [UIColor grayColor];
    portNo.text = appDelegate.portNo_;
    portNo.enabled = FALSE;
    portNo.textColor = [UIColor grayColor];
    userName.text = appDelegate.userName_;
    userName.enabled = FALSE;
    userName.textColor = [UIColor grayColor];
    markerNo.enabled = FALSE;
    markerNo.textColor = [UIColor grayColor];
    goToMain.hidden = NO;
    goToMain.enabled = YES;
    userName.text = appDelegate.userName_;
    [self setSentBytes];
    [self isUploadAvailable];
}

//無接続時のパラメーターやボタンなどのUI状態を設定
-(void)settingForDisconnection{
    didConnect = NO;
    [conOrCan setTitle:@"Connect" forState:UIControlStateNormal];
    status.textColor = [UIColor redColor];
    status.text = @"Disconnected";
    ipAddress.enabled = TRUE;
    ipAddress.textColor = [UIColor blueColor];
    portNo.enabled = TRUE;
    portNo.textColor = [UIColor blueColor];
    userName.enabled = TRUE;
    userName.textColor = [UIColor blueColor];
    goToMain.hidden = YES;
    goToMain.enabled = NO;
    markerNo.enabled = TRUE;
    markerNo.textColor = [UIColor blueColor];
    [appDelegate._motionManager stopAccelerometerUpdates];
    appDelegate.recievedBytes = 0;
    appDelegate.sentBytes = 0;
    appDelegate.isUploadAvailable = NO;
    didSendName = NO;
    [self setSentBytes];
    [self isUploadAvailable];
}
//送信したバイト数を記録
-(void)setSentBytes
{
    NSString *sentText;
    if(appDelegate.sentBytes>1024){
        sentText = [NSString stringWithFormat:@"%d KB",appDelegate.sentBytes/1024];
    }else
    {
        sentText = [NSString stringWithFormat:@"%d B",appDelegate.sentBytes];
    }
    sent.text = sentText;
}

//シングルタップされたらresignFirstResponderでキーボードを閉じる
-(void)onSingleTap:(UITapGestureRecognizer *)recognizer{
    [portNo resignFirstResponder];
    [ipAddress resignFirstResponder];
}

//キーボードを表示していない時は、他のジェスチャに影響を与えないように無効化しておく。
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.singleTap) {
        // キーボード表示中のみ有効
        if (portNo.isFirstResponder) {
            return YES;
        }
        else if (ipAddress.isFirstResponder) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}
//送信可能か不可能の表示を切り替える
-(void)isUploadAvailable
{
    if(appDelegate.isUploadAvailable){
        upload.textColor = [UIColor blueColor];
        upload.text = @"Available";
    }
    else{
        upload.textColor = [UIColor redColor];
        upload.text = @"Unavailable";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//画像フィアル受信用に使うメソッド
- (BOOL)readData:(NSMutableData*)data_ length:(NSUInteger)len
{
    BOOL ret = NO;
    NSInteger leftlen = len;
    if(leftlen <= 0) return YES;
        while(TRUE){
        NSStreamStatus stat = appDelegate.iStream.streamStatus;
            if(stat == NSStreamStatusOpen || stat == NSStreamStatusReading){
            
            if([appDelegate.iStream hasBytesAvailable]){
                // 読み込み可能
                Byte buf[10240];
                
                NSInteger maxlen = (sizeof(buf) / sizeof(Byte)); // バッファサイズ
                if(maxlen > leftlen) maxlen = leftlen;
                
                NSInteger count = [appDelegate.iStream read:buf maxLength:maxlen];
                
                if(count > 0){
                    [data_ appendBytes:buf length:count];
                    leftlen -= count;
                    if(leftlen <= 0){
                        // 指定バイト読み込めたので終了
                        ret = YES;
                        break;
                    }
                }else{
                    if(count == 0){
                        NSLog(@"readData eof");
                    }else{
                        NSLog(@"readData error %@",appDelegate.iStream.streamError.description);
                    }
                    break;
                }
           }
        }else{
            NSLog(@"readData error %u",stat);
            break; // エラー
        }
    }
    
    return ret;
}

//データを送信する
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

//送信用関数
-(void)stringToUint8_t:(NSString *)str
{
    const uint8_t * item =
    (uint8_t *) [str cStringUsingEncoding:NSASCIIStringEncoding];
    [self writeData:item length:strlen((char *)item)];
    
}


//メモリ釈放
- (void)dealloc {
    [status release];
    [sent release];
    [received release];
    
    [appDelegate.iStream release];
    [appDelegate.oStream release];
    
    if (readStream) CFRelease(readStream);
    if (writeStream) CFRelease(writeStream);
    [goToMain release];
    [userName release];
    [markerNo release];
    [super dealloc];
}

- (void)viewDidUnload {
    [status release];
    status = nil;
    [sent release];
    sent = nil;
    [received release];
    received = nil;
    [goToMain release];
    goToMain = nil;
    [userName release];
    userName = nil;
    [upload release];
    upload = nil;
    [markerNo release];
    markerNo = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    if(didConnect)
       [self settingForConnection];
    else
        [self settingForDisconnection];
    [super viewWillAppear:animated];
}


@end
