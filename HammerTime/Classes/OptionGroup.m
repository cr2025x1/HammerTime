//
//  OptionGroup.m
//  HammerTime
//
//  Created by ivis lab on 2014. 5. 28..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "OptionGroup.h"

@interface OptionGroup (private)

- (void)createSprite;
- (void)createTitle;
- (void)createButton;

@end

@implementation OptionGroup {
    CCSprite* _soundSprite;
    CCSprite* _setSoundSprite;
    CCSprite* _bgSoundSprite;
    CCSprite* _setBgSoundSprite;
    CCSprite* _bgSprite;
    
    CCLabelTTF *titleLabel;
    
    CCButton *soundEffectButton;
    CCButton *backgroundSoundButton;
    
    CGSize _winSize;
    
    
    OALSimpleAudio *bgmAudio;
    OALSimpleAudio *effectAudio;
}

-(OptionGroup*)init {
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);
    
    _winSize = [CCDirector sharedDirector].viewSize;
    
    [self createSprite];
    [self createButton];
    
    return self;
}

- (void)createSprite
{
    _bgSprite = [CCSprite spriteWithImageNamed:@"bg-option.png"];
    _bgSprite.positionType = CCPositionTypeNormalized;
    _bgSprite.anchorPoint = ccp(0.5f, 0.5f);
    _bgSprite.position = ccp(0.5f, 0.5f);
    [self addChild:_bgSprite];
    
    _soundSprite = [CCSprite spriteWithImageNamed:@"effect-sound01.png"];
    _soundSprite.positionType = CCPositionTypeNormalized;
    _soundSprite.anchorPoint = ccp(0.5f, 0.5f);
    _soundSprite.position = ccp(0.2f, 0.75f);
    [self addChild:_soundSprite];
    
    _setSoundSprite = [CCSprite spriteWithImageNamed:@"effect-sound02.png"];
    _setSoundSprite.positionType = CCPositionTypeNormalized;
    _setSoundSprite.anchorPoint = ccp(0.5f, 0.5f);
    _setSoundSprite.position = ccp(0.2f, 0.75f);
    [self addChild:_setSoundSprite];
    _setSoundSprite.visible = NO;
    
    _bgSoundSprite = [CCSprite spriteWithImageNamed:@"bg-sound01.png"];
    _bgSoundSprite.positionType = CCPositionTypeNormalized;
    _bgSoundSprite.anchorPoint = ccp(0.5f, 0.5f);
    _bgSoundSprite.position = ccp(0.2f, 0.25f);
    [self addChild:_bgSoundSprite];
    
    _setBgSoundSprite = [CCSprite spriteWithImageNamed:@"bg-sound02.png"];
    _setBgSoundSprite.positionType = CCPositionTypeNormalized;
    _setBgSoundSprite.anchorPoint = ccp(0.5f, 0.5f);
    _setBgSoundSprite.position = ccp(0.2f, 0.25f);
    [self addChild:_setBgSoundSprite];
    _setBgSoundSprite.visible = NO;
}

- (void)createButton
{
    soundEffectButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"effect-button01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"effect-button02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"effect-button01.png"]];
    soundEffectButton.anchorPoint = ccp(0.5f, 0.5f);
    soundEffectButton.positionType = CCPositionTypeNormalized;
    soundEffectButton.position = ccp(0.7f, 0.75f);
    [soundEffectButton setTarget:self selector:@selector(onEffectClicked:)];
    [self addChild:soundEffectButton];
    
    backgroundSoundButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"bg-button01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"bg-button02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"bg-button01.png"]];
    backgroundSoundButton.anchorPoint = ccp(0.5f, 0.5f);
    backgroundSoundButton.positionType = CCPositionTypeNormalized;
    backgroundSoundButton.position = ccp(0.7f, 0.25f);
    [backgroundSoundButton setTarget:self selector:@selector(onBackgroundClicked:)];
    [self addChild:backgroundSoundButton];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onEffectClicked:(id)sender
{
    bgmAudio = [OALSimpleAudio sharedInstance];
    bgmAudio.bgPaused ^= YES;
    _soundSprite.visible ^= YES;
    _setSoundSprite.visible ^= YES;
}

- (void)onBackgroundClicked:(id)sender
{
    effectAudio = [OALSimpleAudio sharedInstance];
    effectAudio.effectsPaused ^= YES;
    _bgSoundSprite.visible ^= YES;
    _setBgSoundSprite.visible ^= YES;
}

// -----------------------------------------------------------------------

@end
