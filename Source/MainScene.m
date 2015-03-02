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
BOOL playing = NO;
BOOL paused = false;
CGSize winSize;
NSInteger obstaclesMaxQt;
NSString *obstacles_cbs[3]  = {@"Obstacle", @"obstacle_triangle", @"enemy"};
NSString *weapons_cbs[1]    = {@"weapon_fireball"};
BOOL jumping = false;

@implementation MainScene {
    CCPhysicsNode *_physicsNode;

    CCSprite *_hero;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_background;
    CCNode *_startButton;
    CCNode *_btn_fire_fireball;
    CCNode *screen_pause;
    CCNode *screen_game_over;
    
    // Menus
    //CCLayoutBox *menu_box;
    CCLayoutBox *pause_menu;
    
    //CCNode *_goal;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    //UISwipeGestureRecognizer *swipeUp;
    NSMutableArray *_obstacles;
    NSMutableArray *_fireballs;
    NSMutableArray *_playing_menu_items;
    NSInteger hero_y_ini_pos;
    NSInteger points;
    CCLabelTTF *score_label;
    
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level
{
    //CCLOG(@"Game over");
    [self gameOver];
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
    
    screen_game_over = (CCNode *) [CCBReader load:@"screen_gameOver"];
}

//-(void)fadeBackground
//{
//    CCNodeColor *fadeLayer = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0 green:0 blue:0]];
//    [self addChild:fadeLayer z:7];
//    fadeLayer.opacity = 0;
//    
//    id fade   = [CCActionFadeTo actionWithDuration:1.0f opacity:160];//200 for light blur
//    id calBlk = [CCActionCallBlock actionWithBlock:^{
//        //show pause screen buttons here
//        //[self showPauseMenu];
//    }];
//    id sequen = [CCActionSequence actions:fade, calBlk, nil];
//    
//    [fadeLayer runAction:sequen];
//}

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

-(void) gameOver
{
    if(playing)
    {
    playing = NO;
    
    [_background.animationManager setPaused:true];
    screen_game_over.anchorPoint = ccp(0.5f, 0.0f);
    screen_game_over.position = ccp(winSize.width/2, winSize.height - 1);
    screen_game_over.name = @"screen_game_over";
    
    [self addChild:screen_game_over];
    [self removeChild:_btn_fire_fireball];
    
    screen_game_over.anchorPoint = ccp(0.5f, 0.5f);
    id bounce = [CCActionJumpBy actionWithDuration:0.17f position:ccp(0.f, (winSize.height/2)* -1.f) height:-180 jumps:1];
    id seq = [CCActionSequence actions:bounce, nil];
    [screen_game_over runAction:seq];
    }
}

-(void)jumpRunner
{
    [_hero.animationManager runAnimationsForSequenceNamed:@"jumping"];
    id Jump_Up = [CCActionJumpBy actionWithDuration:0.2f position:ccp(0,120) height:20 jumps:1];
    id jumping = [CCActionJumpBy actionWithDuration:0.3f position:ccp(0,-120) height:20 jumps:1];
    id seq = [CCActionSequence actions:Jump_Up, jumping, nil];
    [_hero runAction:seq];
}


- (void)launch_fb_Button_Tapped:(id)sender
{
    [self spawnNewFireball];
}

- (void)play //_startButton selector
{
    _obstacles = [NSMutableArray array];
    _fireballs = [NSMutableArray array];
    
    hero_y_ini_pos = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    
    firstObstaclePosition = (_hero.position.x - _hero.contentSize.width) + winSize.width;
    obstaclesMaxQt = ( winSize.width / (int) distanceBetweenObstacles ) * 2;
    screen_pause = (CCNode *) [CCBReader load:@"Pause"];
    _btn_fire_fireball.visible = TRUE;
    playing = YES;
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self addChild:score_label];
    [self setup_menu];
    [self removeChild:_startButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume:) name:@"resume_game_from_pause" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartGame:) name:@"restart_game" object:nil];

    
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


- (void) pause_game:(id)sender
{
    paused = true;
    
    [_hero.animationManager setPaused:true];
    [_hero stopAllActions];
    _hero.physicsBody.affectedByGravity = false;
    [_background.animationManager setPaused:true];
    [self setUserInteractionEnabled:false];
    
    screen_pause.anchorPoint = ccp(0.5f, 0.5f);
    screen_pause.position = ccp(winSize.width/2, winSize.height/2);
    screen_pause.name = @"pause_menu";
    [self addChild:screen_pause];
    
    [self removeChildByName:@"menu_box"];
}

-(void) restartGame:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

-(void)resume:(NSNotification *)notification
{
    [self removeChildByName:@"pause_menu"];
    [self setup_menu];
    [self setUserInteractionEnabled:true];
    
    _hero.physicsBody.affectedByGravity = true;
    [_hero.animationManager setPaused:false];
    _hero.physicsBody.affectedByGravity = true;
    [_background.animationManager setPaused:false];
    
    NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    if((hero_actual_y - hero_y_ini_pos) > 1)
    {
        id jumping = [CCActionJumpBy actionWithDuration:0.25f position:ccp(0,(_hero.position.y - hero_y_ini_pos)*-1) height:20 jumps:1];
        id seq = [CCActionSequence actions:jumping, nil];
        [_hero runAction:seq];
    }
    
    paused = false;
}

- (void)setup_menu
{
    CCSpriteFrame * btn_pause_sprite = [CCSpriteFrame frameWithImageNamed:@"btn_pause.png"];
    
    CCButton *btn_pause = [CCButton buttonWithTitle:@"" spriteFrame:btn_pause_sprite];
    [btn_pause setTarget:self selector:@selector(pause_game:)];

    CCLayoutBox *menu_box;
    menu_box = [[CCLayoutBox alloc] init];
    menu_box.name = @"menu_box";
    menu_box.direction = CCLayoutBoxDirectionVertical;
    menu_box.spacing    = 30.0f;
    menu_box.position = ccp(winSize.width - 20, winSize.height - 20);
    menu_box.anchorPoint = ccp(1,1);
    
    [menu_box addChild:btn_pause];
    [self addChild:menu_box];
    
}

- (void)spawnNewObstacle
{
    NSLog(@"obstacle");
    if(playing)
    {
    CCNode *previousObstacle = [_obstacles lastObject];
    
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    NSInteger cb_id = arc4random_uniform(3);
    CGFloat randomDistance = arc4random_uniform(winSize.width) + distanceBetweenObstacles;
    
    Obstacle *obstacle = (Obstacle *) [CCBReader load:obstacles_cbs[cb_id]];
    obstacle.position = ccp(previousObstacleXPosition + randomDistance, 211);
    
    switch (cb_id) {
        case 0:
            obstacle.scale = 0.8;
            break;
            
        case 1:
            obstacle.scale = 1.0;
            break;
        case 2:
            obstacle.scale = 0.4;
            obstacle.anchorPoint = ccp(0.5f, 0.0f);
            obstacle.position = ccp(previousObstacleXPosition + randomDistance, 211);
            obstacle.animationManager.playbackSpeed = 1.8f;
            break;
        default:
            break;
    }
        NSLog(@"play-add obstable to physics node");
    [_physicsNode addChild:obstacle];
            NSLog(@"play-add obstale to obstacles");
    [_obstacles addObject:obstacle];
    }
}

-(void)spawnNewFireball
{
    CCNode *weapon;
    weapon = (CCNode *) [CCBReader load:weapons_cbs[0]];
    weapon.position = ccp(_hero.position.x + 50, _hero.position.y);
    weapon.scale = 0.3;
    weapon.physicsBody.sensor = true;
    [_physicsNode addChild:weapon];
    [_fireballs addObject:weapon];
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSInteger hero_actual_y = [[NSString stringWithFormat: @"%.2f", _hero.position.y] integerValue];
    if ( (hero_actual_y - hero_y_ini_pos) < 1 && !jumping)
    {
        [self jumpRunner];
    }
}

- (void)update:(CCTime)delta
{
    if(playing && !paused )
    {
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
        
        _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y);
        _physicsNode.position = ccp(_physicsNode.position.x - ( scrollSpeed * delta), _physicsNode.position.y);
    }
    
    if(playing && !paused)
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
                //Add off screen fb to the delayed delete
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