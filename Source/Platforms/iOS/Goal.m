//
//  Goal.m
//  DinoRunner
//
//  Created by johann casique on 28/12/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

-(void)didLoadFromCCB
{
	self.physicsBody.collisionType = @"goal";
	self.physicsBody.sensor = TRUE;
}

@end
