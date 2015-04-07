//
//  GameOverLayer.m
//  DinoRunner
//
//  Created by kembikio on 1/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOverLayer.h"

@implementation GameOverLayer


CCLabelTTF *_go_score_label;

 

-(void)ask_restart_game
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart_game" object:self];
}

- (void)didLoadFromCCB
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(set_score_to_label:) name:@"set_score_to_label" object:nil];
}

-(void)set_score_to_label:(NSNotification *) notification
{
    
    NSLog(notification.userInfo[@"score"]);
    _go_score_label.string = notification.userInfo[@"score"];
   _go_score_label = [CCLabelTTF labelWithString:@"Score" fontName:@"Marker Felt" fontSize:24];
    _go_score_label.position = ccp(150, 200);
    [self addChild:_go_score_label];
 [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
