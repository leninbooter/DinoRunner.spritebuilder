//
//  Robot.m
//  DinoRunner
//
//  Created by kembikio on 7/3/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Robot.h"

@implementation Robot

-(void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"robot";
    self.physicsBody.sensor = TRUE;
}

@end
