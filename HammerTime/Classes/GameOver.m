//
//  GameOver.m
//  HammerTime
//
//  Created by ivis lab on 2014. 6. 15..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "GameOver.h"
#import "MenuScene.h"
#import "GameScene.h"

#define FRONT_CLOUD_SIZE 563
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  550
#define BACK_CLOUD_TOP   500

// -----------------------------------------------------------------------
#pragma mark - GameOver
// -----------------------------------------------------------------------

@implementation GameOver
{
    CCButton *homeButton;
    CCButton *restartButton;
    
    CCSprite *background;
    CCSprite *iconGameOver;
    CCSprite *GamOverTitleSprite;
    
    CCLabelTTF *score;
    CCLabelTTF *new;
    CCLabelTTF *newScore;
    CCLabelTTF *rank;
    CCLabelTTF *rankScroe;
    
    OALSimpleAudio *bgmAudio;
    OALSimpleAudio *effectAudio;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameOver *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [self createBGM];
    [self createBackground];
    [self createTitle];
    [self createButton];
    [self createCloud];
    [self createLbel];
    
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

- (void)createLbel
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    score = [CCLabelTTF labelWithString:@"SCORE" fontName:@"KoreanPODGO-R" fontSize:25.0f];
    score.anchorPoint = ccp(0.5f, 0.5f);
    score.positionType = CCPositionTypeNormalized;
    score.position = ccp(0.5f, 0.49f);
    [self addChild:score z:100];
    
    new = [CCLabelTTF labelWithString:@"NEW" fontName:@"KoreanPODGO-R" fontSize:25.0f];
    new.anchorPoint = ccp(0.5f, 0.5f);
    new.positionType = CCPositionTypeNormalized;
    new.position = ccp(0.14f, 0.405f);
    [self addChild:new z:100];
    
    newScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[userDefaults objectForKey:@"newScoreKey"] intValue]] fontName:@"KoreanPODGO-R" fontSize:30.0f];
    newScore.anchorPoint = ccp(1, 0.5f);
    newScore.positionType = CCPositionTypeNormalized;
    newScore.position = ccp(0.7f, 0.405f);
    [self addChild:newScore];
    
    rank = [CCLabelTTF labelWithString:@"BEST" fontName:@"KoreanPODGO-R" fontSize:25.0f];
    rank.anchorPoint = ccp(0.5f, 0.5f);
    rank.positionType = CCPositionTypeNormalized;
    rank.position = ccp(0.14f, 0.33f);
    [self addChild:rank z:100];
    
    rankScroe = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[userDefaults objectForKey:@"score1"] intValue]] fontName:@"KoreanPODGO-R" fontSize:30.0f];
    rankScroe.anchorPoint = ccp(1, 0.5f);
    rankScroe.positionType = CCPositionTypeNormalized;
    rankScroe.position = ccp(0.7f, 0.33f);
    [self addChild:rankScroe];
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
#pragma mark - Create Gackground
// -----------------------------------------------------------------------

- (void)createBackground
{
    background = [CCSprite spriteWithImageNamed:@"bg-gameover.png"];
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self addChild:background z:0];
    
    iconGameOver = [CCSprite spriteWithImageNamed:@"icon-gameover.png"];
    iconGameOver.anchorPoint = ccp(0.5f, 0.5f);
    iconGameOver.positionType = CCPositionTypeNormalized;
    iconGameOver.position = ccp(0.5f, 0.61f);
    [self addChild:iconGameOver];
}

// -----------------------------------------------------------------------
#pragma mark - Create Title
// -----------------------------------------------------------------------

- (void)createTitle
{
    GamOverTitleSprite = [CCSprite spriteWithImageNamed:@"title-gameover.png"];
    GamOverTitleSprite.position = ccp(self.contentSize.width/2, self.contentSize.height/10*7.8 + self.contentSize.height/2);
    [self addChild:GamOverTitleSprite z:9];
    
    CCActionFreeFall *freefall = [CCActionFreeFall actionWithDuration:0.3f position:ccp(0, -self.contentSize.height/2.2)];
    
    [GamOverTitleSprite runAction:freefall];
}


// -----------------------------------------------------------------------
#pragma mark - Create Button
// -----------------------------------------------------------------------

- (void)createButton
{
    homeButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"home-gameover01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"home-gameover02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"home-gameover01.png"]];
    homeButton.position = ccp(self.contentSize.width/4, self.contentSize.height/7);
    [homeButton setTarget:self selector:@selector(onHomeButtonClicked:)];
    [self addChild:homeButton z:10];
    
    restartButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"restart-gameover01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"restart-gameover02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"restart-gameover01.png"]];
    restartButton.position = ccp(self.contentSize.width/1.3, self.contentSize.height/7);
    [restartButton setTarget:self selector:@selector(onReStartButtonClicked:)];
    [self addChild:restartButton z:10];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onHomeButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.5f]];
}

- (void)onReStartButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.5f]];
}

// -----------------------------------------------------------------------
@end

