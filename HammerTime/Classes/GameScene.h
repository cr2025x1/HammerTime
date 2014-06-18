//
//  GameScene.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright cr2025x1 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "BlockGroup.h"
#import "ButtonGroup.h"
#import "GameLogic.h"
#import "UIGroup.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */

// 인터페이스 시작 선언부의 프로토콜 삽입부에 주목
@interface GameScene : CCScene <GameOverEventProtocol, SoundFadeProtocol> {
    GameLogic* _gameLogic;
    ButtonGroup* _buttonGroup;
    BlockGroup* _blockGroup;
    UIGroup* _uiGroup;
}

// -----------------------------------------------------------------------

+ (GameScene *)scene;
- (void) gameOverEventHandler;
- (void)soundFadeEventHandlerWithDuration:(float)duration;
- (void)soundFadeEventHandlerInner;
- (void)setBackground;
- (void)setBackgroundCombo;
- (void)setBackgroundUI;
- (void)setBackgroundUpper;
- (id)init;

// -----------------------------------------------------------------------
@end