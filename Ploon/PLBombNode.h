//
//  PLBombNode.h
//  Ploon
//
//  Created by Lucas Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PLBombNode : SKNode
@property (nonatomic, readonly) CGFloat radius;
- (instancetype) initWithRadius:(CGFloat) radius;

@end
