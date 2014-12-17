//
//  ModalViewController.h
//  TableTopClient
//
//  Created by student on 14/12/04.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *imageSize;
    IBOutlet UILabel *recievedTime;
    IBOutlet UILabel *sender;
    IBOutlet UIScrollView *scrollView;
    

}
@property (retain, nonatomic) UIImage *_image;
@property (retain, nonatomic) NSString *_imageSize;
@property (retain, nonatomic) NSString *_recievedTime;
@property (retain, nonatomic) NSString *_sender;
@end
