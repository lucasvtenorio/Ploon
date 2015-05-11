//
//  GameScene.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 11/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "GameScene.h"
#import "PLEnemyNode.h"

@interface GameScene ()
@property (nonatomic, strong) SKSpriteNode *ship;
@property (nonatomic) BOOL touched;
@property (nonatomic) CGPoint startTouch;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    self.ship.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:100.0];
    self.ship.physicsBody.categoryBitMask = shipCategory;
    self.ship.physicsBody.collisionBitMask = sceneEdgeCategory;
    [self.ship setScale:0.3];
    
    
    
    NSLog(@"FRame %@", NSStringFromCGRect(self.frame));
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    self.physicsBody.categoryBitMask = sceneEdgeCategory;
    //[self addChild:self.ship];
    
    
    PLEnemyNode *enemy = [PLEnemyNode node];
    enemy.position = CGPointMake(CGRectGetMidX(self.frame),
                                                          CGRectGetMidY(self.frame));
    [self addChild:enemy];
}

- (CGFloat) lenghtOfPoint:(CGPoint) point{
    return sqrtf(point.x*point.x +point.y*point.y);
}
- (CGPoint) normalize:(CGPoint) point {
    CGFloat length = [self lenghtOfPoint:point];
    return CGPointMake(point.x / length, point.y / length);
}

- (CGPoint) normalizedDifferenceWithStartingPoint:(CGPoint) start andEndPoint:(CGPoint) end {
    CGPoint difference = CGPointMake(end.x - start.x, end.y - start.y);
    return [self normalize:difference];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (!self.touched) {
            self.startTouch = location;
            self.touched = YES;
        }
        break;
    }
}


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (self.touched) {
            CGPoint location = [touch locationInNode:self];
            CGPoint vector = [self normalizedDifferenceWithStartingPoint:self.startTouch andEndPoint:location];
            CGFloat mass = self.ship.physicsBody.mass;
            [self.ship.physicsBody applyForce:CGVectorMake(mass*vector.x * 1500.0, mass* vector.y* 1500.0)];
            NSLog(@"Vector %@ %f", NSStringFromCGPoint(vector), mass);
        }
        break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touched = NO;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
