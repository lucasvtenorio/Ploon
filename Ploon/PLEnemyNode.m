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
@property (nonatomic) CGSize initialSize;
@property (nonatomic) CGSize finalSize;
@property (nonatomic) CGFloat animationDuration;

@property (nonatomic) CGVector error;
@end

@implementation PLEnemyNode
- (instancetype) init {
    if (self = [super init]) {
        
        self.shapeNode = [SKShapeNode shapeNodeWithPath:[self pathForSize:CGSizeMake(20.0, 20.0)] centered:YES];
        self.shapeNode.lineWidth = 3.0;
        self.shapeNode.glowWidth = 1.0;
        self.shapeNode.lineJoin = kCGLineJoinRound;
        self.animationDuration = 0.8;
        
        self.error = CGVectorMake([self randomFloatBetween:-50.0 and:50.0], [self randomFloatBetween:-50.0 and:50.0]);
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:9.0];
        self.physicsBody.categoryBitMask = enemyCategory;
        self.physicsBody.collisionBitMask = sceneEdgeCategory | enemyCategory | shipCategory;
        
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
        
        
        SKAction *behaviour = [SKAction performSelector:@selector(runBehaviour) onTarget:self];
        
        
        self.initialSize = CGSizeMake(120.0, 180.0);
        self.finalSize = CGSizeMake(180.0, 120.0);
        [self addChild:self.shapeNode];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[test1, test2]]]];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[behaviour, [SKAction waitForDuration:0.016 withRange:0.01]]]]];
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

- (CGPoint) point:(CGPoint) point withErrorPercentage:(CGFloat) percentage {
    CGVector error = CGVectorMake(self.error.dx * percentage, self.error.dy * percentage);
    return CGPointMake(point.x - error.dx, point.y - error.dy);
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


- (CGPoint) point:(CGPoint) point withSeekPoint:(CGPoint) seekPoint {
    CGPoint target_offset = CGPointMake(seekPoint.x - point.x, seekPoint.y - point.y);
    CGFloat distance = [self lenghtOfPoint:target_offset];
    CGFloat percentage = (MIN(distance, 20.0) / 20.0);
    return [self point:seekPoint withErrorPercentage:percentage];
}

- (void) seekPoint:(CGPoint) point {
//    Vector3 heroPosition = hero.transform.position;
//    float max_speed = this.maximumMovementSpeed;
//    float max_force = this.maximumMovementForce;
//    
//    Vector3 target_offset = heroPosition - this.transform.position;
//    float distance = target_offset.magnitude;
//    float ramped_speed = max_speed * (distance / slowingDistance);
//    float clipped_speed = Mathf.Min (ramped_speed, max_speed);
//    Vector2 desired_velocity = (clipped_speed / distance) * (new Vector2 (target_offset.x, target_offset.y));
//    Vector2 steering = desired_velocity - this.rigidbody2D.velocity;
//    Vector2 steering_force = steering.normalized * max_force;
//    this.rigidbody2D.AddForce (steering_force);
    // point = [self point:self.position withSeekPoint:point];
    CGFloat max_speed = 200.0;
    CGFloat max_force = 30.0;
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
