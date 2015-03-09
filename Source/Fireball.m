//
//  Fireball.m
//  DinoRunner
//
//  Created by kembikio on 7/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Fireball.h"

@implementation Fireball

-(void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"fireball";
    self.physicsBody.sensor = TRUE;
}

@end
