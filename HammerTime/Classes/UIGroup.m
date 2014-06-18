//
//  UIGroup.m
//  HammerTime
//
//  Created by Chrome-MBPR on 6/8/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "UIGroup.h"

@interface UIGroup (private) {

}

@end

@implementation UIGroup {
    CCProgressNode *_timerGauge;
    CCSprite *_timerBarSprite;
    CCSprite *_timerBGSprite;

    CCProgressNode *_comboGauge;    
    CCSprite *_comboBarSprite;
    CCSprite *_comboBGSprite;
    CCSprite *_comboFHSprite;
    CCActionSequence* _comboFHBeatAction;
    float _comboFHoriginalScale;
    
    CCSpriteBatchNode* _startCountSpriteBatchNode;
    NSMutableArray* startCountFrameArray;
    CCSprite* _startCountSprite;
    CCActionSequence* _startCountAction;
    int _frameNumber;
    
    id _scoreLabel;
    
    id _streakLabel;
    CCSprite* _streakLabelSprite;
    CCActionSequence* _streakLabelAction;
    bool _isStreakLabelActionActive;
    
    CCAction* _comboBGFadeIn;
    bool _isComboBGFadeInActive;
    CCAction* _comboBGFadeOut;
    bool _isComboBGFadeOutActive;
    
    GameSetting* _gSetSO;

}



- (UIGroup*)init {
    if( [self class] == [UIGroup class]) {
        NSAssert(false, @"You must not use -(id)init method to initialize a UIGroup object. Use initWithAttachedScene: instead.\n");
        self = nil;
    }
    else {
        self = [super init];
    }
    
    return self;
}



- (UIGroup*)initWithAttachedScene:(CCScene*)attachedScene {
    self = [super init];
    if (!self) return(nil);
    
    _attachedScene = attachedScene;
    _gSetSO = [GameSetting shared];
    
    // 타이머 바 형성부
    _timerBarSprite = [CCSprite spriteWithImageNamed:_gSetSO.timerBarTextureFile];
    NSAssert(_timerBarSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _timerBarSprite.\n");
    _timerBGSprite = [CCSprite spriteWithImageNamed:_gSetSO.timerBGTextureFile];
    NSAssert(_timerBGSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _timerBGSprite.\n");
    
    _timerBGSprite.anchorPoint = _gSetSO.timerAnchorPoint;
    _timerBGSprite.position = _gSetSO.timerPosition;
    [attachedScene addChild:_timerBGSprite z:_gSetSO.timerBGZOrder];
    
    _timerGauge = [CCProgressNode progressWithSprite:_timerBarSprite];
    NSAssert(_timerGauge != nil, @"UIGroup initWithAttachedScene: failed to allocate _timerGauge.\n");
    _timerGauge.anchorPoint = _gSetSO.timerAnchorPoint;
    _timerGauge.position = _gSetSO.timerPosition;
    _timerGauge.type = CCProgressNodeTypeBar;
    _timerGauge.midpoint = ccp(0.0f, 0.5f);
    _timerGauge.barChangeRate = ccp(1.0f, 0.0f);
    [attachedScene addChild:_timerGauge z:_gSetSO.timerBarZOrder];
    
    
    
    // 콤보 바 형성부
    _comboBarSprite = [CCSprite spriteWithImageNamed:_gSetSO.comboBarTextureFile];
    NSAssert(_comboBarSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboBarSprite.\n");
    _comboBGSprite = [CCSprite spriteWithImageNamed:_gSetSO.comboBGTextureFile];
    NSAssert(_comboBGSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboBGSprite.\n");
    
    _comboBGSprite.anchorPoint = _gSetSO.comboAnchorPoint;
    _comboBGSprite.position = _gSetSO.comboPosition;
    [attachedScene addChild:_comboBGSprite z:_gSetSO.comboBGZOrder];
    
    _comboFHSprite = [CCSprite spriteWithImageNamed:_gSetSO.comboFHTextureFile];
    NSAssert(_comboFHSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboFHSprite.\n");
    
    _comboGauge = [CCProgressNode progressWithSprite:_comboBarSprite];
    NSAssert(_comboGauge != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboGauge.\n");
//    _comboGauge.anchorPoint = _gSetSO.comboAnchorPoint;
    _comboFHoriginalScale = 1 / _gSetSO.comboFHScaleSize;
    float comboFHWidth_Scaled =_comboFHSprite.contentSize.width * _comboFHoriginalScale;
    _comboGauge.anchorPoint = ccp((_gSetSO.comboAnchorPoint.x * 2.0f * (comboFHWidth_Scaled + _comboGauge.contentSize.width/2.0f) - 0.5f * (1.0f - _gSetSO.comboFHPositionModifier) * comboFHWidth_Scaled) / _comboGauge.contentSize.width, _gSetSO.comboAnchorPoint.y);
    _comboGauge.anchorPoint = _gSetSO.comboAnchorPoint;
    _comboGauge.position = _gSetSO.comboPosition;
    _comboGauge.type = CCProgressNodeTypeBar;
    _comboGauge.midpoint = ccp(0.0f, 0.5f);
    _comboGauge.barChangeRate = ccp(1.0f, 0.0f);
    
//    CGPoint comboFHPosition = ccp(_comboGauge.position.x + (_gSetSO.comboFHPositionModifier) * _comboGauge.contentSize.width/2, _comboGauge.position.y + _comboGauge.contentSize.height/2);
//    _comboFHoriginalScale = 1 / _gSetSO.comboFHScaleSize;
    _comboFHSprite.scale = _comboFHoriginalScale;
    CGPoint comboFHPosition = ccp(_comboGauge.position.x + (_gSetSO.comboFHPositionModifier) * 0.5f * (_comboGauge.contentSize.width + comboFHWidth_Scaled), _comboGauge.position.y + _comboGauge.contentSize.height/2);
    _comboFHSprite.position = comboFHPosition;
    
    _comboFHBeatAction = [CCActionSequence actions:
                                    [CCActionScaleTo actionWithDuration:_gSetSO.comboFHScaleDuration/2 scale:1],
                                    [CCActionScaleTo actionWithDuration:_gSetSO.comboFHScaleDuration/2 scale:_comboFHSprite.scale],
                                    nil];
    NSAssert(_comboFHBeatAction != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboFHBeatAction.\n");
    
    
    
    // 스타트 카운트 스프라이트 생성부
    _startCountSpriteBatchNode = [[CCSpriteBatchNode alloc] initWithFile:_gSetSO.startCountTextureFile capacity:1];
    NSAssert(_startCountSpriteBatchNode != nil, @"UIGroup initWithAttachedScene: failed to allocate _startCountSpriteBatchNode.\n");
    
    startCountFrameArray = [NSMutableArray array];
    if (startCountFrameArray == nil) {
        NSAssert(false, @"UIGroup initWithAttachedScene: failed to load frames.");
        return nil;
    }
    
    // 프레임 로딩부: 만일 스프라이트 시트 파일의 배열 방법이 바뀌었다면, 이 메소드 호출부도 바꾸어야 한다.
    [[GameCommon shared] loadFrameFromSprite:_startCountSpriteBatchNode.texture
                             withTargetArray:startCountFrameArray
                                withTopLeftX:0
                                withTopLeftY:0
                                   withSizeX:_gSetSO.startCountPixelSizeX
                                   withSizeY:_gSetSO.startCountPixelSizeY
                         withHorizontalCount:_gSetSO.startCountFrameCount
                           withVerticalCount:1
                isLoadingDirectionHorizontal:true
                         withTotalFrameCount:_gSetSO.startCountFrameCount];
    
    _startCountSprite = [CCSprite spriteWithSpriteFrame:[startCountFrameArray objectAtIndex:0]];
    NSAssert(_startCountSprite != nil, @"UIGroup initWithAttachedScene: failed to allocate _startCountSprite.\n");
    _startCountSprite.anchorPoint = _gSetSO.startCountAnchorPoint;
    _startCountSprite.position = _gSetSO.startCountPosition;
    
    // 스타트 카운터의 액션 생성부
    _frameNumber = 0;
    // 아래의 혼란스러움이 바로 내가 CCActionCallBlock을 별로 안 좋아 하는 이유다.
    _startCountAction = [CCActionSequence actions:
                         [CCActionCallBlock actionWithBlock:^
    {
        [_startCountSprite setSpriteFrame:[startCountFrameArray objectAtIndex:_frameNumber]];
        _frameNumber++;
        [[GameCommon shared] playSound:_gSetSO.soundStartCountTick];

    }],
                         [CCActionJumpBy actionWithDuration:_gSetSO.startCountTimePerFrame/2.0f
                                                   position:ccp(0.0f, 0.0f)
                                                     height:_gSetSO.startCountJumpHeight
                                                      jumps:1],
                         nil];
    NSAssert(_startCountAction != nil, @"UIGroup initWithAttachedScene: failed to allocate _startCountAction.\n");

    CCActionRepeat* _startCountActionInner = [CCActionRepeat actionWithAction:_startCountAction
                                                                        times:_gSetSO.startCountFrameCount - 1];
    NSAssert(_startCountActionInner != nil, @"UIGroup initWithAttachedScene: failed to allocate _startCountActionInner.\n");
    _startCountAction = [CCActionSequence actions:_startCountActionInner,
                         [CCActionCallBlock actionWithBlock:^
    {
        [_startCountSprite setSpriteFrame:[startCountFrameArray objectAtIndex:_frameNumber]];
        _frameNumber++;
        [[GameCommon shared] playSound:_gSetSO.soundStartCountComplete];
        
    }],
                         [CCActionSpawn actions:
                          [CCActionScaleBy actionWithDuration:_gSetSO.startCountFadeDuration
                                                        scale:_gSetSO.startCountScaleSize],
                          [CCActionFadeOut actionWithDuration:_gSetSO.startCountFadeDuration],
                          nil],
                         nil];
    NSAssert(_startCountAction != nil, @"UIGroup initWithAttachedScene: failed to allocate _startCountAction.\n");
    
    
    // 점수 라벨 생성
    if ([GameSetting shared].isScoreFontSprite) {
        NSAssert(false, @"UIGroup: Tried to use a sprite with the score label. This function is not built yet.");
    }
    else {
        _scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"0"]
                                         fontName:_gSetSO.ScoreLabelTTFFontName
                                         fontSize:_gSetSO.ScoreLabelTTFFontSize];
        ((CCLabelTTF*)_scoreLabel).color = _gSetSO.ScoreLabelTTFColor;
        ((CCLabelTTF*)_scoreLabel).anchorPoint = _gSetSO.ScoreLabelAnchorPoint;
        ((CCLabelTTF*)_scoreLabel).position =_gSetSO.ScoreLabelPosition;
    }
    
    // 콤보 라벨 생성
    if ([GameSetting shared].isStreakFontSprite) {
        NSAssert(false, @"UIGroup: Tried to use a sprite with the combo label. This function is not built yet.");
    }
    else {
        _streakLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@""]
                                         fontName:_gSetSO.streakLabelTTFFontName
                                         fontSize:_gSetSO.streakLabelTTFFontSize];
        _streakLabelSprite = _streakLabel;
        _streakLabelSprite.color = _gSetSO.streakLabelTTFColor;
        _streakLabelSprite.anchorPoint = _gSetSO.streakLabelAnchorPoint;
        _streakLabelSprite.position =_gSetSO.streakLabelPosition;
    }
    _streakLabelSprite.visible = false;
    _streakLabelSprite.opacity = 0.0f;
    _isStreakLabelActionActive = false;
    _streakLabelAction = [CCActionSequence actions:
                          [CCActionCallBlock actionWithBlock:^{
        _streakLabelSprite.position = _gSetSO.streakLabelPosition;
        _streakLabelSprite.visible = true;
        _streakLabelSprite.opacity = 1.0f;
        _isStreakLabelActionActive = true;
    }],
                          [CCActionJumpBy actionWithDuration:_gSetSO.streakLabelJumpDuration position:ccp(0.0f, 0.0f) height:_gSetSO.streakLabelJumpHeight jumps:1],
                          [CCActionDelay actionWithDuration:_gSetSO.streakLabelFadeDelay],
                          [CCActionSpawn actions:
                           [CCActionMoveBy actionWithDuration:_gSetSO.streakLabelFadeDuration position:ccp(0.0f, _gSetSO.streakLabelJumpHeight)],
                           [CCActionFadeOut actionWithDuration:_gSetSO.streakLabelFadeDuration],
                           nil],
                          [CCActionCallBlock actionWithBlock:^{
        _streakLabelSprite.visible = false;
        _isStreakLabelActionActive = false;
    }],
                          nil];
    
    _backgroundComboNode = [CCNode node];
    NSAssert(_backgroundComboNode != nil, @"UIGroup initWithAttachedScene: failed to allocate _backgroundComboNode.\n");
    _backgroundComboNode.visible = false;
    _backgroundComboNode.cascadeOpacityEnabled = true;
    _backgroundComboNode.opacity = 0.0f;
    _isComboBGFadeInActive = false;
    _isComboBGFadeOutActive = false;
    
    _backgroundNode = [CCNode node];
    NSAssert(_backgroundNode != nil, @"UIGroup initWithAttachedScene: failed to allocate _backgroundNode.\n");
    
    _backgroundUpperNode = [CCNode node];
    NSAssert(_backgroundUpperNode != nil, @"UIGroup initWithAttachedScene: failed to allocate _backgroundUpperNode.\n");
    
    _backgroundUINode = [CCNode node];
    NSAssert(_backgroundUINode != nil, @"UIGroup initWithAttachedScene: failed to allocate _backgroundUINode.\n");
    
    // 생성된 객체들을 이 UI그룹이 소속된 CCScene 객체에 연결한다.
    [_attachedScene addChild:_backgroundNode z:_gSetSO.backgroundZOrder];
    [_attachedScene addChild:_backgroundUpperNode z:_gSetSO.backgroundUpperZOrder];
    [_attachedScene addChild:_backgroundComboNode z:_gSetSO.backgroundComboZOrder];
    [_attachedScene addChild:_comboGauge z:_gSetSO.comboBarZOrder];
    [_attachedScene addChild:_comboFHSprite z:_gSetSO.comboFHZOrder];
    [_attachedScene addChild:_scoreLabel z:_gSetSO.ScoreLabelZOrder];
    [_attachedScene addChild:_streakLabel z:_gSetSO.streakLabelZOrder];
    [_attachedScene addChild:_backgroundUINode z:_gSetSO.backgroundUIZOrder];
    return self;
}



- (void)initComboBarWithPercentage:(double)percentage {
    _comboGauge.percentage = percentage;
}



- (void)updateComboBarWithPercentage:(double)percentage {
    _comboGauge.percentage = percentage;
    if (![_comboFHBeatAction isDone])
    {
        [_comboFHSprite stopAction:_comboFHBeatAction];
    }
    
    _comboFHBeatAction = [CCActionSequence actions:
                          [CCActionScaleTo actionWithDuration:(_gSetSO.comboFHScaleDuration/2 * (1 - _comboFHSprite.scale) / (1 - _comboFHoriginalScale)) scale:1],
                          [CCActionScaleTo actionWithDuration:_gSetSO.comboFHScaleDuration/2 scale:_comboFHoriginalScale],
                          nil];
    NSAssert(_comboFHBeatAction != nil, @"UIGroup initWithAttachedScene: failed to allocate _comboFHBeatAction.\n");
    
    [_comboFHSprite runAction:_comboFHBeatAction];
}


- (void)updateTimerBarWithPercentage:(double)percentage {
    _timerGauge.percentage = percentage;
}

- (void)startCountBegin {
    [_attachedScene addChild:_startCountSprite z:_gSetSO.startCountZOrder];
    [_startCountSprite runAction:_startCountAction];
}

- (void)updateScoreLabel:(unsigned int)score {
    [_scoreLabel setString:[NSString stringWithFormat:@"%d", score]];
}

- (void)showComboBG {
    if (_isComboBGFadeOutActive) {
        [_backgroundComboNode stopAction:_comboBGFadeOut];
        _isComboBGFadeOutActive = false;
    }
    if (!_isComboBGFadeInActive && !(_backgroundComboNode.visible)) {
        _isComboBGFadeInActive = true;
        _backgroundComboNode.visible = true;
        _comboBGFadeIn = [CCActionSequence actions:
        [CCActionFadeIn actionWithDuration:_gSetSO.backgroundComboFadeEffectDuration * (1.0f - _backgroundComboNode.opacity)],
                          [CCActionCallBlock actionWithBlock:^{
            _isComboBGFadeInActive = false;
        }],
                          nil];
        [_backgroundComboNode runAction:_comboBGFadeIn];
    }
}

- (void)hideComboBG {
    if (_isComboBGFadeInActive) {
        [_backgroundComboNode stopAction:_comboBGFadeIn];
        _isComboBGFadeInActive = false;
    }
    if (!_isComboBGFadeOutActive && _backgroundComboNode.visible) {
        _isComboBGFadeOutActive = true;
        _comboBGFadeOut = [CCActionSequence actions:
                           [CCActionFadeOut actionWithDuration:_gSetSO.backgroundComboFadeEffectDuration * _backgroundComboNode.opacity],
                           [CCActionCallBlock actionWithBlock:^{
            _backgroundComboNode.visible = false;
            _isComboBGFadeOutActive = false;
        }],
                           nil];
        [_backgroundComboNode runAction:_comboBGFadeOut];
    }
}

- (void)updateStreakLabel:(unsigned int)streak {
    [_streakLabel setString:[NSString stringWithFormat:@"%d", streak]];
    if (_isStreakLabelActionActive) {
        [_streakLabelSprite stopAction:_streakLabelAction];
    }
    [_streakLabelSprite runAction:_streakLabelAction];
}

@end
