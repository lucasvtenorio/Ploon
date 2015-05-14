//
//  PLPlayerNode.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLPlayerNode.h"
#import "Ploon.h"
@interface PLPlayerNode ()
@property (nonatomic, strong) SKShapeNode *mainShapeNode;
@end

@implementation PLPlayerNode
- (instancetype) initWithSize:(CGSize)size {
    if (self = [super init]) {
        _size = size;
        [self setupShapes];
        [self setupPhysics];
    }
    return self;
}


- (void) setupShapes{
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, NULL, -self.size.width/2.0, 0.0);
    CGPathAddLineToPoint(mutablePath, NULL, 0.0, self.size.height/2.0);
    CGPathAddLineToPoint(mutablePath, NULL, self.size.width/2.0, 0.0);
    CGPathCloseSubpath(mutablePath);
    
    self.mainShapeNode = [SKShapeNode shapeNodeWithPath:mutablePath];
    self.mainShapeNode.fillColor = [UIColor ploomPlayerFillColor];
    self.mainShapeNode.strokeColor = [UIColor ploomPlayerStrokeColor];
    [self addChild:self.mainShapeNode];
}

-(void) setupPhysics {
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2.0];
    self.physicsBody.categoryBitMask = shipCategory;
    self.physicsBody.collisionBitMask = sceneEdgeCategory | enemyCategory | uiCategory;
    self.physicsBody.contactTestBitMask = enemyCategory | bombCategory;
}

- (void) animateDeath {
    
}
@end
