//
//  UIGroup.h
//  HammerTime
//
//  Created by Chrome-MBPR on 6/8/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GameSetting.h"

@interface UIGroup : NSObject {
    CCScene* _attachedScene;
    CCNode* _backgroundNode;
    CCNode* _backgroundComboNode;
    CCNode* _backgroundUINode;
    CCNode* _backgroundUpperNode;
}

@property (nonatomic, readonly) CCNode* backgroundNode;
@property (nonatomic, readonly) CCNode* backgroundComboNode;
@property (nonatomic, readonly) CCNode* backgroundUINode;
@property (nonatomic, readonly) CCNode* backgroundUpperNode;
- (UIGroup*)initWithAttachedScene:(CCScene*)attachedScene;
- (void)initComboBarWithPercentage:(double)percentage;
- (void)updateComboBarWithPercentage:(double)percentage;
- (void)updateTimerBarWithPercentage:(double)percentage;
- (void)updateScoreLabel:(unsigned int)score;
- (void)updateStreakLabel:(unsigned int)streak;
- (void)startCountBegin;
- (void)showComboBG;
- (void)hideComboBG;

@end
