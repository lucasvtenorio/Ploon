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
    return [UIColor colorWithRed:204/255.0 green:38/255.0 blue:22/255.0 alpha:1.0];
}

+ (UIColor *) ploomEnemyFillColor {
    return [UIColor colorWithRed:255/255.0 green:111/255.0 blue:66/255.0 alpha:0.3];
}

+ (UIColor *) ploomBombStrokeColor{
    return [UIColor colorWithRed:8/255.0 green:73/255.0 blue:153/255.0 alpha:1.0];
}

+ (UIColor *) ploomBombFillColor{
    return [UIColor colorWithRed:22/255.0 green:104/255.0 blue:204/255.0 alpha:0.3];
}


+ (UIColor *) ploomPlayerStrokeColor{
    return [UIColor colorWithRed:2/255.0 green:49/255.0 blue:255/255.0 alpha:1.0];
}

+ (UIColor *) ploomPlayerFillColor{
    return [UIColor colorWithRed:2/255.0 green:49/255.0 blue:255/255.0 alpha:0.3];
}


+ (UIColor *) ploomAnalogBackgroundStrokeColor {
    return [UIColor whiteColor];
}
+ (UIColor *) ploomAnalogBackgroundFillColor {
    return [UIColor clearColor];
}
+ (UIColor *) ploomAnalogThumbStrokeColor {
    return [UIColor whiteColor];
}
+ (UIColor *) ploomAnalogThumbFillColor {
    return [UIColor colorWithWhite:1.0 alpha:0.7];
}

@end
