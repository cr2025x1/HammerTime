//
//  GameCommon.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/23/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GameSetting.h"

#define ARC4RANDOM_MAX 0x100000000


enum zOrder {
    background_zOrder,
    background_Combo_ZOrder,
    background_upper,
    block_frag,
    block_group,
    button_group,
    timer_background,
    timer_bar,
    combo_background,
    combo_bar,
    combo_figurehead,
    start_counter,
    score_label,
    combo_label,
    ui_group
};
typedef enum zOrder zOrder;

@class GameCommon;

@protocol GameOverEventProtocol <NSObject>
- (void)gameOverEventHandler;
@end

@protocol SoundFadeProtocol <NSObject>
- (void)soundFadeEventHandlerWithDuration:(float)duration;
- (void)soundFadeEventHandlerInner;
@end

// 상수 설정값 저장용 싱글톤 클래스
@interface GameCommon : NSObject {
    NSMutableDictionary* _soundLibrary;
}

@property (nonatomic, readonly) NSMutableDictionary* soundLibrary;
+ (GameCommon *) shared;
- (void)loadFrameFromSprite:(CCTexture *)SourceTexture withTargetArray:(NSMutableArray *)TargetArray withTopLeftX:(float)TopLeftX withTopLeftY:(float)TopLeftY withSizeX:(float)SizeX withSizeY:(float)SizeY withHorizontalCount:(int)HorizontalCount withVerticalCount:(int)VerticalCount isLoadingDirectionHorizontal:(bool)IsHorizontallySorted withTotalFrameCount:(int)FrameCount;
- (float)magnitude:(CGPoint)vector;
- (void)randomizeArray:(CGPoint*)array startingIndex:(int)startingIndex endingIndex:(int)endingIndex;
- (void)playSound:(NSString*)soundKey;
- (void)bgmFadeOutWithDuration:(float)duration scene:(CCScene*)scene;
- (void)bgmFadeInner;
- (void)bgmStop;
- (void)playStreakSoundWithKey:(unsigned int)key;

@end
