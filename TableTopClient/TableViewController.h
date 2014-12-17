//
//  TableViewController.h
// 
//
// 
//
//

#import <UIKit/UIKit.h>
#import "AssetsAccessor.h"
#import "SentViewController.h"
//写真選択時のプロトコル
@protocol MyImagePickerControllerDelegate <NSObject>
@optional
- (void)didFinishPickingAsset:(ALAsset *)asset;
@end

@interface TableViewController : UIViewController <AssetsAccessorDelegate, UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource, MyImagePickerControllerDelegate> {
    //写真を取得時に使う
    AssetsAccessor *assetsAccessor;
    NSArray * photoAssets;
    NSArray * videoAssets;
}

@property (nonatomic, retain) id parent;
@property (nonatomic, retain) NSArray *groups;
@property (retain,  nonatomic) IBOutlet UITableView *tableView;

@end
