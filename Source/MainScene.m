#import "MainScene.h"
#import "cocos2d.h"
#import <CCActionInterval.h>
#import "ccConfig.h"
#import "../Obstacle.h"
#import <CCDirector.h>
#import "CCBReader.h"

static const CGFloat scrollSpeed = 300.f;
CGFloat firstObstaclePosition;
static const CGFloat distanceBetweenObstacles = 220.f;
BOOL playing = false;
CGSize winSize;
NSInteger obstaclesMaxQt;
NSString *obstacles_cbs[2]  = {@"Obstacle", @"obstacle_triangle"};
NSString *weapons_cbs[1]    = {@"weapon_fireball"};
BOOL jumping = false;

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_startButton;
    
    //CCNode *_goal;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    //UISwipeGestureRecognizer *swipeUp;
    NSMutableArray *_obstacles;
    NSMutableArray *_fireballs;
    NSInteger hero_y_ini_pos;
    NSInteger points;
    CCLabelTTF *score_label;
    //NSString *obstacles_cbs[2] = {@"Obstacle", @"obstacle_triangle",nil};
    //NSArray *obstacles_cbs = [NSArray arrayWithObjects:@"Obstacle",@"obstacle_triangle",nil];
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level
{
    //CCLOG(@"Game over");
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal
{
    points++;
    score_label.string = [NSString stringWithFormat:@"%d", (int)points];
    
    [self fadeText:score_label duration:1.5 curve:0 x:0 y:0 alpha:255.0];
    //CCLOG(@"colision");
    return TRUE;
}


- (void)didLoadFromCCB
{
    _grounds = @[_ground1, _ground2];
    
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;
    _hero.physicsBody.collisionType = @"hero";
    
    winSize = [CCDirector sharedDirector].viewSize;
    
    points = 0;
    score_label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%01ld", (long)points] fontName:@"Helvetica" fontSize:52];
    score_label.position = ccp((winSize.width/2), (winSize.height/4.5)*4);
    
    [score_label setOpacity:0.0];
}

- (void)fadeText:(CCLabelTTF *)progress duration:(NSTimeInterval)duration
           curve:(int)curve x:(CGFloat)x y:(CGFloat)y alpha:(float)alpha
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    progress.opacity = alpha;
    //[progress setOpacity:alpha];
    // Commit the changes
    [UIView commitAnimations];
}

- (void)launch_fb_Button_Tapped:(id)sender
{
    [self spawnNewFireball];
}

- (void)play //_startButton selector
{
    _obstacles = [NSMutableArray array];
    _fireballs = [NSMutableArray array];
    
    [self removeChild:_startButton];
    
    hero_y_ini_pos = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    
    firstObstaclePosition = (_hero.position.x - _hero.contentSize.width) + winSize.width;
    obstaclesMaxQt = ( winSize.width / (int) distanceBetweenObstacles ) * 2;
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self addChild:score_label];

    [self setup_menu];
    
    playing = true;
    //CCScene *MainScene = [CCBReader loadAsScene:@"MainScene"];
    //[[CCDirector sharedDirector] replaceScene:MainScene];
}

//-(void) addSwipeToJumpGesture {
//    swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
//    swipeUp.numberOfTouchesRequired = 1;
//    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
//}
//-(void) handleSwipeUp:(UITapGestureRecognizer *)recognizer{
//    id jump = [CCActionJumpBy actionWithDuration:0.5 position:ccp(0,1) height:80 jumps:1];
//    [_hero runAction:jump];
//}

-(void)jumpRunner
{
    //
    //    id jump = [CCActionJumpBy actionWithDuration:1.f position:ccp(0, 1)
    //                                    height:100 jumps:1];
    //    [_hero runAction:jump];
    [_hero.animationManager runAnimationsForSequenceNamed:@"jumping"];
    id Jump_Up = [CCActionJumpBy actionWithDuration:0.2f position:ccp(0,120) height:20 jumps:1];
    id jumping = [CCActionJumpBy actionWithDuration:0.3f position:ccp(0,-120) height:20 jumps:1];
    id seq = [CCActionSequence actions:Jump_Up, jumping, nil];
    [_hero runAction:seq];
}

- (void)setup_menu
{
    CCSpriteFrame * btn_sound_background = [CCSpriteFrame frameWithImageNamed:@"button_sound_small.png"];
    CCButton *btn_sound = [CCButton buttonWithTitle:@"" spriteFrame:btn_sound_background];
    
    CCSpriteFrame * btn_score_background = [CCSpriteFrame frameWithImageNamed:@"button_score_small.png"];
    CCButton *btn_score = [CCButton buttonWithTitle:@"" spriteFrame:btn_score_background];
    
    CCSpriteFrame * btn_noads_background = [CCSpriteFrame frameWithImageNamed:@"button_noads_small.png"];
    CCButton *btn_noads = [CCButton buttonWithTitle:@"" spriteFrame:btn_noads_background];
    
    CCSpriteFrame * btn_launcher_fb_background = [CCSpriteFrame frameWithImageNamed:@"button_launch_fb_small.png"];
    CCButton *btn_launch = [CCButton buttonWithTitle:@"" spriteFrame:btn_launcher_fb_background];
    [btn_launch setTarget:self selector:@selector(launch_fb_Button_Tapped:)];
    
    
    NSArray *menu_items = @[btn_sound, btn_score, btn_noads, btn_launch];
    
    CCLayoutBox *menu_box = [[CCLayoutBox alloc] init];
    menu_box.direction = CCLayoutBoxDirectionHorizontal;
    menu_box.spacing = 30.0f;
    menu_box.position = ccp(winSize.width/2, 50);
    menu_box.anchorPoint = ccp(0.5, 0.0);
    menu_box.cascadeColorEnabled = YES;
    menu_box.cascadeOpacityEnabled = YES;
    
    for(CCNode* item in menu_items)
    {
        item.cascadeColorEnabled = item.cascadeOpacityEnabled = YES;
        [menu_box addChild:item];
    }
    menu_box.opacity = 0.0f;
    
    [menu_box runAction:[CCActionFadeIn actionWithDuration:1.0f]];
    
    [self addChild:menu_box];
}

- (void)spawnNewObstacle
{
    CCNode *previousObstacle = [_obstacles lastObject];
    
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    NSInteger cb_id = arc4random_uniform(2);
    CGFloat randomDistance = arc4random_uniform(winSize.width) + distanceBetweenObstacles;
    
    Obstacle *obstacle = (Obstacle *) [CCBReader load:obstacles_cbs[cb_id]];
    obstacle.position = ccp(previousObstacleXPosition + randomDistance, 211);
    switch (cb_id) {
        case 0:
            obstacle.scale = 0.8;
            break;
            
        case 1:
            obstacle.scale = 1.4;
            break;
        default:
            break;
    }
    
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

-(void)spawnNewFireball
{
    CCNode *weapon = (CCNode *) [CCBReader load:weapons_cbs[0]];
    weapon.position = ccp(_hero.position.x + 50, _hero.position.y);
    weapon.scale = 0.3;
    weapon.physicsBody.sensor = true;
    [_physicsNode addChild:weapon];
    [_fireballs addObject:weapon];
    //    _hero.position = ccp(_hero.position.x + 5, _hero.position.y);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //[_hero.physicsBody applyImpulse:ccp(0, 10500.f)];
    // [_hero.physicsBody applyAngularImpulse:10000.f];
    //[_hero.physicsBody applyImpulse:(0, 10000.f) atWorldPoint:(0, 15000)];
    //_sinceTouch = 0.f;
    NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    if ( (hero_actual_y - hero_y_ini_pos) < 1 && !jumping)
    {
        [self jumpRunner];
    }
    
    // [self addSwipeToJumpGesture];
}

- (void)update:(CCTime)delta
{
    
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - ( scrollSpeed * delta), _physicsNode.position.y);
    // loop the ground
    for (CCNode *ground in _grounds)
    {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width))
        {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
        // clamp velocity
        float yVelocity = clampf(_hero.physicsBody.velocity.y, 0 * MAXFLOAT, 50.f);
        _hero.physicsBody.velocity = ccp(-0.5, yVelocity);
    }
    
    if(playing)
    {
        NSMutableArray *offScreenObstacles = nil;
        
        for (CCNode *obstacle in _obstacles)
        {
            CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
            CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
            
            if (obstacleScreenPosition.x < -obstacle.contentSize.width)
            {
                if (!offScreenObstacles)
                {
                    offScreenObstacles = [NSMutableArray array];
                }
                
                [offScreenObstacles addObject:obstacle];
            }
        }
        
        for (CCNode *obstacleToRemove in offScreenObstacles)
        {
            [obstacleToRemove removeFromParent];
            [_obstacles removeObject:obstacleToRemove];
            // for each removed obstacle, add a new one
            [self spawnNewObstacle];
            if(_obstacles.count < obstaclesMaxQt)
            {
                [self spawnNewObstacle];
            }
        }
        
        //Move fireballs or kick out the ones off screen
        NSMutableArray *offScreenFireballs = nil;
        for(CCNode *fireball in _fireballs)
        {
            CGPoint fireballWorldPosition = [_physicsNode convertToWorldSpace:fireball.position];
            CGPoint fireballScreenPosition = [self convertToNodeSpace:fireballWorldPosition];
            
            if ( (fireballScreenPosition.x - (fireball.contentSize.width * 0.3)) > winSize.width )
            {
                //Add off screen fb to the delay delete
                if(!offScreenFireballs)
                {
                    offScreenFireballs = [NSMutableArray array];
                }
                [offScreenFireballs addObject:fireball];
            }else{
                fireball.position = ccp(fireball.position.x + delta * (scrollSpeed*1.5), fireball.position.y);
            }
        }
        
        for(CCNode *offscreenfireball in offScreenFireballs)
        {
            [offscreenfireball removeFromParent];
            [_fireballs removeObject:offscreenfireball];
        }
        
        NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
        if( (hero_actual_y - hero_y_ini_pos) > 1)
        {
            jumping = TRUE;
        }
        
        if ( jumping )
        {
            //CCLOG(@"2) %.2ld, dif: %.2ld", (long)hero_actual_y, (long)(hero_actual_y - hero_y_ini_pos) );
            if( (hero_actual_y - hero_y_ini_pos) < 1)
            {
                [_hero.animationManager runAnimationsForSequenceNamed:@"walking"];
                jumping = false;
                
            }
        }
    }
}
@end