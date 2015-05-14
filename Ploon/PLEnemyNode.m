//
//  PLEnemyNode.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 11/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLEnemyNode.h"
#import "GameScene.h"


@interface PLEnemyNode ()
@property (nonatomic, strong) SKShapeNode *shapeNode;
@property (nonatomic) CGFloat animationDuration;
@end

@implementation PLEnemyNode
- (instancetype) init {
    if (self = [super init]) {
        
        self.shapeNode = [SKShapeNode shapeNodeWithPath:[self pathForSize:CGSizeMake(20.0, 20.0)] centered:YES];
        self.shapeNode.strokeColor = [UIColor ploomEnemyStrokeColor];
        self.shapeNode.fillColor = [UIColor ploomEnemyFillColor];
        //self.shapeNode.lineWidth = 3.0;
        //self.shapeNode.glowWidth = 1.0;
        self.shapeNode.lineJoin = kCGLineJoinRound;
        
        self.animationDuration = 0.8;
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:9.0];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.collisionBitMask =  enemyCategory | shipCategory | uiCategory;
        self.physicsBody.allowsRotation = NO;

        
        SKAction *test1 = [SKAction scaleXTo:0.8 y:1.2 duration:self.animationDuration];
        SKAction *test2 = [SKAction scaleXTo:1.2 y:0.8 duration:self.animationDuration];
        
        
        SKAction *behaviour = [SKAction performSelector:@selector(runBehaviour) onTarget:self];
        [self addChild:self.shapeNode];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[test1, test2]]]];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[behaviour, [SKAction waitForDuration:0.016 withRange:0.00]]]]];
    }
    return self;
}

- (void) runBehaviour{
    if (self.parent) {
        if ([self.parent isKindOfClass:[GameScene class]]) {
            GameScene *gameScene = (GameScene *)self.parent;
            [self seekPoint:[gameScene playerPosition]];
        }
    }
}

- (CGFloat) lenghtOfVector:(CGVector) vector{
    return sqrtf(vector.dx*vector.dx +vector.dy*vector.dy);
}

- (CGVector) normalizeVector:(CGVector) vector{
    CGFloat length = [self lenghtOfVector:vector];
    return CGVectorMake(vector.dx / length, vector.dy / length);
}

- (CGFloat) lenghtOfPoint:(CGPoint) point{
    return sqrtf(point.x*point.x +point.y*point.y);
}
- (CGPoint) normalize:(CGPoint) point {
    CGFloat length = [self lenghtOfPoint:point];
    return CGPointMake(point.x / length, point.y / length);
}

- (void) seekPoint:(CGPoint) point {
    CGFloat max_speed = 200.0;
    CGFloat max_force = 60.0;
    CGFloat slowingDistance = 50.0;
    CGPoint target_offset = CGPointMake(point.x - self.position.x, point.y - self.position.y);
    CGFloat distance = [self lenghtOfPoint:target_offset];
    CGFloat ramped_speed = max_speed * (distance / slowingDistance);
    CGFloat clipped_speed  = MIN(ramped_speed, max_speed);
    CGVector desired_velocity = CGVectorMake(target_offset.x * (clipped_speed / distance), target_offset.y * (clipped_speed / distance));
    CGVector steering = CGVectorMake(desired_velocity.dx - self.physicsBody.velocity.dx, desired_velocity.dy - self.physicsBody.velocity.dy);
    CGVector steering_normalized = [self normalizeVector:steering];
    CGVector steering_force = CGVectorMake(steering_normalized.dx * max_force, steering_normalized.dy * max_force);
    [self.physicsBody applyForce:steering_force];
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (CGPoint) randomizePoint:(CGPoint) point withRange:(CGFloat) range {
    return CGPointMake([self randomFloatBetween:point.x-range and:point.x + range], [self randomFloatBetween:point.y-range and:point.y + range]);
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

- (void) animateDeath {
    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"PLEnemyDeathParticle" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.particlePosition = self.position;
    //myParticle.particleBirthRate = 5;
    [self.parent addChild:myParticle];
    [self removeFromParent];
}
@end
