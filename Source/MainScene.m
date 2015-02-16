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
BOOL paused = false;
CGSize winSize;
NSInteger obstaclesMaxQt;
NSString *obstacles_cbs[2]  = {@"Obstacle", @"obstacle_triangle"};
NSString *weapons_cbs[1]    = {@"weapon_fireball"};
BOOL jumping = false;

@implementation MainScene {
    CCPhysicsNode *_physicsNode;

    CCSprite *_hero;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_background;
    CCNode *_startButton;
    
    CCNode *weapon;

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

-(void)fadeBackground
{
    CCNodeColor *fadeLayer = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0 green:0 blue:0]];
    [self addChild:fadeLayer z:7];
    fadeLayer.opacity = 0;
    
    id fade   = [CCActionFadeTo actionWithDuration:1.0f opacity:160];//200 for light blur
    id calBlk = [CCActionCallBlock actionWithBlock:^{
        //show pause screen buttons here
        //[self showPauseMenu];
    }];
    id sequen = [CCActionSequence actions:fade, calBlk, nil];
    
    [fadeLayer runAction:sequen];
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
    weapon = (CCNode *) [CCBReader load:weapons_cbs[0]];
    
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self addChild:score_label];
    [self setup_menu];
    [self removeChild:_startButton];
    
    playing = true;
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

- (void)pause_game:(id)sender
{
    paused = true;
    
    [_hero.animationManager setPaused:true];
    [_hero stopAllActions];
    _hero.physicsBody.affectedByGravity = false;
    [_background.animationManager setPaused:true];
    [self setUserInteractionEnabled:false];
    
    CCSprite *pause_bg = [CCSprite spriteWithImageNamed:@"pause_bg.png"];
    pause_bg.position = ccp(winSize.width/2, winSize.height/2);
    pause_bg.anchorPoint = ccp(0.5f, 0.5f);
    pause_bg.name = @"pause_bg";
    CCSpriteFrame *normalMap = [CCSpriteFrame frameWithImageNamed:@"normal_map.png"];
    CCEffectGlass *glassEffect = [CCEffectGlass effectWithShininess:0.1f refraction:0.1f refractionEnvironment:_hero reflectionEnvironment:_hero normalMap:normalMap];
    pause_bg.effect = glassEffect;
    
    CCSprite *pause_title = [CCSprite spriteWithImageNamed:@"pause_title.png"];
    pause_title.position = ccp(winSize.width/2, winSize.height/2 + 100);
    pause_title.anchorPoint = ccp(0.5f, 0.5f);
    pause_title.name = @"pause_title";
    
    CCSpriteFrame * btn_resume_background = [CCSpriteFrame frameWithImageNamed:@"btn_resume.png"];
    CCButton *btn_resume = [CCButton buttonWithTitle:@"" spriteFrame:btn_resume_background];
    [btn_resume setTarget:self selector:@selector(resume:)];
    
    CCSpriteFrame * btn_sound_background = [CCSpriteFrame frameWithImageNamed:@"btn_no_sound.png"];
    CCButton *btn_sound = [CCButton buttonWithTitle:@"" spriteFrame:btn_sound_background];
    
    CCSpriteFrame * btn_score_background = [CCSpriteFrame frameWithImageNamed:@"btn_score.png"];
    CCButton *btn_score = [CCButton buttonWithTitle:@"" spriteFrame:btn_score_background];
    
    CCSpriteFrame * btn_noads_background = [CCSpriteFrame frameWithImageNamed:@"btn_no_ads.png"];
    CCButton *btn_noads = [CCButton buttonWithTitle:@"" spriteFrame:btn_noads_background];
    
    /*CCSpriteFrame * btn_launcher_fb_background = [CCSpriteFrame frameWithImageNamed:@"button_launch_fb_small.png"];
     CCButton *btn_launch = [CCButton buttonWithTitle:@"" spriteFrame:btn_launcher_fb_background];
     [btn_launch setTarget:self selector:@selector(launch_fb_Button_Tapped:)];
     btn_launch.exclusiveTouch = NO;
     btn_launch.claimsUserInteraction = NO;*/
    
    CCLayoutBox *menu_pause_container   = [[CCLayoutBox alloc] init];
    menu_pause_container.direction      = CCLayoutBoxDirectionVertical;
    menu_pause_container.spacing        = 20.f;
    menu_pause_container.position               = ccp(winSize.width/2, 50);
    menu_pause_container.anchorPoint            = ccp(0.5, 0.0);
    menu_pause_container.cascadeColorEnabled    = YES;
    menu_pause_container.cascadeOpacityEnabled  = YES;
    menu_pause_container.name = @"pause_menu";
    
    CCLayoutBox *up_items   = [[CCLayoutBox alloc] init];
    up_items.direction      = CCLayoutBoxDirectionHorizontal;
    up_items.spacing        = 20.f;
    
    CCLayoutBox *down_items   = [[CCLayoutBox alloc] init];
    down_items.direction      = CCLayoutBoxDirectionHorizontal;
    down_items.spacing        = 20.f;

    NSArray *menu_items = @[btn_sound, btn_score, btn_noads];

    /*pause_menu                        = [[CCLayoutBox alloc] init];
    pause_menu.direction              = CCLayoutBoxDirectionHorizontal;
    pause_menu.spacing                = 30.0f;
    pause_menu.position               = ccp(winSize.width/2, 50);
    pause_menu.anchorPoint            = ccp(0.5, 0.0);
    pause_menu.cascadeColorEnabled    = YES;
    pause_menu.cascadeOpacityEnabled  = YES;*/
    
    
    for(CCNode* item in menu_items)
    {
        item.cascadeColorEnabled = item.cascadeOpacityEnabled = YES;
        [down_items addChild:item];
    }
    pause_menu.opacity = 0.0f;
    [pause_menu runAction:[CCActionFadeIn actionWithDuration:0.3f]];
    
    [up_items addChild:btn_resume];
    
    [menu_pause_container addChild:down_items];
    [menu_pause_container addChild:up_items];
    
    //[self addChild:pause_bg z:0];
    [self fadeBackground];
    [self addChild:pause_title z:1];
    [self addChild:menu_pause_container z:2];
    
    [self removeChildByName:@"menu_box"];
    
}

-(void) resume:(id)sender
{
    [self removeChildByName:@"pause_title"];
    [self removeChildByName:@"pause_menu"];
    [self removeChildByName:@"pause_bg"];
    [self setup_menu];
    [self setUserInteractionEnabled:true];
    
    
    _hero.physicsBody.affectedByGravity = true;
    [_hero.animationManager setPaused:false];
    _hero.physicsBody.affectedByGravity = true;
    [_background.animationManager setPaused:false];
    
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
    if( !paused )
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