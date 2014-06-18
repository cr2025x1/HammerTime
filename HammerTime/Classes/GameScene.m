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

// -----------------------------------------------------------------------
#pragma mark - GameScene
// -----------------------------------------------------------------------

@implementation GameScene {
    
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
    
#pragma mark - HelloWorld Defaults End
    
    // done
	return self;
}



// 매 프레임마다 호출됨. 필히 있어야 함.
- (void)update:(CCTime)delta {
    [_gameLogic updatedTimeHandler:delta];
}



// 프로토콜 지정 메소드: 게임 오버 이벤트 메소드. 역시 필히 있어야 한다.
- (void)gameOverEventHandler {
    // 게임 오버 시 할 행동을 여기에 기록. (씬 전환, 랭크씬으로의 점수 넘기기 등.)
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
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
                               withTransition:[CCTransition transitionFadeWithDuration:1.0f]];
//    [[CCDirector sharedDirector] replaceScene:[MenuScene scene]
//                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GamePage scene]]];
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f scene:[GamePage scene]]];
}

// -----------------------------------------------------------------------


- (void)setBackground {
    // 배경 객체 총괄 노드
    CCNode* _backgroundNode = _uiGroup.backgroundNode;
    
    // 배경 작성 부분
    // 모든 배경(콤보 효과 배경 제외)은 모두 위의 객체 내에 집어넣어야 한다.
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [_backgroundNode addChild:background];
}

- (void)setBackgroundUpper {
    // 배경 위의 객체들을 총괄하는 노드 (콤보 스프라이트보다 상위 z축에 있어야하는 객체들)
    CCNode* _backgroundUpperNode = _uiGroup.backgroundUpperNode;
    
    // 배경 위의 객체 작성 부분
}

- (void)setBackgroundCombo {
    // 콤보 배경 효과 객체 총괄 노드
    CCNode* _backgroundComboNode = _uiGroup.backgroundComboNode;
    
    // 콤보 배경 작성 부분
    // 콤보 활성화 시 뜨는 모든 배경 코드는 여기에 작성되어야 하며, 모든 객체는 위의 노드에 삽입되어야 한다.
    CCSprite *testSprite = [CCSprite spriteWithImageNamed:@"Icon-72.png"];
    testSprite.anchorPoint = ccp(0.0f, 0.5f);
    testSprite.position = ccp(0.0f, self.contentSize.height/2);
    [_backgroundComboNode addChild:testSprite];
}

- (void)setBackgroundUI {
    // 배경 UI 객체 총괄 노드 (UI그룹이 직접 다루지 않는 메뉴 버튼 등등...)
    CCNode* _backgroundUINode = _uiGroup.backgroundUINode;
    
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.anchorPoint = ccp(0.5f, 0.5f);
    backButton.position = ccp(self.contentSize.width*0.85, self.contentSize.height*.95);
    // 단 아래의 좌표 세팅으로는 제대로 출력되지 않음. 좌표 방식의 문제인듯함.
//    backButton.positionType = CCPositionTypeNormalized;
//    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [_backgroundUINode addChild:backButton];
}

@end







 