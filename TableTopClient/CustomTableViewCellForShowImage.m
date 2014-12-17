//
//  CustomTableViewCellForShowImage.m
//  TableTopClient
//
//  Created by student on 14/11/09.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomTableViewCellForShowImage.h"

@implementation CustomTableViewCellForShowImage
@synthesize image1;
@synthesize image2;
@synthesize image3;
@synthesize image4;
@synthesize label1 = _label1;
@synthesize label2 = _label2;
@synthesize label3 = _label3;
@synthesize label4 = _label4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}

+(CGFloat)rowHeight
{
    return 80.0f;
}

- (void)dealloc {
    [_label1 release];
    [_label2 release];
    [_label3 release];
    [_label4 release];
    [super dealloc];
}
@end
