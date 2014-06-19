//
//  RankScene.m
//  HammerTime
//
//  Created by JH Lee on 2014. 5. 22..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "RankScene.h"
#import "GameScene.h"
#import "MenuScene.h"

#define FRONT_CLOUD_SIZE 563
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  550
#define BACK_CLOUD_TOP   500

// -----------------------------------------------------------------------
#pragma mark - RankScene
// -----------------------------------------------------------------------

float const kNumberOfRows = 50.0f;

@implementation RankScene
{
    CCSprite *background;
    CCSprite *rankWindow;
    CCSprite *iconRank;
    CCSprite *cellBox;
    CCSprite *rankTitleSprite;
    CCNodeColor *backgroundColor;
    CCButton *backButton;
    CCButton *gameSceneButton;
    
    CCLabelTTF *rankCount;
    CCLabelTTF *rankScore;
    
    OALSimpleAudio *effectAudio;

}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (RankScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [self createCloud];
    [self createBackground];
    [self createRankWindow];
    [self createTitle];
    [self createTable];
    [self createButton];
    
    return self;
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
#pragma mark - Create Gackground
// -----------------------------------------------------------------------

- (void)createBackground
{
    backgroundColor = [CCNodeColor nodeWithColor:[CCColor colorWithRed:255 green:255 blue:255] width:320 height:590];
    backgroundColor.anchorPoint = ccp(0.5f, 0.5f);
    backgroundColor.positionType = CCPositionTypeNormalized;
    backgroundColor.position = ccp(0.5f, 0.5f);
    [self addChild:backgroundColor z:0];
    
    background = [CCSprite spriteWithImageNamed:@"bg-rank.png"];
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [self addChild:background z:0];
    
    iconRank = [CCSprite spriteWithImageNamed:@"icon-rank.png"];
    iconRank.anchorPoint = ccp(0.5f, 0.5f);
    iconRank.positionType = CCPositionTypeNormalized;
    iconRank.position = ccp(0.14f, 0.77f);
    [self addChild:iconRank z:100];
}

// -----------------------------------------------------------------------
#pragma mark - Create Rank Window
// -----------------------------------------------------------------------

- (void)createRankWindow
{
    rankWindow = [CCSprite spriteWithImageNamed:@"rankWindow.png"];
    rankWindow.anchorPoint = ccp(0.5f, 0.5f);
    rankWindow.positionType = CCPositionTypeNormalized;
    rankWindow.position = ccp(0.5f, 0.5f);
    [self addChild:rankWindow];
}

// -----------------------------------------------------------------------
#pragma mark - Create Title
// -----------------------------------------------------------------------

- (void)createTitle
{
    rankTitleSprite = [CCSprite spriteWithImageNamed:@"title-rank.png"];
    rankTitleSprite.position = ccp(self.contentSize.width/2, self.contentSize.height/10*7.8 + self.contentSize.height/2);
    [self addChild:rankTitleSprite z:9];
    
    CCActionFreeFall *freefall = [CCActionFreeFall actionWithDuration:0.5f position:ccp(0, -self.contentSize.height/2)];
    
    CCActionBump *bump = [CCActionBump actionWithDuration:0.5f velocity:ccp(0, self.contentSize.height/2)];
    
    CCActionDistort *distort = [CCActionDistort actionWithDuration:1.0f velocity:ccp(0, rankTitleSprite.contentSize.height/5) collisionSize:rankTitleSprite.contentSize.height/2 inflationRatio:1.0f displacementScale:1.0f];
    
    CCActionSpawn *spawn = [CCActionSpawn actions:bump, distort, nil];
    
    //    CCActionRepeatForever *forever = [CCActionRepeatForever actionWithAction:distort];
    
    CCActionSequence *sequence = [CCActionSequence actions:freefall, spawn, nil];
    
    [rankTitleSprite runAction:sequence];
}

// -----------------------------------------------------------------------
#pragma mark - Create Table Test
// -----------------------------------------------------------------------

- (void)createTable
{
    CCTableView *table = [[CCTableView alloc] init];
    table.dataSource = self;
    table.contentSizeType = CCSizeTypeNormalized;
    table.contentSize = CGSizeMake(1.0f, 0.75f);
    table.rowHeight = 44;
    table.anchorPoint = ccp(0.5f, 0.5f);
    table.positionType = CCPositionTypeNormalized;
    table.position = ccp(0.55f, 0.5f);
    [table setScrollPosition:ccp(0, table.minScrollY)];
    [rankWindow addChild:table];
}

- (CCTableViewCell*) tableView:(CCTableView*)tableView nodeForRowAtIndex:(NSUInteger) index
{
    CCTableViewCell* cell = [CCTableViewCell node];
    
    cellBox = [CCSprite spriteWithImageNamed:@"cell-rank.png"];
    cellBox.anchorPoint = ccp(0, 0.5f);
    [cell addChild:cellBox];
    
    rankCount = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%lu",(unsigned long)index + 1] fontName:@"KoreanPODGO-R" fontSize:30.0f];
    rankCount.anchorPoint = ccp(1, 0.5f);
    rankCount.position = ccp(50, 0);
    [cell addChild:rankCount z:11];
    
    NSString *count = [NSString stringWithFormat:@"score%d",index + 1];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    rankScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[userDefaults objectForKey:count] intValue]] fontName:@"KoreanPODGO-R" fontSize:30.0f];
    rankScore.anchorPoint = ccp(1, 0.5f);
    rankScore.position = ccp(250, 0);
    [cell addChild:rankScore];
    
//    NSLog(@"%d : %d", [[userDefaults objectForKey:[NSString stringWithFormat:@"score%d", index]] intValue], index);
    
    return cell;
}

- (NSUInteger) tableViewNumberOfRows:(CCTableView*) tableView {
    return kNumberOfRows;
}

// -----------------------------------------------------------------------
#pragma mark - Create Button
// -----------------------------------------------------------------------

- (void)createButton
{
    // Back Button
    backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"back-rank01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"back-rank02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"back-rank01.png"]];
    backButton.position = ccp(self.contentSize.width/6.5, self.contentSize.height/13*12);
    [backButton setTarget:self selector:@selector(onBackButtonClicked:)];
    [self addChild:backButton z:10];
    
    // GameScene Button
    gameSceneButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-rank01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-rank02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"start-rank01.png"]];
    gameSceneButton.position = ccp(self.contentSize.width/2, self.contentSize.height/10);
    [gameSceneButton setTarget:self selector:@selector(onGameButtonClicked:)];
    [self addChild:gameSceneButton z:10];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    // Menu scene with transition
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.5f]];
}

- (void)onGameButtonClicked:(id)sender
{
    [self createEffectBGM];
    
    // Game scene with transition
    [[CCDirector sharedDirector] replaceScene:[GameScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1f]];
}

// -----------------------------------------------------------------------
@end
