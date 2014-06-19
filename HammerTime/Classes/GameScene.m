//
//  GameScene.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright cr2025x1 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "GameScene.h"
#import "MenuScene.h"
#import "CCAnimation.h"
#import "BlockGroup.h"
#import "ButtonGroup.h"
#import "GameOver.h"

#define FRONT_CLOUD_SIZE 563
#define BACK_CLOUD_SIZE  509
#define FRONT_CLOUD_TOP  550
#define BACK_CLOUD_TOP   500

// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------

@implementation GameScene {
    CCSprite *background;
    CCSprite *backgroundCombo;
    CCSprite *bgCloud;
    CCSprite *comboEffectFire;
    CCSprite *comboEffectBg;
    CCSprite *ham;
    
    CCButton *pauseButton;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
#pragma mark - HelloWorld Defaults Begins
    
    _blockGroup = [[BlockGroup alloc] initWithAttachedScene:self];
    _buttonGroup = [[ButtonGroup alloc] initWithAttachedScene:self];
    _uiGroup = [[UIGroup alloc] initWithAttachedScene:self];
    _gameLogic = [[GameLogic alloc] initWithBlockGroup:_blockGroup buttonGroup:_buttonGroup uiGroup:_uiGroup attachedScene:self];
    
    // 배경 및 콤보 배경 작성부분 (각각의 메소드 안에 작성할 것)
    [self setBackground]; // 일반 배경 객체
    [self setBackgroundCombo]; // 콤보시 뜨는 배경 객체
    [self setBackgroundUI]; // 일반 배경 UI 객체 (메뉴 버튼 등)
    [self createCloud];
    [self setBackgroundUpper];
    
#pragma mark - HelloWorld Defaults End
    
    // done
	return self;
}



// 매 프레임마다 호출됨. 필히 있어야 함.
- (void)update:(CCTime)delta {
    [_gameLogic updatedTimeHandler:delta];
}

// GameOver Score 정렬
- (void)gameOver {
    NSLog(@"GameOver");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:_gameLogic.userScore] forKey:@"newScoreKey"];
    [userDefaults synchronize];
    
    NSLog(@"Score : %d", [[userDefaults objectForKey:@"newScoreKey"] intValue]);
    
    
    int i;
    int j;
    int temp;
    int least;
    
    for (i = 1; i < 49; i++) {
        least = i;
        for (j = i + 1; j < 50; j++) {
            if ([[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",j]] intValue] > [[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",least]] intValue]) {
                least = j;
                temp = [[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",i]] intValue];
                [userDefaults setObject:[NSNumber numberWithInt:[[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",least]] intValue]] forKey:[NSString stringWithFormat:@"score%d",i]];
                [userDefaults synchronize];
                [userDefaults setObject:[NSNumber numberWithInt:temp] forKey:[NSString stringWithFormat:@"score%d",least]];
                [userDefaults synchronize];
            }
        }
    }
    
    int newScore;
    int oldScore;
    
    newScore = [[userDefaults objectForKey:@"newScoreKey"] intValue];
    
    NSLog(@"%d", newScore);
    
        for (int i = 1; i < 50; i++) {
            if ([[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",i]] intValue] < newScore) {
                oldScore = [[userDefaults objectForKey:[NSString stringWithFormat:@"score%d",i]] intValue];
                NSLog(@"oldScore : %d", oldScore);
    
                [userDefaults setObject:[NSNumber numberWithInt:newScore] forKey:[NSString stringWithFormat:@"score%d",i]];
                [userDefaults synchronize];
        
                newScore = oldScore;
            }
        }
    
}

// 프로토콜 지정 메소드: 게임 오버 이벤트 메소드. 역시 필히 있어야 한다.
- (void)gameOverEventHandler {
    // 게임 오버 시 할 행동을 여기에 기록. (씬 전환, 랭크씬으로의 점수 넘기기 등.)
    
    [self gameOver];
    
    [[CCDirector sharedDirector] replaceScene:[GameOver scene] withTransition:[CCTransition transitionFadeWithDuration:2.0f]];
    
    NSLog(@"GameScene gameOverHandler: Gameover event is in effect.\n");
    NSLog(@"Achieved User Score = %d\n", _gameLogic.userScore); // _gameLogic.userScore가 사용자의 점수
}



- (void)soundFadeEventHandlerWithDuration:(float)duration {
    unsigned int repeat = (unsigned int)ceilf(duration/0.02f);
    [self schedule:@selector(soundFadeEventHandlerInner) interval:0.02f repeat:repeat delay:0.0f];
//    [self schedule:@selector(soundFadeEventHandlerInner) interval:0.02f repeat:duration/0.02f delay:0.0f];
}

- (void)soundFadeEventHandlerInner {
    [[GameCommon shared] bgmFadeInner];
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    [_gameLogic touchEventHandlerWithCGPoint:touchLoc];
}

// -----------------------------------------------------------------------
#pragma mark - Create Cloud
// -----------------------------------------------------------------------

- (void)createCloud
{
    [self createCloudWithSize:FRONT_CLOUD_SIZE top:FRONT_CLOUD_TOP fileName:@"bg-cloud.png" interval:15 z:1];
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
#pragma mark - Set Node
// -----------------------------------------------------------------------

- (void)setBackgroundUpper {
    // 배경 위의 객체들을 총괄하는 노드 (콤보 스프라이트보다 상위 z축에 있어야하는 객체들)
    CCNode* _backgroundUpperNode = _uiGroup.backgroundUpperNode;
    
    _backgroundUpperNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    _backgroundUpperNode.anchorPoint = ccp(0.5f, 0.5f);
    _backgroundUpperNode.positionType = CCPositionTypeNormalized;
    _backgroundUpperNode.position = ccp(0.5f, 0.5f);
    
    // 배경 위의 객체 작성 부분
}

- (void)setBackground {
    // 배경 객체 총괄 노드
    CCNode* _backgroundNode = _uiGroup.backgroundNode;
    
    _backgroundNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    _backgroundNode.anchorPoint = ccp(0.5f, 0.5f);
    _backgroundNode.positionType = CCPositionTypeNormalized;
    _backgroundNode.position = ccp(0.5f, 0.5f);
    
    // 배경 작성 부분
    // 모든 배경(콤보 효과 배경 제외)은 모두 위의 객체 내에 집어넣어야 한다.
    background = [CCSprite spriteWithImageNamed:@"bg-game.png"];
    background.anchorPoint = ccp(0.5f, 0.5f);
    background.positionType = CCPositionTypeNormalized;
    background.position = ccp(0.5f, 0.5f);
    [_backgroundNode addChild:background z:0];
    
    ham = [CCSprite spriteWithImageNamed:@"ham01.png"];
    ham.anchorPoint = ccp(0.5f, 0.5f);
    ham.positionType = CCPositionTypeNormalized;
    ham.position = ccp(0.6f, 0.87f);
    [_backgroundNode addChild:ham];
    
    CCAnimation *hamAnimation = [CCAnimation animation];
    for (NSInteger i = 1; i < 3; i++) {
        [hamAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"ham%02d.png", i]];
    }
    [hamAnimation setDelayPerUnit:0.3];
    
    CCActionAnimate *hamAnimate = [CCActionAnimate actionWithAnimation:hamAnimation];
    
    CCActionRepeatForever *hamRepeatForever = [CCActionRepeatForever actionWithAction:hamAnimate];
    
    [ham runAction:hamRepeatForever];
}

- (void)setBackgroundCombo {
    // 콤보 배경 효과 객체 총괄 노드
    CCNode* _backgroundComboNode = _uiGroup.backgroundComboNode;
    
    _backgroundComboNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    _backgroundComboNode.anchorPoint = ccp(0.5f, 0.5f);
    _backgroundComboNode.positionType = CCPositionTypeNormalized;
    _backgroundComboNode.position = ccp(0.5f, 0.5f);
    
    // 콤보 배경 작성 부분
    // 콤보 활성화 시 뜨는 모든 배경 코드는 여기에 작성되어야 하며, 모든 객체는 위의 노드에 삽입되어야 한다.
    
    comboEffectBg = [CCSprite spriteWithImageNamed:@"effect-combo-game01.png"];
    comboEffectBg.anchorPoint = ccp(0.5f, 0.5f);
    comboEffectBg.positionType = CCPositionTypeNormalized;
    comboEffectBg.position = ccp(0.5f, 0.9f);
    [_backgroundComboNode addChild:comboEffectBg];
    
    CCAnimation *bgAnimation = [CCAnimation animation];
    for (NSInteger i = 1; i < 3; i++) {
        [bgAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"effect-combo-game%02d.png", i]];
    }
    [bgAnimation setDelayPerUnit:0.05];
    
    CCActionAnimate *bgAnimate = [CCActionAnimate actionWithAnimation:bgAnimation];
    
    CCActionRepeatForever *bgRepeatForever = [CCActionRepeatForever actionWithAction:bgAnimate];
    
    [comboEffectBg runAction:bgRepeatForever];
    
    backgroundCombo = [CCSprite spriteWithImageNamed:@"bg-combo-game.png"];
    backgroundCombo.anchorPoint = ccp(0.5f, 0.5f);
    backgroundCombo.positionType = CCPositionTypeNormalized;
    backgroundCombo.position = ccp(0.5f, 0.5f);
    [_backgroundComboNode addChild:backgroundCombo z:0];
    
    // 햄 애니메이션
    ham = [CCSprite spriteWithImageNamed:@"ham01.png"];
    ham.anchorPoint = ccp(0.5f, 0.5f);
    ham.positionType = CCPositionTypeNormalized;
    ham.position = ccp(0.6f, 0.87f);
    [_backgroundComboNode addChild:ham];
    
    CCAnimation *hamAnimation = [CCAnimation animation];
    for (NSInteger i = 3; i < 6; i++) {
        [hamAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"ham%02d.png", i]];
    }
    [hamAnimation setDelayPerUnit:0.1];
    
    CCActionAnimate *hamAnimate = [CCActionAnimate actionWithAnimation:hamAnimation];
    
    CCActionRepeatForever *hamRepeatForever = [CCActionRepeatForever actionWithAction:hamAnimate];
    
    [ham runAction:hamRepeatForever];
    
    // comboFire
    comboEffectFire = [CCSprite spriteWithImageNamed:@"effect2-combo-game01.png"];
    comboEffectFire.anchorPoint = ccp(0.5f, 0.5f);
    comboEffectFire.positionType = CCPositionTypeNormalized;
    comboEffectFire.position = ccp(0.5f, 0.87f);
    [_backgroundComboNode addChild:comboEffectFire];
    
    CCAnimation *fireAnimation = [CCAnimation animation];
    for (NSInteger i = 1; i < 5; i++) {
        [fireAnimation addSpriteFrameWithFilename:[NSString stringWithFormat:@"effect2-combo-game%02d.png", i]];
    }
    [fireAnimation setDelayPerUnit:0.3];
    
    CCActionAnimate *fireAnimate = [CCActionAnimate actionWithAnimation:fireAnimation];
    
    CCActionRepeatForever *fireRepeatForever = [CCActionRepeatForever actionWithAction:fireAnimate];
    
    [comboEffectFire runAction:fireRepeatForever];
}

- (void)setBackgroundUI {
    // 배경 UI 객체 총괄 노드 (UI그룹이 직접 다루지 않는 메뉴 버튼 등등...)
    CCNode* _backgroundUINode = _uiGroup.backgroundUINode;
    
    _backgroundUINode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    _backgroundUINode.anchorPoint = ccp(0.5f, 0.5f);
    _backgroundUINode.positionType = CCPositionTypeNormalized;
    _backgroundUINode.position = ccp(0.5f, 0.5f);
    
    pauseButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"pause01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"pause02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"pause01.png"]];
    pauseButton.anchorPoint = ccp(0.5f, 0.5f);
    pauseButton.positionType = CCPositionTypeNormalized;
    pauseButton.position = ccp(0.05f, 0.96f);
    [pauseButton setTarget:self selector:@selector(onBackClicked:)];
    [_backgroundUINode addChild:pauseButton];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:0.5f]];
}

// -----------------------------------------------------------------------

@end







 