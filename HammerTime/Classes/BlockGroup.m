//
//  BlockGroup.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "BlockGroup.h"
#import "CCAnimation.h"
#import "GameSetting.h"
#import "GameCommon.h"

// 블록그룹의 private 메소드들
#pragma mark - BlockGroup Interface
@interface BlockGroup (private)
- (CCSpriteBatchNode*)getBlockFragSBN;
- (NSMutableArray*)getBlockFragSFA;
- (void)stashBlock:(Block*)block;
@property (readonly) BlockFragQueue* blockFragQueue;

@end

// 블록의 private 메소드들 : 없음. 애당초 블록 객체는 블록그룹 밖에서는 정상적이라면 생성할 일이 전혀 없을 것이다.
#pragma mark - Block Interface
@interface Block (private)

- (int)createFragments;
- (void)reinit;

@end


#pragma mark - BlockGroup
@implementation BlockGroup {
    GameSetting* _gSetSO;
    BlockQueue* _blockQueue;
    BlockFragQueue* _blockFragQueue;
}

+ (BlockGroup*)allocWithAttachedScene:(CCScene*)attachedScene {
    return [[BlockGroup alloc] initWithAttachedScene:attachedScene];
}

// 초기화 메소드
- (BlockGroup*)initWithAttachedScene:(CCScene*)attachedScene {
    self = [super init];
    if (!self) return(nil);
    
    _blockArray = [NSMutableArray array];
    if (_blockArray == nil) {
        return nil; // 기본적으로 동적 할당이 발생하는 곳에서는 항상 널 포인터 여부를 검사한다. 실패할 수도 있기 때문이다.
    }
    
    _gSetSO = [GameSetting shared];
    
    _visibleCount = _gSetSO.blockVisibleCount;
    _totalCount = _visibleCount * 2;
    // 모든 블럭은 이 배치노드의 자식으로 들어간다.
    _blockSpriteBatchNode = [[CCSpriteBatchNode alloc] initWithFile:_gSetSO.blockTextureFile capacity:_totalCount];
    if (_blockSpriteBatchNode == nil) {
        return nil;
    }
    
    _blockFragSpriteBatchNode = [[CCSpriteBatchNode alloc] initWithFile:_gSetSO.blockFragTextureFile capacity:_visibleCount*_gSetSO.blockFragGenCount];
    if (_blockFragSpriteBatchNode == nil) {
        return nil;
    }
    
    _animationArray = [NSMutableArray array];
    if (_animationArray == nil) {
        return nil;
    }
    
    _blockTypeQueue = [[BlockTypeQueue alloc] initWithCapacity:_totalCount];
    if (_blockTypeQueue == nil) {
        return nil;
    }
    
    _blockQueue = [BlockQueue allocWithCapacity:_totalCount];
    if (_blockQueue == nil) {
        return nil;
    }
    
    for (int i = 0; i < _gSetSO.blockTypeCount; i++) {
        NSMutableArray *frameArray = [NSMutableArray array];
        if (frameArray == nil) {
            NSAssert(false, @"BlockGroup initWithBaseCGP: failed to load frames.");
            return nil;
        }
        
        // 프레임 로딩부: 만일 블럭의 스프라이트 시트 파일의 배열 방법이 바뀌었다면, 이 메소드 호출부도 바꾸어야 한다.
        [[GameCommon shared] loadFrameFromSprite:_blockSpriteBatchNode.texture
                  withTargetArray:frameArray
                     withTopLeftX:i * _gSetSO.blockPixelSizeX
                     withTopLeftY:0
                        withSizeX:_gSetSO.blockPixelSizeX
                        withSizeY:_gSetSO.blockPixelSizeY
              withHorizontalCount:1
                withVerticalCount:_gSetSO.blockFrameCount
     isLoadingDirectionHorizontal:false
              withTotalFrameCount:_gSetSO.blockFrameCount];
        
        CCAnimation* animation = [CCAnimation animationWithSpriteFrames:frameArray delay:_gSetSO.blockFrameDelay];
        if (animation == nil) {
            NSAssert(false, @"BlockGroup initWithBaseCGP: failed to load animation.");
            return nil;
        }
        
        [_animationArray addObject:animation];
    }
    
    
    _blockFragSpriteFrameArray = [NSMutableArray array];
    NSAssert(_blockFragSpriteFrameArray != nil, @"BlockGroup initWithBaseCGP: failed to allocate _blockFragSpriteFrameArray.");
    for (int i = 0; i < _gSetSO.blockTypeCount; i++) {
        // 프레임 로딩부: 만일 블럭의 스프라이트 시트 파일의 배열 방법이 바뀌었다면, 이 메소드 호출부도 바꾸어야 한다.
        NSMutableArray *frameArray = [NSMutableArray array];
        if (frameArray == nil) {
            NSAssert(false, @"BlockGroup initWithBaseCGP: failed to load frames.");
            return nil;
        }
        [[GameCommon shared] loadFrameFromSprite:_blockFragSpriteBatchNode.texture
                                 withTargetArray:frameArray
                                    withTopLeftX:i * _gSetSO.blockFragSizePixelX
                                    withTopLeftY:0
                                       withSizeX:_gSetSO.blockFragSizePixelX
                                       withSizeY:_gSetSO.blockFragSizePixelY
                             withHorizontalCount:1
                               withVerticalCount:_gSetSO.blockFragTypeCount
                    isLoadingDirectionHorizontal:false
                             withTotalFrameCount:_gSetSO.blockFragTypeCount];
        [_blockFragSpriteFrameArray addObject:frameArray];
    }
    
    
    [attachedScene addChild:_blockSpriteBatchNode z:_gSetSO.blockZOrder];
    [attachedScene addChild:_blockFragSpriteBatchNode z:_gSetSO.blockFragZOrder];
    
    _baseCGP = _gSetSO.blockGroupBaseCGP;
    _attachedScene = attachedScene;
    _blockCount = 0;
//    _removalCount = 0;
    _isBusy = false;
    _isGameOver = false;
    
    _userResponseTime = -1.0f;
    
    return self;
}



// 블록을 삽입하는 메소드
- (int)addBlockWithAmount:(unsigned int)amount {
    // 블록그룹이 동작 수행 중일 때에는 작업을 거부한다.
    if (_isBusy) {
        NSLog(@"BlockGroup addBlockWithAmount: execution denied. This BlockGroup object is busy.\n");
        return -1;
    }
    _isBusy = true;
    
    NSAssert(amount > 0, @"BlockGroup addBlockWithAmount: argument \"amount\" must be higher than 0.\n");
    NSAssert(amount <= _visibleCount, @"BlockGroup addBlockWithAmount: argument \"amount\" must be lesser than _visibleCount.\n");
    
    int blockCountOld = _blockCount;
    CGPoint offsetByLastBlockPosition;
    CGPoint initVelocity = ccp(0.0f, 0.0f);
    if (blockCountOld > 0) {
        offsetByLastBlockPosition = ccpSub([[_blockArray lastObject] getBlockPosition], ccp(_baseCGP.x, _baseCGP.y - _gSetSO.blockFallAccDirection * (_gSetSO.blockSizeY * (_visibleCount - 0.5) + _gSetSO.blockGap * (float)(_visibleCount - 1))));
        NSLog(@"LastBlockOffset = %@\n", NSStringFromCGPoint(offsetByLastBlockPosition));
        // 내가 만든 액션 객체의 결함인지는 모르나, 실제 이동에서의 미세한 오차가 있었다. 이러한 오차 허용치를 제공해야 했다.
        if (fabsf(offsetByLastBlockPosition.y * 1000.0f) <= 1.0f) {
            offsetByLastBlockPosition = ccp(0.0f, 0.0f);
        }
        else {
            initVelocity = [(Block*)[_blockArray lastObject] currentVelocity];
        }
    }
    else {
        offsetByLastBlockPosition = ccp(0.0f, 0.0f);
    }
    
    for (int i = 0; i < amount; i++) {
        int chosenType = [_blockTypeQueue getBlockType];
        int deathAnimationType = chosenType;
        if (_gSetSO.blockTypeDurabilityArray[chosenType] > 1) {
            deathAnimationType--;
        }
        
        Block* block = NULL;
        if (_blockQueue.count > 0) {
            block = [_blockQueue getBlock];
        }
        else {
            block = [Block alloc];
        }
        block = [block initWithAttachedBatchNode:_blockSpriteBatchNode
                                        position:ccpAdd(ccp(_baseCGP.x, _baseCGP.y - _gSetSO.blockFallAccDirection * (_gSetSO.blockSizeY * (i + _visibleCount + 0.5) + _gSetSO.blockGap * (float)(i + _visibleCount))), offsetByLastBlockPosition)
                                            type:chosenType
                                  deathAnimation:[_animationArray objectAtIndex:deathAnimationType]
                                     superObject:self
                                superObjectIndex:i + blockCountOld];
//        Block* block = [[Block alloc]
//                        initWithAttachedBatchNode:_blockSpriteBatchNode
//                        position:ccpAdd(ccp(_baseCGP.x, _baseCGP.y - _gSetSO.blockFallAccDirection * (_gSetSO.blockSizeY * (i + _visibleCount + 0.5) + _gSetSO.blockGap * (float)(i + _visibleCount))), offsetByLastBlockPosition)
//                        type:chosenType
//                        deathAnimation:[_animationArray objectAtIndex:deathAnimationType]
//                        superObject:self
//                        superObjectIndex:i + blockCountOld];
        if (block == nil)
        {
            NSAssert(false, @"BlockGroup addBlockWithAmount: Block object allocation failed.");
            return -1;
        }
        [_blockArray addObject:block];
        _blockCount++;
    }
    
    int loop_threshold = blockCountOld + amount;
    // 실제 블록은 위로 쌓이면 쌓일수록 아래에 깔린 블록들의 수축으로 인한 추가 변위가 계속 겹쳐지면서 실제로 움직여야 하는 변위의 양이 배로 증가한다. 이 때문에 변위 스케일값이 필요한 것이다.
//    unsigned int scale = 1;
    
    float fallTime;
    if ((_userResponseTime <= 0) || (_userResponseTime >= _gSetSO.blockFallDurationMax)) {
        fallTime = _gSetSO.blockFallDurationMax;
    }
    else {
        fallTime = _userResponseTime;
    }
    
    CGPoint displacement = ccpSub(ccpMult(ccp(0, _gSetSO.blockFallAccDirection * ((float)_gSetSO.blockSizeY + _gSetSO.blockGap)), (float)(_visibleCount - blockCountOld)), offsetByLastBlockPosition);
    for (int i = blockCountOld; i < loop_threshold; i++) {
        [[_blockArray objectAtIndex:i] fallWithDisplacement:displacement duration:fallTime initialVelocity:initVelocity];
    }
    
    _isBusy = false;
    
    return 0;
}



// 화면 상의 블록을 모두 채운다.
- (int)fillBlockGroup {
    int count = (int)_visibleCount - (int)_blockCount;
    if (count <= 0) {
        NSLog(@"fillBlockGroup: This BlockGroup object is already full.\n");
        return -1;
    }
    return [self addBlockWithAmount:_visibleCount - _blockCount];
}



// 이는 반대로 화면 상의 블록을 모두 제거한다.
- (int)removeAllBlock {
    if (_blockCount <= 0) {
        NSLog(@"removeAllBlock: This BlockGroup object is already empty.\n");
        return -1;
    }
    return [self removeBlockWithAmount:_blockCount userResponseTime:_userResponseTime];
}



// 굳이 말이 필요한가?
- (void)dealloc {
    // [_blockQue release];
    // [super dealloc];
    
}



// 가장 아래에 있는 블록의 타입을 반환
- (BlockType)bottomBlockType {
    return [(Block*)([_blockArray objectAtIndex:0]) blockType];
}



// 정해진 수만큼 블록을 제거한다. 게임 규칙 설계 상에서는 한 개의 블럭씩만을 삭제할 수만 있어도 상관없으나, 보너스 등의 도입을 고려, 여럿 삭제할 수 있게 확장했다.
// 대신 그만큼 멀티스레딩을 고려하느라 코드가 훨씬 복잡해지는 문제가 발생했다.
- (int)removeBlockWithAmount:(unsigned int)amount userResponseTime:(float)responseTime {
    // 중복 호출을 피한다.
    if (_isBusy) {
        NSLog(@"removeBlockWithAmount: This BlockGroup object is busy. (Return value = -1)\n");
        return -1;
    }
    
    _isBusy = true;
    
    _userResponseTime = responseTime;
    
    
//    _removalCount = amount;
    NSLog(@"removal count = %d\n", amount);
    for (int i = 0; i < amount; i++) {
        [[_blockArray objectAtIndex:0] playDeathAction];
//        [_blockQue putBlock:[_blockArray objectAtIndex:0]];
        [_blockArray removeObjectAtIndex:0];
        _blockCount--;
    }
    
    float fallTime;
    if ((_userResponseTime <= 0) || (_userResponseTime >= _gSetSO.blockFallDurationMax)) {
        fallTime = _gSetSO.blockFallDurationMax;
    }
    else {
        fallTime = _userResponseTime;
    }
    
    for (int i = 0; i < _blockCount; i++) {
        CGPoint displacement = ccpSub(ccp(_baseCGP.x, _baseCGP.y - _gSetSO.blockFallAccDirection * (_gSetSO.blockSizeY / 2.0f + _gSetSO.blockSizeY * i)), [[_blockArray objectAtIndex:i] getBlockPosition]);
        CGPoint displacementWithGap = ccpSub(displacement, ccp(0.0f, _gSetSO.blockFallAccDirection * _gSetSO.blockGap * i));
        [[_blockArray objectAtIndex:i] fallWithDisplacement:displacementWithGap duration:fallTime];
    }
    
    _isBusy = false;
    // 제거된 만큼 자동으로 블록을 보충하도록 메소드 호출, 단 게임 오버 상황인 경우에는 재생성을 하지 않는다.
    if (!(_isGameOver)) {
        [self addBlockWithAmount:amount];
    }
    
    
    return 0;
}



// 게임 종료 시 호출해야 하는 메소드 : 블럭의 재생을 막고, 현재 있는 모든 블럭을 폭파시킨다.
- (void)gameOver {
    _isGameOver = true;
    
    if (!(_isBusy)) {
        [self removeAllBlock];
    }
}



- (void)queueBlockType:(BlockType)blockType {
    [_blockTypeQueue putBlockType:blockType];
}

- (CCSpriteBatchNode*)getBlockFragSBN {
    return _blockFragSpriteBatchNode;
    
}

- (NSMutableArray*)getBlockFragSFA {
    return _blockFragSpriteFrameArray;
}

- (void)weakenBottomBlock {
    [(Block*)([_blockArray objectAtIndex:0]) weakenBlock];
}

- (void)stashBlock:(Block*)block {
    [_blockQueue putBlock:block];
}

@end



// 블록 클래스 : 각각의 벽돌 하나하나의 객체
/*
 - 이 클래스의 객체는 모두 블록 관리 클래스 내에서만 캡슐화되어 존재해야 한다.
 */
#pragma mark - Block
@implementation Block {
    CCSprite* _sprite;
    BlockType _blockType;
    CCActionFreeFall* _fall;
    //    CCActionDistort* _bounce;
    CCActionAnimate* _deathAction;
    BlockGroup* _superObject;
    unsigned int _superObjectIndex;
    CCSpriteBatchNode* _attachedBatchNode;
    
    GameSetting* _gSetSO;
}

- (Block*)initWithAttachedBatchNode:(CCSpriteBatchNode*)attachedBatchNode
                           position:(CGPoint)position
                               type:(BlockType)givenType
                     deathAnimation:(CCAnimation *)deathAnimation
                        superObject:(BlockGroup*)superObject
                   superObjectIndex:(unsigned int)superObjectIndex {
    
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);
    
    _gSetSO = [GameSetting shared];
    
    // 블록의 세부 설정값 입력
    _attachedBatchNode = attachedBatchNode;
    _blockType = givenType;
    _superObject = superObject;
    _superObjectIndex = superObjectIndex;
    
    // 고속 반응을 위해, 이 부분은 애니메이션의 진행과 별도로 게임이 속행되도록 바뀔 수 있다.
    _deathAction = [CCActionSequence actions:[CCActionAnimate actionWithAnimation:deathAnimation],
                    [CCActionCallBlock actionWithBlock:^{
        // 메소드 설계 철학: 만든 곳에서 제거한다. BlockGroup에서 이 Block을 만들었으니 이 Block의 해체도 BlockGroup에서 이루어지게 한다.
        // 이 주석이 있는 부분에 파편 발생 메소드를 추가할 예정이다. 혹은 디자이너의 결정에 따라 다른 메소드로도 변경 가능.
        [self removeSprite];
        [_superObject stashBlock:self];
    }],
                     nil];
    
    // NULL 확인 조건문 추가: reinit 대응
    if (_fall == NULL) {
        _fall = [CCActionFreeFall alloc];
    }
    
//    _bounce = [CCActionDistort alloc];
    
    // NULL 확인 조건문 추가: reinit 대응
    if (_sprite == NULL) {
        _sprite = [CCSprite spriteWithTexture:_attachedBatchNode.texture
                                         rect:CGRectMake(_blockType * _gSetSO.blockSizeX, 0, _gSetSO.blockSizeX, _gSetSO.blockSizeY)];
    }
    else {
        [_sprite setTextureRect:CGRectMake(_blockType * _gSetSO.blockSizeX, 0, _gSetSO.blockSizeX, _gSetSO.blockSizeY)];
    }
    
    if (_deathAction == nil || _fall == nil || _sprite == nil) {
//    if (_bounce == nil || _deathAction == nil || _fall == nil || _sprite == nil) {
        return nil;
    }
    
    _sprite.position = position;
    [_attachedBatchNode addChild:_sprite];
    
    return self;
}



// 제거 명령 시 동작
- (void)playDeathAction {
    [self createFragments];
    [_sprite runAction:_deathAction];
}

- (int)fallWithDisplacement:(CGPoint)givenDisplacement duration:(float)duration initialVelocity:(CGPoint)initialVelocity {
    
    //    float displacementMagnitude = [[GameCommon shared] magnitude:givenDisplacement];
    //    float fallDuration = sqrtf(2.0 * displacementMagnitude / [GameSetting shared].blockFallAcceleration);
    
    if (!([_fall isDone])) {
        [_sprite stopAction:_fall];
    }
    _fall = [_fall initWithDuration:duration position:givenDisplacement initialVelocity:initialVelocity];
    
    //    _bounce = [_bounce
    //               initWithDuration:[GameSetting shared].blockBumpDuration
    //               velocity:_fall.terminalVelocity
    //               collisionSize:_sprite.contentSize.height/2
    //               inflationRatio:[GameSetting shared].blockInflationRatio displacementScale:displacementScale];
    
    //    CCActionSequence* sequence = [CCActionSequence actions:
    //                                  _fall,
    //                                  [CCActionCallBlock actionWithBlock:^{
    //        [_superObject checkMoveStatus:self];
    //    }],
    //                                  nil];
    //    CCActionSequence* sequence = [CCActionSequence actions:
    //                                  _fall,
    //                                  _bounce,
    //                                  [CCActionCallBlock actionWithBlock:^{
    //        [_superObject checkMoveStatus:self];
    //    }],
    //                                  nil];
    
    //    if (sequence == nil) {
    //        NSAssert(false, @"Failed to get a CCActionSequence object.");
    //        return -1;
    //    }
    
    //    [_sprite runAction:sequence];
    [_sprite runAction:_fall];
    return 0;
}

- (int)fallWithDisplacement:(CGPoint)givenDisplacement duration:(float)duration {
    return [self fallWithDisplacement:givenDisplacement duration:duration initialVelocity:_fall.currentVelocity];
}


// 블록그룹 객체의 내부 배열에서의 이 객체의 인덱스가 바뀔 수 있으므로, 설정자를 제공한다.
- (void)setSuperObjectIndex:(unsigned int)superObjectIndex {
    _superObjectIndex = superObjectIndex;
}



// 블록의 스프라이트 제거
- (void)removeSprite {
    [_attachedBatchNode removeChild:_sprite cleanup:true];
}



// 블록 파괴시의 파편 발생
- (int)createFragments {
    // 참고할 파편 생성의 패턴 : 마리오의 벽돌 파괴
    // 파편은 사망시 애니메이션(극도로 짧거나 단 1장) 후, 그 애니메이션의 마지막 스프라이트가 조각조각 분해되어 각기 따로 분산되는 형태로 구현한다.
    // GameSetting의 변수값에 따라 파편의 발생을 정의한다. (가로 몇 줄, 세로 몇 줄, 포물선의 최대 높이 변위 얼마, 시작 속도, 가속도 등)
    // 게임의 진행과 무관하게 파편은 진행하므로, 작업 완료를 체크할 필요는 없다. 단, 객체의 소멸은 반드시 진행되어야 한다.
    // 파편을 생성한 블록 객체는 사라질 것이므로, 파편의 해체는 여기서 해서는 안 된다. (?)
    // 만일 파편의 해체를 파편 객체 자체에서 한다면, 설계 철학을 위반하지 않는가?
    // 이동 시 이용할 메소드 : CCActionJumpBy? 아무튼, 내가 직접 새 클래스를 정의하지는 않아도 될 듯하다.
    for (int i = 0; i < _gSetSO.blockFragGenCount; i++) {
        int fragRand = arc4random() % _gSetSO.blockFragTypeCount;
        
        CCSprite* fragSprite = [CCSprite spriteWithSpriteFrame:[[[_superObject getBlockFragSFA] objectAtIndex:_blockType] objectAtIndex:fragRand]];
        NSAssert(fragSprite != nil, @"Block createFragments: failed to allocate fragSprite.\n");
        
        fragSprite.position = _sprite.position;
        
//        float init_velocity = (double)rand() / (double)RAND_MAX * ([GameSetting shared].blockFragVelocityMax - [GameSetting shared].blockFragVelocityMin) + [GameSetting shared].blockFragVelocityMin;
//        float init_angle = (double)rand() / (double)RAND_MAX * ([GameSetting shared].blockFragAngleMax - [GameSetting shared].blockFragAngleMin) + [GameSetting shared].blockFragAngleMin;
        float init_velocity = (double)arc4random() / (double)ARC4RANDOM_MAX * (_gSetSO.blockFragVelocityMax - _gSetSO.blockFragVelocityMin) + _gSetSO.blockFragVelocityMin;
        float init_angle = (double)arc4random() / (double)ARC4RANDOM_MAX * (_gSetSO.blockFragAngleMax - _gSetSO.blockFragAngleMin) + _gSetSO.blockFragAngleMin;
        float cosAngle = cosf(init_angle);
        float sinAngle = sinf(init_angle);
        float init_fallHeight = fragSprite.position.y + fragSprite.contentSize.height/2;
        float init_intermediate = (-1.0f) * init_velocity * sinAngle;
        float init_determinant = powf(powf(init_velocity * sinAngle, 2) - 2 * _gSetSO.blockFragGravAcc * init_fallHeight, 0.5);
        float init_duration1 = (init_intermediate + init_determinant) / _gSetSO.blockFragGravAcc;
        float init_duration2 = (init_intermediate - init_determinant) / _gSetSO.blockFragGravAcc;
        float init_duration;
        if (init_duration1 > 0) {
            init_duration = init_duration1;
        }
        else {
            init_duration = init_duration2;
        }
        
        CGPoint destination = ccp(powf(-1, i) * init_velocity * cosAngle *  init_duration, (-1) * init_fallHeight);
        
//        float init_anglerVelocity = (((double)rand() / (double)RAND_MAX) * ([GameSetting shared].blockFragAnglerVelocityMax - [GameSetting shared].blockFragAnglerVelocityMin) + [GameSetting shared].blockFragAnglerVelocityMin);
        float init_anglerVelocity = (((double)arc4random() / (double)ARC4RANDOM_MAX) * (_gSetSO.blockFragAnglerVelocityMax - _gSetSO.blockFragAnglerVelocityMin) + _gSetSO.blockFragAnglerVelocityMin);
        CCActionRotateBy* rotation_inner = [CCActionRotateBy actionWithDuration:1 angle:180 / M_PI * init_anglerVelocity];
        NSAssert(rotation_inner != nil, @"Block createFragments: failed to allocate rotation_inner.\n");
        CCActionRepeatForever* rotation = [CCActionRepeatForever actionWithAction:rotation_inner];
        NSAssert(rotation != nil, @"Block createFragments: failed to allocate rotation.\n");
        
//        CCActionJumpBy* jump = [CCActionJumpBy actionWithDuration:init_duration
//                                                         position:destination
//                                                           height:250
//                                                            jumps:1];
        NSLog(@"jump height = %lf\n", (-1.0f) * powf(init_velocity * sinAngle, 2) / (2.0f * _gSetSO.blockFragGravAcc));
        CCActionJumpBy* jump = [CCActionJumpBy actionWithDuration:init_duration
                                                         position:destination
                                                           height:(-1.0f) * powf(init_velocity * sinAngle, 2) / (2.0f * _gSetSO.blockFragGravAcc)
                                                            jumps:1];
//        CCActionJumpBy* jump = [CCActionJumpBy actionWithDuration:init_duration
//                                                         position:destination
//                                                           height:(-1.0f) * powf(init_velocity * sinAngle, 2) / (2.0f * [GameSetting shared].blockFragGravAcc)
//                                                            jumps:1];
        NSAssert(jump != nil, @"Block createFragments: failed to allocate jump.\n");
        CCActionSequence* actionSeq = [CCActionSequence actions:jump,
                                       [CCActionCallBlock actionWithBlock:^{
            [[_superObject getBlockFragSBN] removeChild:fragSprite cleanup:true];
            [_superObject.blockFragQueue putBlockFrag:fragSprite];
        }],
                                       nil];
        NSAssert(actionSeq != nil, @"Block createFragments: failed to allocate actionSeq.\n");
        
        [[_superObject getBlockFragSBN] addChild:fragSprite];
        [fragSprite runAction:rotation];
        [fragSprite runAction:actionSeq];

    }
    
    return 0;
}

- (CGPoint)currentVelocity {
    if ([_fall isDone]) {
        return ccp(0.0f, 0.0f);
    }
    else {
//        NSLog(@"_fall iV : %@\n", NSStringFromCGPoint(_fall.currentVelocity));
        return _fall.currentVelocity;
    }
}

- (CGPoint)getBlockPosition {
    return _sprite.position;
}

- (void)weakenBlock {
    // 스프라이트 시트 구조가 바뀌면 이것도 바뀌어야 할 수 있다.
    [self createFragments];
    _blockType--;
    [_sprite setTextureRect:CGRectMake(_blockType * _gSetSO.blockSizeX, 0, _gSetSO.blockSizeX, _gSetSO.blockSizeY)];
}

- (void)reinit {
    _deathAction = NULL;
}

@end



#pragma mark - BlockTypeQueue
@implementation BlockTypeQueue

- (BlockTypeQueue*)init {
    if( [self class] == [BlockTypeQueue class]) {
        NSAssert(false, @"You must not use -(id)init method to initialize a BlockTypeQue object. Use initWithCapacity instead.\n");
        
        self = nil;
    }
    else {
        self = [super init];
    }
    
    return self;
}

- (void)dealloc {
    free(_array);
}

- (BlockTypeQueue*)initWithCapacity:(unsigned int)capacity {
    // 주의: 만일 이 메소드를 한 객체에서 여러 번 호출하게 되면 메모리 누수가 발생한다.
    
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);    
    
    _array = (BlockType*)(malloc(sizeof(BlockType)*capacity));
    if (_array == nil) {
        NSLog(@"BlockTypeQue object: Failed to malloc.\n");
        return nil;
    }
    for (int i = 0; i < capacity; i++) {
        _array[i] = not_a_block;
    }
    
    _writingIndex = 0;
    _readingIndex = 0;
    _count = 0;
    _capacity = capacity;
    
    return self;
}

- (void)putBlockType:(BlockType)blockType {
    if (_count >= _capacity) {
        NSAssert(false, @"BlockTypeQue object is overloaded.\n");
    }
    
    _array[_writingIndex] = blockType;
    _writingIndex = (_writingIndex + 1) % _capacity;
    _count++;
    
    NSLog(@"Stashing BlockType %d. Queued data count = %d.\n", blockType, _count);
}

- (BlockType)getBlockType {
    if (_count <= 0) {
        NSAssert(false, @"BlockTypeQue object is called with getBlockType() but it is empty.\n");
    }
    
    BlockType loadedBlockType = _array[_readingIndex];
    _array[_readingIndex] = not_a_block;
    _readingIndex = (_readingIndex + 1) % _capacity;
    _count--;
    
    NSLog(@"Withdrawing BlockType %d. Queued data count = %d.\n", loadedBlockType, _count);
    return loadedBlockType;
}


@end



#pragma mark - BlockQueue
// 블록 객체를 그대로 소멸시키지 않고 재생해 사용하기 위해 저장하는 큐 객체
@implementation BlockQueue

- (BlockQueue*)init {
    if( [self class] == [BlockQueue class]) {
        NSAssert(false, @"You must not use -(id)init method to initialize a BlockQueue object. Use initWithCapacity instead.\n");
        
        self = nil;
    }
    else {
        self = [super init];
    }
    
    return self;
}

- (void)dealloc {
    free(_array);
}

+ (BlockQueue*)allocWithCapacity:(unsigned int)capacity {
    return [[BlockQueue alloc] initWithCapacity:capacity];
}

- (BlockQueue*)initWithCapacity:(unsigned int)capacity {
    _array = (Block *__strong*)(calloc(capacity, sizeof(Block*)));
    if (_array == nil) {
        NSLog(@"BlockQueue object: Failed to calloc.\n");
        return nil;
    }
    
    _writingIndex = 0;
    _readingIndex = 0;
    _count = 0;
    _capacity = capacity;
    NSLog(@"BlockQueue initlaized with capacity of %d.\n", _capacity);
    
    return self;
}

- (void)putBlock:(Block*)block {
    if (_count >= _capacity) {
        NSAssert(false, @"BlockQueue object is overloaded.\n");
    }
    
    _array[_writingIndex] = block;
    [_array[_writingIndex] reinit];
    _writingIndex = (_writingIndex + 1) % _capacity;
    _count++;
    NSLog(@"Stashing a Block object. Count = %d\n", _count);
}

- (Block*)getBlock {
    if (_count <= 0) {
        NSAssert(false, @"BlockQueue object is called with getBlock() but it is empty.\n");
    }
    
    Block* loadedBlock = _array[_readingIndex];
    _array[_readingIndex] = NULL;
    _readingIndex = (_readingIndex + 1) % _capacity;
    _count--;
    NSLog(@"Withdrawing a Block object. Count = %d\n", _count);
    
    return loadedBlock;
}

@end


#pragma mark - BlockFragQueue
// 블록 객체를 그대로 소멸시키지 않고 재생해 사용하기 위해 저장하는 큐 객체
@implementation BlockFragQueue

- (BlockFragQueue*)init {
    if( [self class] == [BlockFragQueue class]) {
        NSAssert(false, @"You must not use -(id)init method to initialize a BlockFragQueue object. Use initWithCapacity instead.\n");
        
        self = nil;
    }
    else {
        self = [super init];
    }
    
    return self;
}

- (void)dealloc {
    free(_array);
}

+ (BlockFragQueue*)allocWithCapacity:(unsigned int)capacity {
    return [[BlockFragQueue alloc] initWithCapacity:capacity];
}

- (BlockFragQueue*)initWithCapacity:(unsigned int)capacity {
    _array = (CCSprite *__strong*)(calloc(capacity, sizeof(CCSprite*)));
    if (_array == nil) {
        NSLog(@"BlockFragQueue object: Failed to calloc.\n");
        return nil;
    }
    
    _writingIndex = 0;
    _readingIndex = 0;
    _count = 0;
    _capacity = capacity;
    NSLog(@"BlockFragQueue initlaized with capacity of %d.\n", _capacity);
    
    return self;
}

- (void)putBlockFrag:(CCSprite*)blockFrag {
    if (_count >= _capacity) {
        NSAssert(false, @"BlockFragQueue object is overloaded.\n");
    }
    
    _array[_writingIndex] = blockFrag;
    _writingIndex = (_writingIndex + 1) % _capacity;
    _count++;
    NSLog(@"Stashing a CCSprite object. Count = %d\n", _count);
}

- (CCSprite*)getBlockFrag {
    if (_count <= 0) {
        NSAssert(false, @"BlockFragQueue object is called with getBlockFrag() but it is empty.\n");
    }
    
    CCSprite* loadedBlockFrag = _array[_readingIndex];
    _array[_readingIndex] = NULL;
    _readingIndex = (_readingIndex + 1) % _capacity;
    _count--;
    NSLog(@"Withdrawing a CCSprite object. Count = %d\n", _count);
    
    return loadedBlockFrag;
}

@end