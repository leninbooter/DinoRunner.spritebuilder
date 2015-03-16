//
//  GameOverLayer.m
//  DinoRunner
//
//  Created by kembikio on 1/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOverLayer.h"

@implementation GameOverLayer

-(void)ask_restart_game
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restart_game" object:self];
}

@end
