//
//  BlockGroup.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCActionUDC.h"
#import "GameCommon.h"


@class Block;
@class BlockTypeQueue;
@class BlockQue;



// 블록 관리 클래스
@interface BlockGroup : NSObject {
    // BlockQue* _blockQue;
    NSMutableArray* _blockArray;
    bool _isBusy; // 모션 진행 중일 때 터치 차단
    CCScene* _attachedScene;
    unsigned int _visibleCount;
    unsigned int _totalCount;
    CGPoint _baseCGP;
    CCSpriteBatchNode* _blockSpriteBatchNode;
    unsigned int _blockCount;
    NSMutableArray* _animationArray;
    bool _isGameOver;
    CCSpriteBatchNode* _blockFragSpriteBatchNode;
    NSMutableArray* _blockFragSpriteFrameArray;
    
    // 멀티스레딩을 고려한 상태변수들
//    bool* _removalMarkerArray;
//    bool _isRemoving;
//    unsigned int _removalCount;
//    bool* _moveMarkerArray;
//    bool _isMoving;
//    unsigned int _moveCount;
    BlockTypeQueue* _blockTypeQueue;
    
    float _userResponseTime;    
}

@property (nonatomic, readonly) bool isBusy;
+ (BlockGroup*)allocWithAttachedScene:(CCScene*)attachedScene;
- (BlockGroup*)initWithAttachedScene:(CCScene*)attachedScene;
- (int)removeBlockWithAmount:(unsigned int)amount userResponseTime:(float)responseTime;
- (int)addBlockWithAmount:(unsigned int)amount; // 이 메소드는 구현체 내부에서만 사용할 예정임.
- (int)removeAllBlock;
- (int)fillBlockGroup;
- (BlockType)bottomBlockType;
- (void)gameOver;
- (void)queueBlockType:(BlockType)blockType;
- (void)weakenBottomBlock;


@end



// 블록 클래스 : 각각의 벽돌 하나하나의 객체
/*
 - 이 클래스의 객체는 모두 블록 관리 클래스 내에서만 캡슐화되어 존재해야 한다.
*/
@interface Block : NSObject {
    CCSprite* _sprite;
    BlockType _blockType;
    CCActionFreeFall* _fall;
//    CCActionDistort* _bounce;
    CCActionAnimate* _deathAction;
    BlockGroup* _superObject;
    unsigned int _superObjectIndex;
    CCSpriteBatchNode* _attachedBatchNode;
}

@property (nonatomic, readonly) BlockType blockType;
@property (nonatomic, readonly) unsigned int superObjectIndex;
//@property (nonatomic, readonly) CCSprite* sprite;
- (Block*)initWithAttachedBatchNode:(CCSpriteBatchNode*)attachedBatchNode
                           position:(CGPoint)position
                               type:(BlockType)givenType
                     deathAnimation:(CCAnimation *)deathAnimation
                        superObject:(BlockGroup*)superObject
                   superObjectIndex:(unsigned int)superObjectIndex;
- (void)playDeathAction;
- (int)fallWithDisplacement:(CGPoint)givenDisplacement duration:(float)duration;
- (int)fallWithDisplacement:(CGPoint)givenDisplacement duration:(float)duration initialVelocity:(CGPoint)initialVelocity;
//- (int)fallWithDisplacement:(CGPoint)givenDisplacement duration:(float)duration displacementScale:(float)displacementScale;
- (void)setSuperObjectIndex:(unsigned int)superObjectIndex;
- (CGPoint)getBlockPosition;
- (CGPoint)currentVelocity;
- (void)weakenBlock;

@end




@interface BlockQue : NSObject {
    unsigned int _writingIndex;
    unsigned int _readingIndex;
    unsigned int _count;
    unsigned int _capacity;
    Block *__strong* _array; // Hell yeah!
}

@property (nonatomic, readonly) unsigned int count;
- (Block*)getBlock;
- (void)putBlock:(Block*)block;
- (BlockQue*)initWithCapacity:(unsigned int)capacity;

@end



@interface BlockTypeQueue : NSObject {
unsigned int _writingIndex;
unsigned int _readingIndex;
unsigned int _count;
unsigned int _capacity;
BlockType* _array; // Hell yeah!
}

@property (nonatomic, readonly) unsigned int count;
- (BlockType)getBlockType;
- (void)putBlockType:(BlockType)blockType;
- (BlockTypeQueue*)initWithCapacity:(unsigned int)capacity;

@end



/*
 코딩 시 준수할 규칙
 - 객체는 "만든 곳"에서 해체도 담당한다.
 - 가능하면 각 클래스나 변수의 이름은 간단하게.
 - 객체 프로그래밍 지향.
*/