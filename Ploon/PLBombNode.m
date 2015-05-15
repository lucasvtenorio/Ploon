//
//  PLBombNode.m
//  Ploon
//
//  Created by Lucas Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLBombNode.h"
#import "Ploon.h"
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
        self.zPosition = 4;
    }
    return self;
}

- (void) setupShapes {
    self.mainShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius];
    self.mainShapeNode.lineWidth = 1.0;
    //self.mainShapeNode.fillColor = [UIColor ploomBombFillColor];
    self.mainShapeNode.strokeColor = [UIColor ploomBombStrokeColor];
    
    
    self.detailShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.radius/2.0];
    self.detailShapeNode.lineWidth = 1.0;
    self.detailShapeNode.fillColor = [UIColor ploomBombFillColor];
    self.detailShapeNode.strokeColor = [UIColor ploomBombStrokeColor];
    
    [self addChild:self.mainShapeNode];
    [self addChild:self.detailShapeNode];
}

- (void) setupPhysics{
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.radius];
    self.physicsBody.categoryBitMask = bombCategory;
    self.physicsBody.collisionBitMask = sceneEdgeCategory | uiCategory;
}

- (void) setupAnimations {
    SKAction *growAction = [SKAction scaleTo:2.0 duration:2.0];
    growAction.timingMode = SKActionTimingEaseIn;
    SKAction *shrinkAction = [SKAction scaleTo:0.5 duration:2.0];
    shrinkAction.timingMode = SKActionTimingEaseOut;
    SKAction *sequence = [SKAction sequence:@[growAction, shrinkAction]];
    SKAction *animateForever = [SKAction repeatActionForever:sequence];
    [self.detailShapeNode runAction:animateForever];
}

- (void) animateDeath {
    SKAction *disappear = [SKAction sequence:@[[SKAction scaleTo:3.0 duration:0.25],[SKAction scaleTo:0.0 duration:0.25], [SKAction removeFromParent]]];
    [self runAction:disappear];
}
@end
