//
//  CFViewController.m
//  StandOutColor
//
//  Created by Storm Edge Apps LLC on 22.07.14.
//  Copyright (c) 2014 Storm Edge Apps LLC. All rights reserved.
//

#import "CFViewController.h"
#import "ImageHelper.h"

typedef enum { R, G, B, A } UIColorComponentIndices;
#define MIN3(x,y,z)  ((y) <= (z) ? \
((x) <= (y) ? (x) : (y)) \
: \
((x) <= (z) ? (x) : (z)))

#define MAX3(x,y,z)  ((y) >= (z) ? \
((x) >= (y) ? (x) : (y)) \
: \
((x) >= (z) ? (x) : (z)))

/**
 * RGB to HSL converter.
 * Adapted from: https://github.com/alessani/ColorConverter
 */
static void RGB_TO_HSL (CGFloat r, CGFloat g, CGFloat b, CGFloat *outH, CGFloat *outS, CGFloat *outL){
    CGFloat h,s,l,v,m,vm,r2,g2,b2;
    
    h = 0; s = 0;
    
    v = MAX(r, g);
    v = MAX(v, b);
    m = MIN(r, g);
    m = MIN(m, b);
    
    l = (m+v)/2.0f;
    
    if (l <= 0.0) {
        if(outH)
            *outH = h;
        if(outS)
            *outS = s;
        if(outL)
            *outL = l;
        return;
    }
    
    vm = v - m;
    s = vm;
    
    if (s > 0.0f) {
        s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m);
    } else {
        if(outH)
            *outH = h;
        if(outS)
            *outS = s;
        if(outL)
            *outL = l;
        return;
    }
    
    r2 = (v - r)/vm;
    g2 = (v - g)/vm;
    b2 = (v - b)/vm;
    
    if (r == v){
        h = (g == m ? 5.0f + b2 : 1.0f - g2);
    }else if (g == v){
        h = (b == m ? 1.0f + r2 : 3.0 - b2);
    }else{
        h = (r == m ? 3.0f + g2 : 5.0f - r2);
    }
    
    h/=6.0f;
    
    if(outH)
        *outH = h;
    if(outS)
        *outS = s;
    if(outL)
        *outL = l;
}

struct rgb_color {
    CGFloat r, g, b;
};

struct hsv_color {
    CGFloat hue;
    CGFloat sat;
    CGFloat val;
};

@interface UIColor (UIColorAdditions)

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
- (CGFloat)value;
- (CGFloat)brightness;
- (CGFloat)saturation;

@end

@interface NSString (UIColorAdditions)

+ (UIColor *)colorFromNSString:(NSString *)string;

@end

@implementation UIColor (UIColorAdditions)


- (CGFloat)red{ return CGColorGetComponents(self.CGColor)[R]; }

- (CGFloat)green{ return CGColorGetComponents(self.CGColor)[G]; }

- (CGFloat)blue{ return CGColorGetComponents(self.CGColor)[B]; }

- (CGFloat)alpha{ return CGColorGetComponents(self.CGColor)[A]; }

+ (struct hsv_color)HSVfromRGB:(struct rgb_color)rgb{
    struct hsv_color hsv;
    
    CGFloat rgb_min, rgb_max;
    rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
    rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
    
    hsv.val = rgb_max;
    if (hsv.val == 0) {
        hsv.hue = hsv.sat = 0;
        return hsv;
    }
    
    rgb.r /= hsv.val;
    rgb.g /= hsv.val;
    rgb.b /= hsv.val;
    rgb_min = MIN3(rgb.r, rgb.g, rgb.b);
    rgb_max = MAX3(rgb.r, rgb.g, rgb.b);
    
    hsv.sat = rgb_max - rgb_min;
    if (hsv.sat == 0) {
        hsv.hue = 0;
        return hsv;
    }
    
    if (rgb_max == rgb.r) {
        hsv.hue = 0.0 + 60.0*(rgb.g - rgb.b);
        if (hsv.hue < 0.0) {
            hsv.hue += 360.0;
        }
    } else if (rgb_max == rgb.g) {
        hsv.hue = 120.0 + 60.0*(rgb.b - rgb.r);
    } else /* rgb_max == rgb.b */ {
        hsv.hue = 240.0 + 60.0*(rgb.r - rgb.g);
    }
    
    return hsv;
}

- (CGFloat)hue{
    struct hsv_color hsv;
    struct rgb_color rgb;
    rgb.r = [self red];
    rgb.g = [self green];
    rgb.b = [self blue];
    hsv = [UIColor HSVfromRGB: rgb];
    return (hsv.hue / 360.0);
}

- (CGFloat)saturation{
    struct hsv_color hsv;
    struct rgb_color rgb;
    rgb.r = [self red];
    rgb.g = [self green];
    rgb.b = [self blue];
    hsv = [UIColor HSVfromRGB: rgb];
    return hsv.sat;
}

- (CGFloat)brightness{
    struct hsv_color hsv;
    struct rgb_color rgb;
    rgb.r = [self red];
    rgb.g = [self green];
    rgb.b = [self blue];
    hsv = [UIColor HSVfromRGB: rgb];
    return hsv.val;
}

- (CGFloat)value{
    return [self brightness];
}
@end

@interface CFViewController ()

@end

@implementation CFViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    imageNames = [NSArray arrayWithObjects:@"Blue1.png", @"Blue2.jpg", @"Blue3.jpg", 
        @"Red1.jpg", @"Red2.jpg", @"Red3.jpg", @"Red4.jpg", 
        @"Golden1.jpg", @"Golden2.jpg", @"Golden3.jpg", @"Cyan1.jpg", nil];
    imageIndex = 0;
    
	[imageView setImage:[UIImage imageNamed:[imageNames objectAtIndex:imageIndex]]];
    [colorView setBackgroundColor:[self getDominatingColor:imageView.image]];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)next{
    imageIndex++;
    if (imageIndex >= imageNames.count) imageIndex = 0;
    
    [imageView setImage:[UIImage imageNamed:[imageNames objectAtIndex:imageIndex]]];
    [colorView setBackgroundColor:[self getDominatingColor:imageView.image]];
}

- (UIColor *)getDominatingColor:(UIImage *)image{
    float maxDominatingFactor = 0;
    UIColor *returnColor;
    NSArray *colors = [ImageHelper mostFrequentColors:30 of:image withColorPallete:ColorPalete512];
    for(UIColor *color in colors){
        if(([color brightness] + [color saturation]) > maxDominatingFactor){
            returnColor = color;
            maxDominatingFactor = ([color brightness] + [color saturation]);
        }
    }
    
    return returnColor;
}

@end
