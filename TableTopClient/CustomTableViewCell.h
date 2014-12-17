//
//  CustomTableViewCell.h
//  TableTopClient
//
//  Created by student on 14/10/18.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaseView,SlideView;
@interface CustomTableViewCell : UITableViewCell{
}

@property (nonatomic, retain) IBOutlet BaseView* baseView;
@property (nonatomic, retain) IBOutlet SlideView* slideView;

@property (retain, nonatomic) IBOutlet UILabel *titleInList;
@property (retain, nonatomic) IBOutlet UIImageView *imageInList;
@property (retain, nonatomic) IBOutlet UILabel *idInList;
@property (retain, nonatomic) IBOutlet UIButton *cellDelete;
@property  BOOL slideOpened_;
@property  BOOL IsSelected_;


+(CGFloat)rowHeight;

-(void)setSlideOpened;




@end
