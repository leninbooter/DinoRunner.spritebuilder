//
//  PauseLayer.m
//  DinoRunner
//
//  Created by kembikio on 22/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PauseLayer.h"

@implementation PauseLayer

-(void)ask_resume_game
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resume_game_from_pause" object:self];
}

-(void)score
{
    
}

-(void)sound
{
    
}
@end
