//
//  GameViewController.m
//  Ploon
//
//  Created by Lucas Vicente Tenório on 11/05/15.
//  Copyright (c) 2015 Lucas Vicente Tenório. All rights reserved.
//

#import "GameViewController.h"


@interface GameViewController ()
@property (weak, nonatomic) IBOutlet SKView *gameView;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
//    self.gameView.showsFPS = YES;
//    self.gameView.showsNodeCount = YES;
//    self.gameView.showsDrawCount = YES;
    //self.gameView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    self.gameView.ignoresSiblingOrder = NO;
    //self.gameView.frameInterval = 2;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
    scene.gameDelegate = self;
    //GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [self.gameView presentScene:scene];
}
- (IBAction)pauseButtonPressed:(id)sender {
    
    self.gameView.scene.paused = !self.gameView.scene.paused;
    if (self.gameView.scene.paused) {
        self.gameView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.gameView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.gameView.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.gameView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (void) gameSceneGameDidEnd:(GameScene *)gameScene {
    //[gameScene cleanup];
    GameScene *scene = [GameScene sceneWithSize:self.view.bounds.size];
    scene.gameDelegate = self;
    //GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    // Present the scene.
    [self.gameView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    } else {
//        return UIInterfaceOrientationMaskAll;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
