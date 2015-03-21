#import "cocos2d.h"
#import <CCActionInterval.h>
#import "ccConfig.h"
#import <iAd/iAd.h>

@interface MainScene : CCNode <CCPhysicsCollisionDelegate, ADBannerViewDelegate>{
    ADBannerView *_adView;
}

@property(nonatomic,retain)IBOutlet ADBannerView *_adView;

@end;
