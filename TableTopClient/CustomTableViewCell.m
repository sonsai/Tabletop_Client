//
//  CustomTableViewCell.m
//  TableTopClient
//
//  Created by student on 14/10/18.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "SentViewController.h"

@interface SlideView : UIView {
}
@end

@implementation SlideView


#define CUSTOMCELL_OBJECT_LENGTH    10.0
#define CUSTOMCELL_SHADOW_OFFSET    5.0
#define CUSTOMCELL_SHADOW_BLUR      5.0

- (void)drawRect:(CGRect)rect
{
    // draw edge shadow
    // NSLog(@"-[SlideView drawRect:] %@", NSStringFromCGRect(rect));
    CGRect frame = self.bounds;
    frame.origin.x -= CUSTOMCELL_OBJECT_LENGTH;
    frame.origin.y -= CUSTOMCELL_OBJECT_LENGTH;
    frame.size.width += CUSTOMCELL_OBJECT_LENGTH;
    frame.size.height = CUSTOMCELL_OBJECT_LENGTH;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShadow(context,CGSizeMake(CUSTOMCELL_SHADOW_OFFSET, CUSTOMCELL_SHADOW_OFFSET), CUSTOMCELL_SHADOW_BLUR);
    
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, frame);
    
}

@end;

@interface BaseView : UIView {
}
@property (nonatomic, assign) BOOL selected;
@end


@implementation BaseView
@synthesize selected;

- (void)drawRect:(CGRect)rect
{
    // draw
    // NSLog(@"-[BaseView drawRect:] %@", NSStringFromCGRect(rect));
    
    if (selected) {
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = { 0.9f, 0.9f, 0.9f, 0.9f,
            0.7f, 0.7f, 0.7f, 0.7f };
        
        
        size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
        
        
        CGContextAddRect(context, self.frame);
        
        CGRect frame = self.bounds;
        CGPoint startPoint = frame.origin;
        CGPoint endPoint = frame.origin;
        endPoint.y = frame.origin.y + frame.size.height;
        
        CGGradientRef gradientRef =
        CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
        
        CGContextDrawLinearGradient(context,
                                    gradientRef,
                                    startPoint,
                                    endPoint,
                                    kCGGradientDrawsAfterEndLocation);
        
        
        
        CGGradientRelease(gradientRef);
        CGColorSpaceRelease(colorSpaceRef);
    }
}
@end

@implementation CustomTableViewCell

@synthesize baseView;
@synthesize slideView;
@synthesize titleInList;
@synthesize imageInList;
@synthesize idInList;
@synthesize cellDelete;
@synthesize slideOpened_;
@synthesize IsSelected_;


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
    
    //[self setHighlighted:YES animated:NO];
    [super setSelected:selected animated:animated];
    
    

    // Configure the view for the selected state
}

+(CGFloat)rowHeight
{
    return 80.0f;
}

- (void)setSlideOpened
{
   
        if (self.slideOpened_) {
            // open slide
            [UIView animateWithDuration:0.2
                            animations:^{
                                CGRect frame = self.baseView.frame;
                                frame.origin.x = -200.0f;
                                self.baseView.frame = frame;
                            }];
            self.imageInList.alpha = 0.3;
        } else {
            // close slide
            [UIView animateWithDuration:0.1
                            animations:^{
                                CGRect frame = self.baseView.frame;
                                frame.origin.x = 0;
                                self.baseView.frame = frame;
                            }];
            self.imageInList.alpha = 1.0;
        }
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor* selectedColor = [UIColor whiteColor];  // default color
    if (highlighted||self.IsSelected_) {
        selectedColor = [UIColor blueColor];
    }
    self.baseView.backgroundColor = selectedColor;
    [super setHighlighted:highlighted animated:animated];
}



- (void)dealloc {
    [imageInList release];
    [titleInList release];
    [idInList release];
    [cellDelete release];
    [super dealloc];
}
@end
