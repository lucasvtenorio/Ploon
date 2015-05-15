//
//  PLAnalogStick.h
//  Ploon
//
//  Created by Lucas Vicente Tenório on 12/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class PLAnalogStick;
@protocol PLAnalogStickDelegate <NSObject>
- (void) analogStick:(PLAnalogStick *) analogStick movedWithVelocity:(CGPoint) velocity andAngularVelocity:(CGFloat) angularVelocity;
@end

@interface PLAnalogStick : SKNode
@property (nonatomic) CGFloat backgroundNodeDiameter;
@property (nonatomic) CGFloat thumbNodeDiameter;
@property (nonatomic, weak) id <PLAnalogStickDelegate> delegate;
- (instancetype) initWithBackgroundSize:(CGSize) backgroundSize andThumbSize:(CGSize) thumbSize;
@end


