//
//  GameScene.h
//  Ploon
//

//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "PLAnalogStick.h"

#import "Ploon.h"



@class GameScene;
@protocol GameSceneDelegate <NSObject>
-(void) gameSceneGameDidEnd:(GameScene *) gameScene;
@end

@interface GameScene : SKScene <PLAnalogStickDelegate, SKPhysicsContactDelegate>
@property (nonatomic, strong) NSArray *enemies;
@property (nonatomic, readonly) CGPoint playerPosition;
@property (nonatomic, weak) id <GameSceneDelegate> gameDelegate;
- (void) cleanup;
@end
