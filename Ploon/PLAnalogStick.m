//
//  PLAnalogStick.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 12/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "PLAnalogStick.h"
#import "Ploon.h"


const NSTimeInterval kThumbSpringBackDuration = 0.15;

@interface PLAnalogStick ()
@property (nonatomic, strong) CADisplayLink *velocityLoop;
@property (nonatomic, strong) SKNode *backgroundNode;
@property (nonatomic, strong) SKNode *thumbNode;



@property (nonatomic) BOOL isTracking;
@property (nonatomic) CGPoint velocity;
@property (nonatomic) CGPoint anchorPointInPoints;
@property (nonatomic) CGFloat angularVelocity;

@property (nonatomic) CGSize backgroundNodeSize;
@property (nonatomic) CGSize thumbNodeSize;;

@end

@implementation PLAnalogStick

#pragma Initialization

- (instancetype) init {
    if (self = [super init]) {
        [self commonInit];
        [self setupWithImages];
    }
    return self;
}

- (instancetype) initWithBackgroundSize:(CGSize) backgroundSize andThumbSize:(CGSize) thumbSize {
    if (self = [super init]) {
        [self commonInit];
        self.backgroundNodeSize = backgroundSize;
        self.thumbNodeSize = thumbSize;
        [self setupWithShapes];
    }
    return self;
    
}

- (void) setupWithShapes{
    SKShapeNode *backgroundShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.backgroundNodeSize.width/2.0];
    backgroundShapeNode.fillColor = [UIColor ploomAnalogBackgroundFillColor];
    backgroundShapeNode.strokeColor = [UIColor ploomAnalogBackgroundStrokeColor];
    
    SKShapeNode *thumbShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:self.thumbNodeSize.width/2.0];
    thumbShapeNode.strokeColor = [UIColor ploomAnalogThumbStrokeColor];
    thumbShapeNode.fillColor = [UIColor ploomAnalogThumbFillColor];
    
    self.backgroundNode = backgroundShapeNode;
    self.thumbNode = thumbShapeNode;
    [self addChild:self.backgroundNode];
    [self addChild:self.thumbNode];
}

- (void) setupWithImages {
    self.backgroundNode = [SKSpriteNode node];
    self.thumbNode = [SKSpriteNode node];
    [self setThumbImage:nil sizeToFit:YES];
    [self setBackgroundImage:nil sizeToFit:YES];
    [self addChild:self.backgroundNode];
    [self addChild:self.thumbNode];
    self.backgroundNodeSize = ((SKSpriteNode *)self.backgroundNode).size;
    self.thumbNodeSize = ((SKSpriteNode *)self.thumbNode).size;
}

- (void) commonInit{
    self.zPosition = 6;
    _isTracking = NO;
    _velocity = CGPointZero;
    _anchorPointInPoints = CGPointZero;
    _angularVelocity = 0.0;
    self.userInteractionEnabled = YES;
    self.velocity = CGPointZero;
    self.isTracking = NO;
    self.alpha = 0.4;
}

- (void) reset {
    self.isTracking = NO;
    self.velocity = CGPointZero;
    SKAction *easeOut = [SKAction moveTo:self.anchorPointInPoints duration:kThumbSpringBackDuration];
    easeOut.timingMode = SKActionTimingEaseOut;
    [self.thumbNode runAction:easeOut];
    self.alpha = 0.2;
}

#pragma mark - Properties

- (BOOL) thumbNodeIsSprite{
    return [self.thumbNode isKindOfClass:[SKSpriteNode class]];
}

- (BOOL) backgroundNodeIsSprite {
    return [self.backgroundNode isKindOfClass:[SKSpriteNode class]];
}

- (CGFloat) thumbNodeDiameter {
    return self.thumbNodeSize.width;
}

- (CGFloat) backgroundNodeDiameter {
    return self.backgroundNodeSize.width;
}

- (void) setThumbNodeDiameter:(CGFloat)thumbNodeDiameter {
    if ([self thumbNodeIsSprite]) {
        ((SKSpriteNode *)self.thumbNode).size = CGSizeMake(thumbNodeDiameter, thumbNodeDiameter);
    }
    self.thumbNodeSize = CGSizeMake(thumbNodeDiameter, thumbNodeDiameter);
}



- (void) setBackgroundNodeDiameter:(CGFloat)backgroundNodeDiameter {
    if ([self backgroundNodeIsSprite]) {
        ((SKSpriteNode *)self.backgroundNode).size = CGSizeMake(backgroundNodeDiameter, backgroundNodeDiameter);
    }
    self.backgroundNodeSize = CGSizeMake(backgroundNodeDiameter, backgroundNodeDiameter);
}

- (void) setThumbImage:(UIImage *) image sizeToFit:(BOOL) sizeToFit{
    if ([self thumbNodeIsSprite]) {
        UIImage *tImage = image != nil ? image : [UIImage imageNamed:@"aSThumbImg"];
        ((SKSpriteNode *)self.thumbNode).texture = [SKTexture textureWithImage:tImage];
        if (sizeToFit) {
            self.thumbNodeDiameter = MIN(tImage.size.width, tImage.size.height);
        }
    }
}

- (void) setBackgroundImage:(UIImage *) image sizeToFit:(BOOL) sizeToFit{
    if ([self backgroundNodeIsSprite]) {
        UIImage *tImage = image != nil ? image : [UIImage imageNamed:@"aSBgImg"];
        ((SKSpriteNode *)self.backgroundNode).texture = [SKTexture textureWithImage:tImage];
        if (sizeToFit) {
            self.backgroundNodeDiameter = MIN(tImage.size.width, tImage.size.height);
        }
    }
}

#pragma mark - Delegate

- (void) setDelegate:(id<PLAnalogStickDelegate>)delegate {
    _delegate = delegate;
    if (self.velocityLoop) {
        [self.velocityLoop invalidate];
    }
    self.velocityLoop = nil;
    if (self.delegate) {
        self.velocityLoop = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        [self.velocityLoop addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void) update {
    if (_isTracking) {
        if (self.delegate) {
            [self.delegate analogStick:self movedWithVelocity:self.velocity andAngularVelocity:self.angularVelocity];
        }
    }
}


#pragma mark - Touches Begin

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *touchedNode = [self nodeAtPoint:location];
        if (self.isTracking == NO ){//&& touchedNode == self.thumbNode) {
            self.isTracking = YES;
            self.alpha = 1.0;
        }
    }
}

#pragma mark - Touches Moved

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGFloat xDistance = location.x - self.thumbNode.position.x;
        CGFloat yDistance = location.y - self.thumbNode.position.y;
        if (self.isTracking && sqrt(xDistance *xDistance  + yDistance *yDistance) <= self.backgroundNodeDiameter * 2) {
            CGFloat xAnchorDistance = location.x - self.anchorPointInPoints.x;
            CGFloat yAnchorDistance = location.y - self.anchorPointInPoints.y;
            CGFloat magV = sqrt(xAnchorDistance * xAnchorDistance + yAnchorDistance * yAnchorDistance);
            if (magV <= self.thumbNodeSize.width) {
                CGPoint moveDifference = CGPointMake(xAnchorDistance , yAnchorDistance);
                self.thumbNode.position = CGPointMake(self.anchorPointInPoints.x + moveDifference.x, self.anchorPointInPoints.y + moveDifference.y);
            }else{
                CGFloat aX = self.anchorPointInPoints.x + xAnchorDistance / magV * self.thumbNodeSize.width;
                CGFloat aY = self.anchorPointInPoints.y + yAnchorDistance / magV * self.thumbNodeSize.height;
                self.thumbNode.position = CGPointMake(aX, aY);
            }
            CGFloat tNAnchPoinXDiff  = self.thumbNode.position.x - self.anchorPointInPoints.x;
            CGFloat tNAnchPoinYDiff = self.thumbNode.position.y - self.anchorPointInPoints.y;
            self.velocity = CGPointMake(tNAnchPoinXDiff, tNAnchPoinYDiff);
            self.angularVelocity = -atan2f(tNAnchPoinXDiff, tNAnchPoinYDiff);
            
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reset];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self reset];
}

@end
