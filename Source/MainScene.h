#import "cocos2d.h"
#import <CCActionInterval.h>
#import "ccConfig.h"
#import <iAd/iAd.h>

@interface MainScene : CCNode <CCPhysicsCollisionDelegate, ADBannerViewDelegate>{
}

@property(nonatomic,retain)IBOutlet ADBannerView *adView;

@end;
