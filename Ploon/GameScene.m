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


static int test = 0;
@interface GameScene ()
@property (nonatomic, strong) PLPlayerNode *ship;
@property (nonatomic) BOOL touched;
@property (nonatomic) CGPoint startTouch;
@property (nonatomic) PLAnalogStick *moveAnalogStick;

@property (nonatomic, strong) NSArray *spawnPositions;

@property (nonatomic, strong) NSMutableSet *enemiesSet;
@property (nonatomic, strong) NSMutableSet *bombsSet;

@property (nonatomic) NSUInteger enemiesPerWave;

@property (nonatomic, strong) SKLabelNode *scoreLabelNode;
@property (nonatomic) NSUInteger numberOfEnemiesKilled;
@property (nonatomic) NSUInteger maximumNumberofEnemies;

@property (nonatomic, strong) AudioNode *audio;
@property (nonatomic) BOOL ending;

@end

@implementation GameScene

#pragma mark - Life Cycle

-(void)didMoveToView:(SKView *)view {
    NSLog(@"Did move to view! %d", test);
    test++;
    _state = GameSceneStatePressToStart;
//    [self cleanup];
//    [self start];
}
- (void) dealloc {
    NSLog(@"Dealloc called!!!!!!");
}
- (void) willMoveFromView:(SKView *)view {
    NSLog(@"Will remove the scene!");
    [self cleanup];
}

- (void) start {
    self.paused = NO;
    [self setupSound];
    [self setupSets];
    self.maximumNumberofEnemies = 400;
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.backgroundColor = [UIColor blackColor];
    self.ending = NO;
    self.physicsWorld.contactDelegate = self;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    self.physicsBody.categoryBitMask = sceneEdgeCategory;
    [self setupBackground];
    [self setupPlayer];
    [self addAnalogStick];
    [self populateSpawnPositions];
    [self setupActions];
    [self setupDifficulty];
    [self setupUI];
    self.shouldEnableEffects = NO;
    [self.ship animateAppearance];
    
    
    
    _state = GameSceneStateRunning;
    //[self setupFilter];
}

- (void) cleanup {
    self.paused = YES;
    [self removeAllChildren];
    [self removeAllActions];
    self.enemiesSet = nil;
    
}

#pragma mark - Sound

- (void) setupSound {
    self.audio = [AudioNode node];
    [self addChild:self.audio];
    [self.audio start];
    
}

#pragma mark - UI

- (void) setupUI {
    self.numberOfEnemiesKilled = 0;
    self.scoreLabelNode = [SKLabelNode node];
    self.scoreLabelNode.text = @"Score: 0";
    self.scoreLabelNode.fontColor = [UIColor whiteColor];

    CGFloat delta = 8.0;
    self.scoreLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    self.scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.scoreLabelNode.position = CGPointMake(delta, self.frame.size.height - delta);
    [self addChild:self.scoreLabelNode];
    
    SKAction *updateScore = [SKAction performSelector:@selector(updateScore) onTarget:self];
    SKAction *timing = [SKAction sequence:@[[SKAction waitForDuration:0.1], updateScore]];
    SKAction *repeatForever = [SKAction repeatActionForever:timing];
    [self runAction:repeatForever];
}

- (void) updateScore {
    self.scoreLabelNode.text = [NSString stringWithFormat:@"Score: %lu", (unsigned long)self.numberOfEnemiesKilled];
}
#pragma mark - Setup
- (void) setupDifficulty {
    self.enemiesPerWave = 1;
    
    SKAction *increase = [SKAction runBlock:^{
        if (self.enemiesPerWave < 20) {
            self.enemiesPerWave = self.enemiesPerWave + 1;
        }
    }];
    
    SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:6.0], increase]];
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
    SKAction *wait = [SKAction waitForDuration:128.0/60.0];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[wait, spawnEnemies]]]];
    
    
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
    if (self.bombsSet.count < 5) {
        PLBombNode *bomb = [[PLBombNode alloc] initWithRadius:35.0];
        bomb.position = CGPointMake([self randomFloatBetween:35.0 and:self.frame.size.width - 2* 35.0], [self randomFloatBetween:35.0 and:self.frame.size.height - 2* 35.0]);
        [self.bombsSet addObject:bomb];
        [self addChild:bomb];
    }
}

- (void) spawnEnemy {
    [self.audio enemySpawned];
    NSUInteger random = self.enemiesPerWave;
    if (self.enemiesPerWave > 5) {
        if (random + self.enemiesSet.count <= self.maximumNumberofEnemies) {
            CGPoint randomPosition = [self.spawnPositions[rand() % [self.spawnPositions count]] CGPointValue];
            CGFloat delta = 3.0;
            for (int i = 0 ; i<random; i++) {
                PLEnemyNode *enemy = [PLEnemyNode node];
                enemy.position = CGPointMake(randomPosition.x + delta*i, randomPosition.y + delta*i);
                [self.enemiesSet addObject:enemy];
                [self addChild:enemy];
            }
        }
    }
    if (random + self.enemiesSet.count <= self.maximumNumberofEnemies) {
        CGPoint randomPosition = [self.spawnPositions[rand() % [self.spawnPositions count]] CGPointValue];
        CGFloat delta = 3.0;
        for (int i = 0 ; i<random; i++) {
            PLEnemyNode *enemy = [PLEnemyNode node];
            enemy.position = CGPointMake(randomPosition.x + delta*i, randomPosition.y + delta*i);
            [self.enemiesSet addObject:enemy];
            [self addChild:enemy];
        }
    }
}

- (void) addAnalogStick {
    
    CGFloat bgDiametr = 150;
    CGFloat thumbDiametr = 75;
    CGFloat joysticksRadius = bgDiametr / 2;
    self.moveAnalogStick = [[PLAnalogStick alloc] initWithBackgroundSize:CGSizeMake(bgDiametr, bgDiametr) andThumbSize:CGSizeMake(thumbDiametr, thumbDiametr)];
    //self.moveAnalogStick.backgroundNodeDiameter = bgDiametr;
    //self.moveAnalogStick.thumbNodeDiameter = thumbDiametr;
    self.moveAnalogStick.position = CGPointMake(joysticksRadius + 25, joysticksRadius + 25);
    self.moveAnalogStick.delegate = self;
    self.moveAnalogStick.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:75];
    self.moveAnalogStick.physicsBody.categoryBitMask = uiCategory;
    self.moveAnalogStick.physicsBody.dynamic = NO;
    [self addChild:self.moveAnalogStick];
}

#pragma mark - Analog Stick Delegate

- (void) analogStick:(PLAnalogStick *)analogStick movedWithVelocity:(CGPoint)velocity andAngularVelocity:(CGFloat)angularVelocity {
    if (self.state == GameSceneStateRunning) {
        self.ship.position = CGPointMake(self.ship.position.x + (velocity.x * 0.12), self.ship.position.y + (velocity.y * 0.12));
        
        self.ship.zRotation = angularVelocity;
    }
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
    CGFloat radius = bombNode.radius * 1.5;
    
    
    NSSet *enemies = [self enemiesInRadius:radius fromPoint:bombNode.position];
    
    for (PLEnemyNode *enemy in enemies) {
        [self.enemiesSet removeObject:enemy];
        self.numberOfEnemiesKilled++;
        [enemy animateDeath];
    }
    [self.bombsSet removeObject:bombNode];
    [bombNode animateDeath];
    [self.audio increase];
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
- (void) switchToEnd {
    [self.audio playerExploded];
    _state = GameSceneStateEnded;
}
- (void) playerContactedEnemy {
    NSLog(@"Player contacted enemy");
    if (self.state == GameSceneStateRunning) {
        _state = GameSceneStateEnding;
        [self.ship animateDeath];
        //self.physicsWorld.contactDelegate = nil;
        NSLog(@"Going to start Ending!");
        self.ending = YES;
        SKAction *end = [SKAction runBlock:^{
            [self switchToEnd];
            NSLog(@"Finished end block");
        }];
        //[self.audio fadeOut];
        if (self.audio) {
            SKAction *a = [self.audio fadeOutAction];
            [self runAction:[SKAction sequence:@[a, end]]];
        }else{
            [self runAction:[SKAction sequence:@[end]]];
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


#pragma mark - Background

- (void) drawGridBackgroundWithRectangleSize:(CGSize) rectangleSize {
    CGFloat x = 0.0;
    CGFloat y = 0.0;
    
    UIColor *color = [UIColor colorWithWhite:1.0 alpha:0.1];
    while (x < self.frame.size.width) {
        CGPoint a = CGPointMake(x, 0.0);
        CGPoint b = CGPointMake(x, self.frame.size.height);
        CGPoint points[2];
        points[0] = a;
        points[1] = b;
        SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithPoints:points count:2];
        shapeNode.strokeColor = color;
        [self addChild:shapeNode];
        x+=rectangleSize.width;
    }
    
    while (y < self.frame.size.height) {
        CGPoint a = CGPointMake(0.0, y);
        CGPoint b = CGPointMake(self.frame.size.width, y);
        CGPoint points[2];
        points[0] = a;
        points[1] = b;
        SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithPoints:points count:2];
        shapeNode.strokeColor = color;
        [self addChild:shapeNode];
        y+=rectangleSize.height;
    }
}

- (void) setupBackground {
    CGSize gridSize = CGSizeMake(60.0, 60.0);
    [self drawGridBackgroundWithRectangleSize:gridSize];
    [self drawGridBackgroundWithRectangleSize:CGSizeMake(gridSize.width/2.0, gridSize.height/2.0)];
}


#pragma mark - Shader Test
- (void) setFilterInputScale:(CGFloat) inputScale {
    [self.filter setValue:[NSNumber numberWithFloat:inputScale] forKey:@"inputScale"];
}

- (void) setFilterPoint:(CGPoint) point {
    NSLog(@"Point %@", NSStringFromCGPoint(point));
    [self.filter setValue:[CIVector vectorWithX:point.x Y:point.y] forKey:@"inputCenter"];
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


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.state == GameSceneStatePressToStart) {
        [self cleanup];
        [self start];
    }
}

- (void) update:(NSTimeInterval)currentTime {
    if (self.state == GameSceneStateEnded) {
        if (self.gameDelegate) {
            if ([self.gameDelegate respondsToSelector:@selector(gameSceneGameDidEnd:)])  {
                [self.gameDelegate gameSceneGameDidEnd:self];
            }
        }
        _state = GameSceneStateFinished;
        NSLog(@"Ending complete");
    }
}

@end
