//
//  HowtoGroup.m
//  HammerTime
//
//  Created by ivis lab on 2014. 6. 18..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "HowtoGroup.h"
#import "GameScene.h"
#import "MenuScene.h"

@interface HowtoGroup (private)

- (void)createBackground;
- (void)creatEffect;
- (void)createSprite;
- (void)createButton;

@end

@implementation HowtoGroup {
    
    CCSprite* _background;
    CCSprite* _howtoSprite;
    CCSprite* _effectSprite;
    
    CCButton* _gameSceneButton;
    CCButton* _xButton;
    
    CCActionRotateBy *actionSpin;
    
    OALSimpleAudio *effectAudio;
}

-(HowtoGroup*)init {
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);
    
    [self createBackground];
    [self creatEffect];
    [self createSprite];
    [self createButton];
    
    return self;
}

- (void)createEffectBGM
{
    effectAudio = [OALSimpleAudio sharedInstance];
    [effectAudio playEffect:@"Break.mp3"];
}

// -----------------------------------------------------------------------
#pragma mark - Create Gackground
// -----------------------------------------------------------------------

- (void)createBackground
{
    _background = [CCSprite spriteWithImageNamed:@"bg-menu.png"];
    _background.anchorPoint = ccp(0.5f, 0.5f);
    _background.positionType = CCPositionTypeNormalized;
    _background.position = ccp(0.5f, 0.5f);
    [self addChild:_background z:0];
}

// -----------------------------------------------------------------------
#pragma mark - Create Gackground Effect
// -----------------------------------------------------------------------

- (void)creatEffect
{
    _effectSprite = [CCSprite spriteWithImageNamed:@"effect-menu.png"];
    _effectSprite.anchorPoint = ccp(0.5f, 0.5f);
    _effectSprite.positionType = CCPositionTypeNormalized;
    _effectSprite.position = ccp(0.42f, 0.19f);
    [self addChild:_effectSprite z:10];
    
    actionSpin = [CCActionRotateBy actionWithDuration:5.0f angle:360];
    [_effectSprite runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
}

- (void)createSprite
{
    _howtoSprite = [CCSprite spriteWithImageNamed:@"howto-menu.png"];
    _howtoSprite.positionType = CCPositionTypeNormalized;
    _howtoSprite.anchorPoint = ccp(0.5f, 0.5f);
    _howtoSprite.position = ccp(0.5f, 0.5f);
    [self addChild:_howtoSprite];
}

- (void)createButton
{
    // Game scene button
    _gameSceneButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu01.png"]];
    _gameSceneButton.positionType = CCPositionTypeNormalized;
    _gameSceneButton.position = ccp(0.8f, 0.08f);
    [_gameSceneButton setTarget:self selector:@selector(onGameButtonClicked:)];
    [self addChild:_gameSceneButton z:10];
    
    _xButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"x-01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"x-02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"x-01.png"]];
    _xButton.positionType = CCPositionTypeNormalized;
    _xButton.position = ccp(0.87f, 0.88f);
    [_xButton setTarget:self selector:@selector(onXButtonClicked:)];
    [self addChild:_xButton z:10];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

// Game Scene Button
- (void)onGameButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1f]];
}

- (void)onXButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1f]];
}

// -----------------------------------------------------------------------

@end

