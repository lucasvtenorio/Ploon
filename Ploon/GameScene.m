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
@property (nonatomic) PLAnalogStick *moveAnalogStick;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    self.ship.size = CGSizeMake(35.0, 35.0);
    self.ship.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
    self.ship.physicsBody.categoryBitMask = shipCategory;
    self.ship.physicsBody.collisionBitMask = sceneEdgeCategory | enemyCategory;
    //[self.ship setScale:0.15];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    self.physicsBody.categoryBitMask = sceneEdgeCategory;
    [self addChild:self.ship];
    
    for (int i = 0; i < 4; i++) {
        [self spawnEnemy];
    }
    [self addAnalogStick];
    
    SKAction *spawnAction = [SKAction performSelector:@selector(spawnEnemy) onTarget:self];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:2.0], spawnAction]]]];
}
- (CGPoint) playerPosition {
    return self.ship.position;
}
- (void) spawnEnemy {
    PLEnemyNode *enemy = [PLEnemyNode node];
    enemy.position = CGPointMake(rand() % (int) self.frame.size.width, rand() % (int) self.frame.size.height);//CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:enemy];
}
- (void) addAnalogStick {
    self.moveAnalogStick = [[PLAnalogStick alloc] init];
    CGFloat bgDiametr = 150;
    CGFloat thumbDiametr = 75;
    CGFloat joysticksRadius = bgDiametr / 2;
    self.moveAnalogStick.backgroundNodeDiameter = bgDiametr;
    self.moveAnalogStick.thumbNodeDiameter = thumbDiametr;
    self.moveAnalogStick.position = CGPointMake(joysticksRadius + 25, joysticksRadius + 25);
    self.moveAnalogStick.delegate = self;
    [self addChild:self.moveAnalogStick];
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

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        if (!self.touched) {
//            self.startTouch = location;
//            self.touched = YES;
//        }
//        break;
//    }
//}
//
//
//- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    for (UITouch *touch in touches) {
//        if (self.touched) {
//            CGPoint location = [touch locationInNode:self];
//            CGPoint vector = [self normalizedDifferenceWithStartingPoint:self.startTouch andEndPoint:location];
//            CGFloat mass = self.ship.physicsBody.mass;
//            [self.ship.physicsBody applyForce:CGVectorMake(mass*vector.x * 1500.0, mass* vector.y* 1500.0)];
//            NSLog(@"Vector %@ %f", NSStringFromCGPoint(vector), mass);
//        }
//        break;
//    }
//}
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.touched = NO;
//}
- (void) analogStick:(PLAnalogStick *)analogStick movedWithVelocity:(CGPoint)velocity andAngularVelocity:(CGFloat)angularVelocity {
    self.ship.position = CGPointMake(self.ship.position.x + (velocity.x * 0.12), self.ship.position.y + (velocity.y * 0.12));
    self.ship.zRotation = angularVelocity;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
