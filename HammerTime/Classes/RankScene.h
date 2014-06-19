//
//  RankScene.h
//  HammerTime
//
//  Created by JH Lee on 2014. 5. 22..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface RankScene : CCScene <CCTableViewDataSource, CCScrollViewDelegate> {

}

// -----------------------------------------------------------------------

+ (RankScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end
