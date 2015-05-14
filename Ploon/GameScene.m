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
#import "PLPlayerNode.h"

@interface GameScene ()
@property (nonatomic, strong) PLPlayerNode *ship;
@property (nonatomic) BOOL touched;
@property (nonatomic) CGPoint startTouch;
@property (nonatomic) PLAnalogStick *moveAnalogStick;

@property (nonatomic, strong) NSArray *spawnPositions;

@property (nonatomic, strong) NSMutableSet *enemiesSet;
@property (nonatomic, strong) NSMutableSet *bombsSet;

@property (nonatomic) NSUInteger enemiesPerWave;

@end

@implementation GameScene

#pragma mark - Life Cycle

-(void)didMoveToView:(SKView *)view {
    [self setupSets];
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.backgroundColor = [UIColor blackColor];
    self.physicsWorld.contactDelegate = self;
    
    
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    self.physicsBody.categoryBitMask = sceneEdgeCategory;
    //[self setupBackground];
    [self setupPlayer];
    [self addAnalogStick];
    [self populateSpawnPositions];
    [self setupActions];
    [self setupDifficulty];
    //[self setupFilter];
}


- (void) cleanup {
    [self removeAllChildren];
    [self removeAllActions];
    self.enemiesSet = nil;
}

#pragma mark - Setup

- (void) setupDifficulty {
    self.enemiesPerWave = 3;
    
    SKAction *increase = [SKAction runBlock:^{
        if (self.enemiesPerWave < 20) {
            self.enemiesPerWave = self.enemiesPerWave + 2;
        }
    }];
    
    SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:5.0], increase]];
    [self runAction:[SKAction repeatActionForever:sequence]];
}

- (void) setupSets{
    self.enemiesSet = [NSMutableSet set];
    self.bombsSet = [NSMutableSet set];
}

- (void) setupPlayer {
    self.ship = [[PLPlayerNode alloc] initWithSize:CGSizeMake(35.0/2.0, 35.0)];
    self.ship.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
    [self addChild:self.ship];
}

- (void) setupActions {
    SKAction *spawnEnemies = [SKAction performSelector:@selector(spawnEnemy) onTarget:self];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[spawnEnemies,[SKAction waitForDuration:3.0]]]]];
    
    
    SKAction *spawnBombs = [SKAction performSelector:@selector(spawnBomb) onTarget:self];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:3.0], spawnBombs]]]];
}


- (void) populateSpawnPositions {
    CGFloat delta = 50.0;
    CGPoint position2 = CGPointMake(delta, self.frame.size.height - delta);
    CGPoint position3 = CGPointMake(self.frame.size.width - delta, delta);
    CGPoint position4 = CGPointMake(self.frame.size.width - delta, self.frame.size.height - delta);
    self.spawnPositions = @[[NSValue valueWithCGPoint:position2], [NSValue valueWithCGPoint:position3], [NSValue valueWithCGPoint:position4]];
}



- (void) spawnBomb{
    if (self.bombsSet.count < 3) {
        PLBombNode *bomb = [[PLBombNode alloc] initWithRadius:35.0];
        bomb.position = CGPointMake([self randomFloatBetween:35.0 and:self.frame.size.width - 2* 35.0], [self randomFloatBetween:35.0 and:self.frame.size.height - 2* 35.0]);
        [self.bombsSet addObject:bomb];
        [self addChild:bomb];
    }
}

- (void) spawnEnemy {
    NSUInteger random = self.enemiesPerWave;
    CGPoint randomPosition = [self.spawnPositions[rand() % [self.spawnPositions count]] CGPointValue];
    for (int i = 0 ; i<random; i++) {
        PLEnemyNode *enemy = [PLEnemyNode node];
        enemy.position = randomPosition;
        [self.enemiesSet addObject:enemy];
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

#pragma mark - Analog Stick Delegate

- (void) analogStick:(PLAnalogStick *)analogStick movedWithVelocity:(CGPoint)velocity andAngularVelocity:(CGFloat)angularVelocity {
    self.ship.position = CGPointMake(self.ship.position.x + (velocity.x * 0.12), self.ship.position.y + (velocity.y * 0.12));
    
    self.ship.zRotation = angularVelocity;
}

#pragma mark - Physics
- (void) didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == shipCategory) {
        if (contact.bodyB.categoryBitMask == enemyCategory) {
            [self playerContactedEnemy];
        }else if(contact.bodyB.categoryBitMask == bombCategory) {
            [self playerContactedBomb:contact.bodyB.node];
        }
    }else if (contact.bodyA.categoryBitMask == enemyCategory) {
        if (contact.bodyB.categoryBitMask == shipCategory) {
            [self playerContactedEnemy];
        }
    }else if (contact.bodyA.categoryBitMask == bombCategory) {
        if (contact.bodyB.categoryBitMask == shipCategory) {
            [self playerContactedBomb: contact.bodyA.node];
        }
    }
}
- (void) playerContactedBomb:(SKNode *) bomb {
    PLBombNode *bombNode = (PLBombNode *) bomb;
    CGFloat radius = bombNode.radius;
    
    
    NSSet *enemies = [self enemiesInRadius:radius fromPoint:bombNode.position];
    
    for (PLEnemyNode *enemy in enemies) {
        [self.enemiesSet removeObject:enemy];
        [enemy animateDeath];
    }
    [self.bombsSet removeObject:bombNode];
    [bombNode animateDeath];
}



- (NSSet *) enemiesInRadius:(CGFloat) radius fromPoint:(CGPoint) point {
    
    NSMutableSet *result = [NSMutableSet set];
    for (PLEnemyNode *enemy in self.enemiesSet) {
        CGFloat difference = sqrt((enemy.position.x - point.x) * (enemy.position.x - point.x) + (enemy.position.y - point.y) * (enemy.position.y - point.y));
        if (difference <= radius*3.0) {
            [result addObject:enemy];
        }
    }
    return result;
}

- (void) playerContactedEnemy {
    if (self.gameDelegate) {
        if ([self.gameDelegate respondsToSelector:@selector(gameSceneGameDidEnd:)])  {
            [self.gameDelegate gameSceneGameDidEnd:self];
        }
    }
}

#pragma mark - Util
- (CGPoint) playerPosition {
    return self.ship.position;
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
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

- (CGFloat) interpolateWithInitial:(CGFloat) initial final:(CGFloat) final percentage:(CGFloat) percentage {
    return initial + (final - initial) * percentage;
}


#pragma mark - Shader Test

- (void) setupBackground {
    CGSize gridSize = CGSizeMake(30.0, 30.0);
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    
    while (x < self.frame.size.width) {
        CGPoint a = CGPointMake(x, 0.0);
        CGPoint b = CGPointMake(x, self.frame.size.height);
        CGPoint points[2];
        points[0] = a;
        points[1] = b;
        SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithPoints:points count:2];
        [self addChild:shapeNode];
        x+=gridSize.width;
    }
    
    while (y < self.frame.size.height) {
        CGPoint a = CGPointMake(0.0, y);
        CGPoint b = CGPointMake(self.frame.size.width, y);
        CGPoint points[2];
        points[0] = a;
        points[1] = b;
        SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithPoints:points count:2];
        [self addChild:shapeNode];
        y+=gridSize.height;
    }
}
- (void) setFilterInputScale:(CGFloat) inputScale {
    [self.filter setValue:[NSNumber numberWithFloat:inputScale] forKey:@"inputScale"];
}

- (void) setupFilter {
    
    self.shouldEnableEffects = YES;
    self.shouldRasterize = NO;
    
    CIFilter *bumpDistortion = [CIFilter filterWithName:@"CIBumpDistortion"];
    [bumpDistortion setDefaults];
    [bumpDistortion setValue:[CIVector vectorWithX:self.frame.size.width/2.0 Y:self.frame.size.height/2.0] forKey:@"inputCenter"];
    [bumpDistortion setValue:[NSNumber numberWithFloat:300] forKey:@"inputRadius"];
    //[bumpDistortion setValue:[NSNumber numberWithFloat:-0.5] forKey:@"inputScale"];
    
    self.filter = bumpDistortion;
    [self setFilterInputScale:-0.9];
    
    NSTimeInterval duration = 0.5;
    
    SKAction *animate = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat percentage = elapsedTime/duration;
        CGFloat value = [self interpolateWithInitial:-0.1 final:0.1 percentage:percentage];
        [self setFilterInputScale:value];
    }];
    
    SKAction *reverse = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat percentage = elapsedTime/duration;
        CGFloat value = [self interpolateWithInitial:-0.1 final:0.1 percentage:(1-percentage)];
        [self setFilterInputScale:value];
    }];
    
    SKAction *sequence = [SKAction sequence:@[animate, reverse]];
    [self runAction:[SKAction repeatActionForever:sequence]];
}

@end
