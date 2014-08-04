//
//  CFViewController.h
//  StandOutColor
//
//  Created by Storm Edge Apps LLC on 22.07.14.
//  Copyright (c) 2014 Storm Edge Apps LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFViewController : UIViewController
{
    NSArray *imageNames;
    int imageIndex;

    IBOutlet UIView *colorView;
    IBOutlet UIImageView *imageView;
}

-(IBAction)next;

-(UIColor *)getDominatingColor:(UIImage *)image;


@end
