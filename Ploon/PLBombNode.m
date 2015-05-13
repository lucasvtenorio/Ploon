//
//  PLBombNode.m
//  Ploon
//
//  Created by Lucas Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLBombNode.h"

@interface PLBombNode ()
@property (nonatomic, strong) SKShapeNode *mainShapeNode;
@property (nonatomic, strong) SKShapeNode *detailShapeNode;
@end
@implementation PLBombNode

- (instancetype) initWithRadius:(CGFloat)radius {
    if (self = [super init]) {
        _radius = radius;
        [self setupShapes];
        [self setupPhysics];
        [self setupAnimations];
    }
    return self;
}

- (void) setupShapes {
    self.mainShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
    self.detailShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius/2.0];
    
    self.mainShapeNode.lineWidth = 2.0;
    self.detailShapeNode.lineWidth = 2.0;
    
    [self addChild:self.mainShapeNode];
    [self addChild:self.detailShapeNode];
}

- (void) setupPhysics{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
}

- (void) setupAnimations {
    SKAction *growAction = [SKAction scaleTo:2.0 duration:4.0];
    SKAction *shrinkAction = [SKAction scaleTo:0.5 duration:4.0];
    SKAction *sequence = [SKAction sequence:@[growAction, shrinkAction]];
    SKAction *animateForever = [SKAction repeatActionForever:sequence];
    [self.detailShapeNode runAction:animateForever];
}
@end
