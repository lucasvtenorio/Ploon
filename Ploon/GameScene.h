//
//  GameScene.h
//  Ploon
//

//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PLAnalogStick.h"

static const uint8_t shipCategory = 1;
static const uint8_t enemyCategory = 2;
static const uint8_t sceneEdgeCategory = 3;



@interface GameScene : SKScene <PLAnalogStickDelegate>
@property (nonatomic, strong) NSArray *enemies;
@property (nonatomic, readonly) CGPoint playerPosition;
@end
