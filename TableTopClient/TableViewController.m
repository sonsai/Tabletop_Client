//
//  TableViewController.m
//  AssetsAccessorDemo
//
//  Created by 森川慎太郎 on 2013/09/19.
//
//

#import "TableViewController.h"
//#import "FileViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.groups.count==1 && [self.groups[0] numberOfAssets]==0) {
        [[[UIAlertView alloc] initWithTitle:@"No Photo" message:@"Please add some photos to this device." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
    self.tableView.dataSource=self;
    self.tableView.delegate = self;
    
    assetsAccessor = [[AssetsAccessor alloc] initWithDelegate:self];
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [assetsAccessor getAssetsGroupsWithTypes:ALAssetsGroupAll];
    [super viewWillAppear:animated];
}

- (void)assetsGroupsDidLoad:(NSArray *)groups{
    self.groups = groups;
    self.parent = nil;
    [self.tableView reloadData];
}

//UIAlertViewDelegateメソッド
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//次の画面にsegueでデータを渡す
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ToAlbumView"]) {
        FileViewController *fileViewController = [segue destinationViewController];
        //fileViewController.delegate = self.parent;
        fileViewController.photoAssets = self->photoAssets;
        fileViewController.videoAssets = self->videoAssets;
    }
}


//リストのセクション数を取得
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//リストの行数を取得
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}


//セルに情報をセット
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"assetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.imageView.image = [UIImage imageWithCGImage:[self.groups[indexPath.row] posterImage]];
    cell.textLabel.text = [self.groups[indexPath.row] valueForProperty:ALAssetsGroupPropertyName];

    return cell;
    
    
}
//セルの高さをセット
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

//選択したアルバムの情報をdelegateに送信
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [assetsAccessor getAssetsFromGroup:self.groups[indexPath.row] withFilter:[ALAssetsFilter allAssets]];
}

//AssetsAccessorDelegateメソッド
- (void)assetsDidLoadByGroup:(NSArray *)photoAssets_ Video:(NSArray *)videoAssets_{   
    self->photoAssets = photoAssets_;
    self->videoAssets = videoAssets_;
    [self performSegueWithIdentifier:@"ToAlbumView" sender:photoAssets_];
}

@end
