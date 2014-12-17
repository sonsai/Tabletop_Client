//
//  CustomTableViewCellForShowImage.h
//  TableTopClient
//
//  Created by student on 14/11/09.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCellForShowImage : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *image1;
@property (retain, nonatomic) IBOutlet UIButton *image2;
@property (retain, nonatomic) IBOutlet UIButton *image3;
@property (retain, nonatomic) IBOutlet UIButton *image4;
@property (retain, nonatomic) IBOutlet UILabel *label2;
@property (retain, nonatomic) IBOutlet UILabel *label1;
@property (retain, nonatomic) IBOutlet UILabel *label3;
@property (retain, nonatomic) IBOutlet UILabel *label4;

+(CGFloat)rowHeight;
@end
