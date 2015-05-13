//
//  GameScene.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 11/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "GameScene.h"
#import "PLEnemyNode.h"
#import "PLBombNode.h"


@interface GameScene ()
@property (nonatomic, strong) SKSpriteNode *ship;
@property (nonatomic) BOOL touched;
@property (nonatomic) CGPoint startTouch;
@property (nonatomic) PLAnalogStick *moveAnalogStick;

@property (nonatomic, strong) NSArray *spawnPositions;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor blackColor];
    self.physicsWorld.contactDelegate = self;
    self.ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    self.ship.size = CGSizeMake(35.0, 35.0);
    self.ship.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.ship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15.0];
    self.ship.physicsBody.categoryBitMask = shipCategory;
    self.ship.physicsBody.collisionBitMask = sceneEdgeCategory | enemyCategory;
    self.ship.physicsBody.contactTestBitMask = enemyCategory;
    //[self.ship setScale:0.15];
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    self.physicsBody.categoryBitMask = sceneEdgeCategory;
    [self addChild:self.ship];
    

    [self addAnalogStick];
    [self populateSpawnPositions];
    SKAction *spawnAction = [SKAction performSelector:@selector(spawnEnemy) onTarget:self];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:5.0], spawnAction]]]];
    
    
    PLBombNode *bomb = [[PLBombNode alloc] initWithRadius:60.0];
    bomb.position = CGPointMake(CGRectGetMidX(self.frame),
                                CGRectGetMidY(self.frame));
    [self addChild:bomb];
}

- (void) populateSpawnPositions {
    CGPoint position1 = CGPointMake(0.0, 0.0);
    CGFloat delta = 30.0;
    CGPoint position2 = CGPointMake(0.0, self.frame.size.height - delta);
    CGPoint position3 = CGPointMake(self.frame.size.width - delta, 0.0);
    CGPoint position4 = CGPointMake(self.frame.size.width - delta, self.frame.size.height - delta);
    self.spawnPositions = @[[NSValue valueWithCGPoint:position2], [NSValue valueWithCGPoint:position3], [NSValue valueWithCGPoint:position4]];
}

- (CGPoint) playerPosition {
    return self.ship.position;
}
- (void) spawnEnemy {
    int random = rand() % 3 + 1;
    for (int i = 0 ; i<random; i++) {
        PLEnemyNode *enemy = [PLEnemyNode node];
        CGPoint randomPosition = [self.spawnPositions[rand() % [self.spawnPositions count]] CGPointValue];
        enemy.position = randomPosition;//CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:enemy];
    }
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

- (void) analogStick:(PLAnalogStick *)analogStick movedWithVelocity:(CGPoint)velocity andAngularVelocity:(CGFloat)angularVelocity {
    self.ship.position = CGPointMake(self.ship.position.x + (velocity.x * 0.12), self.ship.position.y + (velocity.y * 0.12));
    
    self.ship.zRotation = angularVelocity;
}
- (void) didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == shipCategory) {
        if (contact.bodyB.categoryBitMask == enemyCategory) {
            [self playerContactedEnemy];
        }
    }else if (contact.bodyA.categoryBitMask == enemyCategory) {
        if (contact.bodyB.categoryBitMask == shipCategory) {
            [self playerContactedEnemy];
        }
    }
}

- (void) playerContactedEnemy {
    if (self.gameDelegate) {
        if ([self.gameDelegate respondsToSelector:@selector(gameSceneGameDidEnd:)])  {
            [self.gameDelegate gameSceneGameDidEnd:self];
        }
    }
}
- (void) cleanup {
    [self removeAllChildren];
    [self removeAllActions];
}
-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
