//
//  PLEnemyNode.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 11/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLEnemyNode.h"

@interface PLEnemyNode ()
@property (nonatomic, strong) SKShapeNode *shapeNode;
@property (nonatomic) CGSize initialSize;
@property (nonatomic) CGSize finalSize;
@property (nonatomic) CGFloat animationDuration;
@end

@implementation PLEnemyNode
- (instancetype) init {
    if (self = [super init]) {
        
        self.shapeNode = [SKShapeNode shapeNodeWithPath:[self pathForSize:CGSizeMake(150.0, 150.0)] centered:YES];
        self.shapeNode.lineWidth = 5.0;
        self.shapeNode.glowWidth = 1.0;
        self.shapeNode.lineJoin = kCGLineJoinRound;
        self.animationDuration = 0.8;
        
        SKAction *action = [SKAction customActionWithDuration:self.animationDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            if ([node isKindOfClass:[PLEnemyNode class]]) {
                PLEnemyNode *enemy = (PLEnemyNode *)node;
                [enemy animateForTime:elapsedTime];
            }
        }];
        
        SKAction *reverse = [SKAction customActionWithDuration:self.animationDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            if ([node isKindOfClass:[PLEnemyNode class]]) {
                PLEnemyNode *enemy = (PLEnemyNode *)node;
                [enemy reverseForTime:elapsedTime];
            }
        }];
        
        SKAction *test1 = [SKAction scaleXTo:0.8 y:1.2 duration:self.animationDuration];
        SKAction *test2 = [SKAction scaleXTo:1.2 y:0.8 duration:self.animationDuration];
        
        
        self.initialSize = CGSizeMake(120.0, 180.0);
        self.finalSize = CGSizeMake(180.0, 120.0);
        [self addChild:self.shapeNode];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[test1, test2]]]];
    }
    return self;
}


- (void) animateForTime:(CGFloat) elapsedTime {
    CGFloat percentage = elapsedTime/self.animationDuration;
    CGPathRef newPath = [self pathForInitialSize:self.initialSize finalSize: self.finalSize percentage:percentage];
    self.shapeNode.path = newPath;
}

- (void) reverseForTime:(CGFloat) elapsedTime {
    CGFloat percentage = elapsedTime/self.animationDuration;
    CGPathRef newPath = [self pathForInitialSize:self.finalSize finalSize: self.initialSize percentage:percentage];
    self.shapeNode.path = newPath;
}

- (CGFloat) interpolateWithInitial:(CGFloat) initial final:(CGFloat) final percentage:(CGFloat) percentage {
    return initial + (final - initial) * percentage;
}

- (CGPathRef) pathForInitialSize:(CGSize) initial finalSize:(CGSize) final percentage:(CGFloat) percentage{
    
    CGSize size = CGSizeMake([self interpolateWithInitial:initial.width final:final.width percentage:percentage], [self interpolateWithInitial:initial.height final:final.height percentage:percentage]);
    
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, NULL, -size.width/2.0, 0.0);
    CGPathAddLineToPoint(mutablePath, NULL, 0.0, -size.height/2.0);
    CGPathAddLineToPoint(mutablePath, NULL, size.width/2.0, 0.0);
    CGPathAddLineToPoint(mutablePath, NULL, 0.0, size.height/2.0);
    CGPathCloseSubpath(mutablePath);
    return mutablePath;
}

- (CGPathRef) pathForSize:(CGSize) size {
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, NULL, -size.width/2.0, 0.0);
    CGPathAddLineToPoint(mutablePath, NULL, 0.0, -size.height/2.0);
    CGPathAddLineToPoint(mutablePath, NULL, size.width/2.0, 0.0);
    CGPathAddLineToPoint(mutablePath, NULL, 0.0, size.height/2.0);
    CGPathCloseSubpath(mutablePath);
    return mutablePath;
}

@end
