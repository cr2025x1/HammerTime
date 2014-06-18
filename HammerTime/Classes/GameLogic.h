//
//  GameLogic.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/30/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameCommon.h"
#import "GameSetting.h"
#import "BlockGroup.h"
#import "ButtonGroup.h"
#import "UIGroup.h"
//#import "GameScene.h"

@interface GameLogic : NSObject {
    unsigned int _userScore;
    unsigned int _userCombo;
    double* _rateArray;
    unsigned int _arrayElementCount;
    unsigned int _specBlockIndex;
    unsigned int _regularBlockTypeCount;
//    bool _isComboFull;
    float _specBlkP;
    bool* _isBlockUnlocked;
    unsigned int _blockUnlockCount;
    unsigned int _blockColorUnlockCount;
    BlockGroup* _blockGroup;
    ButtonGroup* _buttonGroup;
    UIGroup* _uiGroup;
    bool* _isButtonUnlocked;
    SEL* _blockEffectSelectorArray;
    double _remainingTime;
    CCScene* _attachedScene;
    bool _isGameActive;
//    bool _isGameStarted;
    OALSimpleAudio* _audioEngine;
    unsigned int _userHitStreak;
}

@property (nonatomic, readonly) unsigned int userScore;
- (GameLogic*)initWithBlockGroup:(BlockGroup*)blockGroup
                     buttonGroup:(ButtonGroup*)buttonGroup
                         uiGroup:(UIGroup*)uiGroup
                   attachedScene:(CCScene*)attachedScene;
- (void)touchEventHandlerWithCGPoint:(CGPoint)touchPoint;
- (void)updatedTimeHandler: (CCTime)deltaTime;
- (void)startGame;
- (void)gameOverEventHandler;

@end
