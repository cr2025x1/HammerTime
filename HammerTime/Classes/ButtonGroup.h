//
//  ButtonGroup.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockGroup.h"
#import "GameCommon.h"
#import "GameSetting.h"

@class Button;

@interface ButtonGroup : NSObject {
    NSMutableArray* _buttonArray;
    CGRect _detectionZone;
    unsigned int _buttonCount;
    CCSpriteBatchNode* _buttonBatchNode;
    CGPoint* _positionArray;
    CCScene* _attachedScene;
    NSMutableArray* _animationArray;
}

@property (nonatomic, readonly) unsigned int buttonCount;
+ (ButtonGroup *)allocWithAttachedScene:(CCScene*)attachedScene;
- (ButtonGroup *)initWithAttachedScene:(CCScene*)attachedScene;
- (int)addButtonWithAmount:(unsigned int)amount;
- (int)removeButtonWithAmount:(unsigned int)amount; // 사용될 것 같지는 않지만, 일단 선언을 추가해 둠.
- (BlockType)blockTypeCheckWithCGPoint:(CGPoint)givenPoint;
- (void)shuffleButtons;

@end



@interface Button : NSObject {
    CCSpriteBatchNode* _attachedBatchNode;
    BlockType _blockType;
    BlockType _internalType;
    CCSprite* _sprite;
    CGRect _boundingBox;
    SEL _pushSelector;
    CCActionAnimate* _pushAnimate;
}

@property (nonatomic, readonly) BlockType blockType;
//@property (nonatomic, readonly) CCSprite* sprite;
- (Button*)initWithAttachedBatchNode:(CCSpriteBatchNode*)attachedBatchNode
                            position:(CGPoint)position
                       pushAnimation:(CCAnimation*)pushAnimation
                                type:(BlockType)type;
- (bool)pushCheckWithCGPoint:(CGPoint)givenPoint;
- (void)removeButtonSprite;
- (void)buttonMoveWithCGPoint:(CGPoint)givenPoint;
//- (void)setType:(BlockType)type; // 이 메소드 대신 초기화 메소드를 이용한다. 스프라이트도 바뀌어야 하기 때문이다.

@end