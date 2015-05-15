//
//  PLPlayerNode.h
//  Ploon
//
//  Created by Lucas Vicente Tenório on 13/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface PLPlayerNode : SKNode
@property (nonatomic, readonly) CGSize size;
- (instancetype) initWithSize:(CGSize) size;
-(void) animateAppearance;
- (void) animateDeath;
@end
