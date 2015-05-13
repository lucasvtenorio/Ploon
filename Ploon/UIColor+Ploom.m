//
//  UIColor+Ploom.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "UIColor+Ploom.h"

@implementation UIColor (Ploom)
+ (UIColor *) ploomEnemyStrokeColor {
    return [UIColor whiteColor];
}

+ (UIColor *) ploomEnemyFillColor {
    return [UIColor clearColor];
}

+ (UIColor *) ploomPlayerStrokeColor{
    return [UIColor blueColor];
}

+ (UIColor *) ploomPlayerFillColor{
    return [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.5];
}
@end
