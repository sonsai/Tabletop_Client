//
//  RecievedViewController.m
//  TableTopClient
//
//  Created by student on 14/11/21.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "RecievedViewController.h"
#import "ModalViewController.h"

@interface RecievedViewController ()<UITableViewDelegate, UITableViewDataSource,UITabBarControllerDelegate>

@end

@implementation RecievedViewController

AppDelegate *appDelegate;

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
    recievedImage.delegate = self;
    recievedImage.dataSource = self;
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    UINib *nib = [UINib nibWithNibName:CustomTableViewCellIdentifier bundle:nil];
    [recievedImage registerNib:nib forCellReuseIdentifier:CustomTableViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:CustomTableViewCellIdentifier];
    [recievedImage reloadData];
    //[self performSelectorInBackground:@selector(tableReload) withObject:nil];
    //[self performSelector:@selector(tableReload)];
	// Do any additional setup after loading the view.
}
//リストの行数を取得
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger dataCount = appDelegate.recievedImage.count / 3;
    //NSLog(@"%d",dataCount);
    return dataCount;    
}
//リストに情報をセット
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomTableViewCellIdentifier];
    int row = indexPath.row * 3;
    cell.imageInList.image = [appDelegate.recievedImage objectAtIndex:row];
    cell.titleInList.text = [appDelegate.recievedImage objectAtIndex:row+1];
    cell.idInList.text =[appDelegate.recievedImage objectAtIndex:row+2];

    // タッチイベントを追加
    //[cell.cellDelete addTarget:self action:@selector(listDelete:event:)
              //forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
//リストのセクション数を取得
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil; //ビルド警告回避用
}

//次の画面にsegueでデータを渡す
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowImage"]) {
        ModalViewController *mvc = [segue destinationViewController];
        mvc._image = [appDelegate.recievedImage objectAtIndex:(int)sender];
        mvc._imageSize = [appDelegate.recievedImage objectAtIndex:(int)sender+1];
        mvc._recievedTime = [appDelegate.recievedImage objectAtIndex:(int)sender+2];
        //mvc.sender = [appDelegate.recievedImage objectAtIndex:(int)sender+3];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row * 3;
    
    [self performSegueWithIdentifier:@"ShowImage"sender:(id)row];
}
//セルの高さを取得
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CustomTableViewCell rowHeight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [recievedImage release];
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    [recievedImage reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [recievedImage release];
    recievedImage = nil;
    [super viewDidUnload];
}
@end
