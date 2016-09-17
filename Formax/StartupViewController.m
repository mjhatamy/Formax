//
//  StartupViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/2/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "StartupViewController.h"
#import "AppManager.h"

@interface StartupViewController ()<CAAnimationDelegate>{
    AppManager* appMngr;
    MSCognitoUserService *mscs;
}

@end

@implementation StartupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mscs = [MSCognitoUserService SharedInstance];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showMonkeyAnimation];
    
    [self performSelector:@selector(showSignAnimation) withObject:self afterDelay:2];
    
    
    
    
    //REMOVE ON PRODUCTION
    //[self performSegueWithIdentifier:@"gotoSigninViewControllerSegue" sender:self];
    
   // [mscs getCurrntUserDetailWithCompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
   //     dispatch_async(dispatch_get_main_queue(), ^{
            //[self performSegueWithIdentifier:@"gotoSigninViewControllerSegue" sender:self];
     //   });
    //}];
    
}


-(void) showSignAnimation{
    NSMutableArray *imageListNames = [[NSMutableArray alloc] init];
    for(int i=57; i > 0; i--){
        [imageListNames addObject:[NSString stringWithFormat:@"SignAnim_%d", i]];
    }
    NSMutableArray *animImages = [[NSMutableArray alloc] init];
    for(int i=0; i < imageListNames.count; i++){
        [animImages addObject:(id)[UIImage imageNamed:[imageListNames objectAtIndex:i]].CGImage ];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.duration = 57 / 25.0; // 24 frames per second
    animation.values = animImages;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    [self.signAnimImageView.layer addAnimation:animation forKey:@"animation"];
}


-(void) showMonkeyAnimation{
    NSMutableArray *imageListNames = [[NSMutableArray alloc] init];
    for(int i=0; i < 113; i++){
        [imageListNames addObject:[NSString stringWithFormat:@"MonkeyAnim_%d", i]];
    }
    NSMutableArray *animImages = [[NSMutableArray alloc] init];
    for(int i=0; i < imageListNames.count; i++){
        [animImages addObject:(id)[UIImage imageNamed:[imageListNames objectAtIndex:i]].CGImage ];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.duration = 112 / 25.0; // 24 frames per second
    animation.values = animImages;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [self.monkeyAnimView.layer addAnimation:animation forKey:@"animation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{    
    [mscs isSignedin];
    [mscs getCurrntUserDetailWithCompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [self performSegueWithIdentifier:@"gotoSigninViewControllerSegue" sender:self];
       });
    }];
    
}

-(BOOL)prefersStatusBarHidden{ return YES; }

@end
