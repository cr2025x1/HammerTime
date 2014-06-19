//
//  MenuScene.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright cr2025x1 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "MenuScene.h"
#import "GameScene.h"
#import "RankScene.h"
#import "HowToScene.h"
#import "CCActionUDC.h"

#define FRONT_CLOUD_SIZE 563
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  550
#define BACK_CLOUD_TOP   500

// -----------------------------------------------------------------------
#pragma mark - MenuScene
// -----------------------------------------------------------------------

@implementation MenuScene
{
    CCSprite *background;
    
    CCNode *optionNode;
    CCSprite *_bgOption;
    
    CCSprite *titleSprite;
    
    CCButton *optionButton;
    CCButton *gameSceneButton;
    CCButton *rankSceneButton;
    CCButton *howtoSceneButton;
    
    CCSprite *effectSprite;
    CCActionRotateBy *actionSpin;
    
    OALSimpleAudio *bgmAudio;
    OALSimpleAudio *effectAudio;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MenuScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    NSLog(@"%f", self.contentSize.width);
    NSLog(@"%f", self.contentSize.height);
    
    [self createBGM];
    
    [self createOptionNode];
    [self createTitle];
    
    [self createBackground];
    [self createButton];
    [self createCloud];
    [self creatEffect];
    
    // done
	return self;
}

- (void)createBGM
{
    bgmAudio = [OALSimpleAudio sharedInstance];
    bgmAudio.bgVolume = 1.0f;
    [bgmAudio playBg:@"bgm-menu.wav" loop:YES];
}

- (void)createEffectBGM
{
    effectAudio = [OALSimpleAudio sharedInstance];
    [effectAudio playEffect:@"Break.mp3"];
}

// -----------------------------------------------------------------------
#pragma mark - Create Cloud
// -----------------------------------------------------------------------

- (void)createCloud
{
    [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP fileName:@"bg-cloud.png" interval:15 z:2];
    [self createCloudWithSize:BACK_CLOUD_SIZE  top:BACK_CLOUD_TOP  fileName:@"bg-cloud.png"  interval:30 z:1];
}

- (void)createCloudWithSize:(int)imgSize top:(int)imgTop fileName:(NSString*)fileName interval:(int)interval z:(int)z {
    id enterRight	= [CCActionMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id enterRight2	= [CCActionMoveTo actionWithDuration:interval position:ccp(0, imgTop)];
    id exitLeft		= [CCActionMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id exitLeft2	= [CCActionMoveTo actionWithDuration:interval position:ccp(-imgSize, imgTop)];
    id reset		= [CCActionMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id reset2		= [CCActionMoveTo actionWithDuration:0  position:ccp( imgSize, imgTop)];
    id seq1			= [CCActionSequence actions: exitLeft, reset, enterRight, nil];
    id seq2			= [CCActionSequence actions: enterRight2, exitLeft2, reset2, nil];
    
    CCSprite *spCloud1 = [CCSprite spriteWithImageNamed:fileName];
    [spCloud1 setAnchorPoint:ccp(0,1)];
    [spCloud1 setPosition:ccp(0, imgTop)];
    [spCloud1 runAction:[CCActionRepeatForever actionWithAction:seq1]];
    [self addChild:spCloud1 z:z ];
    
    CCSprite *spCloud2 = [CCSprite spriteWithImageNamed:fileName];
    [spCloud2 setAnchorPoint:ccp(0,1)];
    [spCloud2 setPosition:ccp(imgSize, imgTop)];
    [spCloud2 runAction:[CCActionRepeatForever actionWithAction:seq2]];
    [self addChild:spCloud2 z:z ];
}

// -----------------------------------------------------------------------
#pragma mark - Create OptionNode
// -----------------------------------------------------------------------

- (void)createOptionNode
{
    _bgOption = [CCSprite spriteWithImageNamed:@"bg-option.png"];
    
    optionNode = [[OptionGroup alloc] init];
    optionNode.contentSize = CGSizeMake(_bgOption.contentSize.width, _bgOption.contentSize.height);
    optionNode.anchorPoint = ccp(0.5f, 0.5f);
    optionNode.positionType = CCPositionTypeNormalized;
    optionNode.position = ccp(0.47f, 0.87f);
    optionNode.visible = NO;

    [self addChild:optionNode z:11];
}

// Option Window Button
- (void)onOptionButtonClicked:(id)sender
{
    optionNode.visible ^= YES;
}

// -----------------------------------------------------------------------
#pragma mark - Create Gackground Effect
// -----------------------------------------------------------------------

- (void)creatEffect
{
    effectSprite = [CCSprite spriteWithImageNamed:@"effect-menu.png"];
    effectSprite.anchorPoint = ccp(0.5f, 0.5f);
    effectSprite.positionType = CCPositionTypeNormalized;
    effectSprite.position = ccp(0.42f, 0.19f);
    [self addChild:effectSprite z:10];
    
    actionSpin = [CCActionRotateBy actionWithDuration:5.0f angle:360];
    [effectSprite runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
}

// -----------------------------------------------------------------------
#pragma mark - Create Gackground
// -----------------------------------------------------------------------

- (void)createBackground
{
    background = [CCSprite spriteWithImageNamed:@"bg-menu.png"];
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self addChild:background z:0];
}

// -----------------------------------------------------------------------
#pragma mark - Create Title
// -----------------------------------------------------------------------

- (void)createTitle
{
    // Game Image작업이 되면 넣겠습니다.
    titleSprite = [CCSprite spriteWithImageNamed:@"title-menu.png"];
    titleSprite.position = ccp(self.contentSize.width/2, self.contentSize.height/10*7.8 + self.contentSize.height/2);
    [self addChild:titleSprite z:9];
    
    CCActionFreeFall *freefall = [CCActionFreeFall actionWithDuration:0.5f position:ccp(0, -self.contentSize.height/2)];
    
    CCActionBump *bump = [CCActionBump actionWithDuration:0.5f velocity:ccp(0, self.contentSize.height/2)];
    
    CCActionDistort *distort = [CCActionDistort actionWithDuration:1.0f velocity:ccp(0, titleSprite.contentSize.height/5) collisionSize:titleSprite.contentSize.height/2 inflationRatio:1.0f displacementScale:1.0f];
    
    CCActionSpawn *spawn = [CCActionSpawn actions:bump, distort, nil];
    
//    CCActionRepeatForever *forever = [CCActionRepeatForever actionWithAction:distort];
    
    CCActionSequence *sequence = [CCActionSequence actions:freefall, spawn, nil];
    
    [titleSprite runAction:sequence];
}

// -----------------------------------------------------------------------
#pragma mark - Create Button
// -----------------------------------------------------------------------

- (void)createButton
{
    // option button
    optionButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"set-menu01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"set-menu02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"set-menu01.png"]];
    optionButton.anchorPoint = ccp(0.5f, 0.5f);
    optionButton.positionType = CCPositionTypeNormalized;
    optionButton.position = ccp(0.9f, 0.94f);
    [optionButton setTarget:self selector:@selector(onOptionButtonClicked:)];
    [self addChild:optionButton z:10];
    
    // Game scene button
    gameSceneButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-menu01.png"]];
    gameSceneButton.positionType = CCPositionTypeNormalized;
    gameSceneButton.position = ccp(0.8f, 0.27f);
    [gameSceneButton setTarget:self selector:@selector(onGameButtonClicked:)];
    [self addChild:gameSceneButton z:10];
    
    // Rank scene button
    rankSceneButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"rank-menu01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"rank-menu02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"rank-menu01.png"]];
    rankSceneButton.positionType = CCPositionTypeNormalized;
    rankSceneButton.position = ccp(0.8f, 0.17f);
    [rankSceneButton setTarget:self selector:@selector(onRankButtonClicked:)];
    [self addChild:rankSceneButton z:10];
    
    // HowTo scene button
    howtoSceneButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"howto-menu01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"howto-menu02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"howto-menu01.png"]];
    howtoSceneButton.positionType = CCPositionTypeNormalized;
    howtoSceneButton.position = ccp(0.8f, 0.07f);
    [howtoSceneButton setTarget:self selector:@selector(onHowToButtonClicked:)];
    [self addChild:howtoSceneButton z:10];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

    // Game Scene Button
- (void)onGameButtonClicked:(id)sender
{
    [self createEffectBGM];
    [bgmAudio stopBg];
    
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1f]];
}

    // Rank Scene Button
- (void)onRankButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    [[CCDirector sharedDirector] replaceScene:[RankScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.5f]];
}

    // HowTo Scene Button
- (void)onHowToButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    [[CCDirector sharedDirector] replaceScene:[HowToScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1f]];
}

// -----------------------------------------------------------------------
@end
