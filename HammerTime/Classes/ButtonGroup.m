//
//  ButtonGroup.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/21/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "ButtonGroup.h"
#import "CCAnimation.h"

@interface ButtonGroup (private) {
    
}

@end

@interface Button (private) {
    
}
- (void)playPushMotion;
- (void)playPushMotionNull;

@end


@implementation ButtonGroup


+ (ButtonGroup *)allocWithAttachedScene:(CCScene*)attachedScene {
    return [[ButtonGroup alloc] initWithAttachedScene:attachedScene];
}
- (ButtonGroup *)initWithAttachedScene:(CCScene*)attachedScene {
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);
    
    // 버튼 객체를 저장할 NSMutableArray 배열 로드
    _buttonArray = [NSMutableArray array];
    if (_buttonArray == nil) {
        NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to allocate _buttonArray.");
        return nil;
    }
    
    // 버튼의 CCSpriteBatchNode 객체 로드
    _buttonBatchNode = [[CCSpriteBatchNode alloc] initWithFile:[GameSetting shared].buttonTextureFile capacity:[GameSetting shared].buttonGroupCapacity];
    if (_buttonBatchNode == nil) {
        NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to allocate _buttonBatchNode.");
        return nil;
    }
    _attachedScene = attachedScene;
    [_attachedScene addChild:_buttonBatchNode z:[GameSetting shared].buttonZOrder];
    
    // 버튼 위치 좌표를 섞기 위해, C 언어 타입 구조체 배열로 주어진 좌표설정값들을 옮긴다.
    _positionArray = malloc(sizeof(CGPoint)*[GameSetting shared].buttonGroupCapacity);
    if (_positionArray == nil) {
        NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to allocate _randomizedPosition.");
        return nil;
    }
    
    for (int i = 0; i < [GameSetting shared].buttonGroupCapacity; i++) {
        _positionArray[i] = [[[GameSetting shared].buttonPositionArray objectAtIndex:i] CGPointValue];
    }
    
    // 난이도 상향을 위해 버튼의 배열을 섞는다. 이후 밸런싱 문제로 제거할 수도 있음.
    [[GameCommon shared] randomizeArray:_positionArray
                          startingIndex:0
                            endingIndex:[GameSetting shared].buttonInitialCount - 1];
    [[GameCommon shared] randomizeArray:_positionArray
                          startingIndex:[GameSetting shared].buttonInitialCount
                            endingIndex:[GameSetting shared].buttonGroupCapacity - 1];
    
    
    _animationArray = [NSMutableArray array];
    if (_animationArray == nil) {
        return nil;
    }
    
    // 버튼 스프라이트의 프레임 로드
    for (int i = 0; i < [GameSetting shared].buttonTypeCount; i++) {
        NSMutableArray *frameArray = [NSMutableArray array];
        if (frameArray == nil) {
            NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to load frames.");
            return nil;
        }
        
        // 프레임 로딩부: 만일 버튼의 스프라이트 시트 파일의 배열 방법이 바뀌었다면, 이 메소드 호출부도 바꾸어야 한다.
        [[GameCommon shared] loadFrameFromSprite:_buttonBatchNode.texture
                                 withTargetArray:frameArray
                                    withTopLeftX:i * [GameSetting shared].buttonPixelSizeX
                                    withTopLeftY:0
                                       withSizeX:[GameSetting shared].buttonPixelSizeX
                                       withSizeY:[GameSetting shared].buttonPixelSizeY
                             withHorizontalCount:1
                               withVerticalCount:[GameSetting shared].buttonFrameCount
                    isLoadingDirectionHorizontal:false
                             withTotalFrameCount:[GameSetting shared].buttonFrameCount];
        
        CCAnimation* animation = [CCAnimation animationWithSpriteFrames:frameArray delay:[GameSetting shared].blockFrameDelay];
        if (animation == nil) {
            NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to load animation.");
            return nil;
        }
        
        [_animationArray addObject:animation];
    }
    
    
    // 초기 설정치만큼의 버튼 추가
    _buttonCount = 0;
    if ([self addButtonWithAmount:[GameSetting shared].buttonInitialCount] != 0) {
        NSAssert(false, @"ButtonGroup initWithAttachedScene: failed to add a button.\n");
        return nil;
    }
    
    return self;
}



// 터치 포인트를 받아 각 버튼 객체들에게 터치되었는지 확인하고, 참값이 반환되면 그 버튼 객체의 블록타입 반환. (참값 반환이 없다면 not_a_block값 반환)
- (BlockType)blockTypeCheckWithCGPoint:(CGPoint)givenPoint {
    for (int i = 0; i < _buttonArray.count; i++) {
        if ([[_buttonArray objectAtIndex:i] pushCheckWithCGPoint:givenPoint]) {
            NSLog(@"Pushed BlockType = %d\n", [[_buttonArray objectAtIndex:i] blockType]);
            return [[_buttonArray objectAtIndex:i] blockType];
        }
    }
    NSLog(@"Pushed BlockType = %d\n", not_a_block);
    return not_a_block;
}



// 주어진 개수만큼 버튼 객체를 더한다.
- (int)addButtonWithAmount:(unsigned int)amount {
    NSAssert((amount > 0) && (amount <= [GameSetting shared].buttonGroupCapacity - _buttonCount), @"ButtonGroup addButton: given amount is out of its accepted range.");
    
    int loop_end = amount + _buttonCount;
    for (int i = _buttonCount; i < loop_end; i++) {
        // 버튼의 종류 세팅이 바뀐다면 type값의 식도 바뀌어야 한다.
        Button* button = [[Button alloc] initWithAttachedBatchNode:_buttonBatchNode position:_positionArray[i] pushAnimation:[_animationArray objectAtIndex:i] type:i * 2];
        if (button == nil) {
            NSAssert(false, @"ButtonGroup addButtonWithAmount: failed to allocate a button object.");
            return -1;
        }
        
        [_buttonArray addObject:button];
    }
    
    _buttonCount += amount;
    
    return 0;
}



// 이는 반대로 주어진 개수만큼 버튼 객체를 제거한다.
- (int)removeButtonWithAmount:(unsigned int)amount {
    if (!((amount > 0) && (amount <= _buttonCount))) {
        NSAssert(false, @"ButtonGroup removeButton: given amount is out of its accepted range.");
        return -1;
    }
    
    for (int i = 0; i < amount; i++) {
        NSAssert([_buttonArray lastObject], @"ERROR!");
        
        [[_buttonArray lastObject] removeButtonSprite];
        [_buttonArray removeLastObject];
        
    }
    _buttonCount -= amount;
    
    return 0;
}


- (void) dealloc {
    // 초기화 메소드에서 동적할당으로 만든 C 타입 배열의 할당을 해제한다.
    free(_positionArray);
}


// 버튼 위치 뒤섞기
- (void)shuffleButtons {
    [[GameCommon shared] randomizeArray:_positionArray
                          startingIndex:0
                            endingIndex:_buttonCount - 1];
    
    for (int i = 0; i < _buttonCount; i++) {
        [((Button*)[_buttonArray objectAtIndex:i]) buttonMoveWithCGPoint:_positionArray[i]];
    }
    
}

@end



// 각각의 버튼 객체
@implementation Button {
    
}

- (Button*)initWithAttachedBatchNode:(CCSpriteBatchNode*)attachedBatchNode
                            position:(CGPoint)position
                       pushAnimation:(CCAnimation*)pushAnimation
                                type:(BlockType)type {
    // 슈퍼클래스 초기화
    self = [super init];
    if (!self) return(nil);
    
    // 인수 검사
    NSAssert(attachedBatchNode != nil, @"Button initWithAttachedBatchNode: given node point is null.");
    // pushAnimation은 널 포인터를 받을 수도 있다. 널 포인터를 받았다면 푸시 애니메이션이 없음을 의미한다.
    
    _attachedBatchNode = attachedBatchNode;
    // 버튼의 타입 설정 : 중요! 이후 스프라이트 시트의 구성에 따라 반드시 다시 변경해야 한다.
    _internalType = type / 2;
    _blockType = _internalType * 2;
    
    // 스프라이트 로딩 부분 : 만일 스프라이트 시트의 구조가 바뀐다면 이 부분 역시 변경되어야 한다.
    _sprite = [CCSprite spriteWithTexture:_attachedBatchNode.texture rect:CGRectMake(_internalType * [GameSetting shared].buttonSizeX, 0, [GameSetting shared].buttonSizeX, [GameSetting shared].buttonSizeY)];
    if (_sprite == nil) {
        NSAssert(false, @"Button initWithAttachedBatchNode: failed to allocate its sprite.");
        return nil;
    }
    
    _sprite.position = position;
    _boundingBox = [_sprite boundingBox];
    [_attachedBatchNode addChild:_sprite];
    
    // 메소드 포인터를 이용, 만일 푸시 애니메이션이 지정되지 않았다면 푸시 애니메이션 재생을 생략한다. (매 실행시마다 if문를 계속 쓰지 않도록 하기 위함)
    if (pushAnimation == nil) {
        _pushSelector = @selector(playPushMotionNull);
        NSLog(@"No animation detected.");
    }
    else {
        _pushSelector = @selector(playPushMotion);
        NSLog(@"Animation detected.");
        _pushAnimate = [CCActionAnimate actionWithAnimation:pushAnimation];
        if (_pushAnimate == nil) {
            NSAssert(false, @"Button initWithAttachedBatchNode: failed to allocate its animation action.");
            return nil;
        }
    }
    
    return self;
}



// 눌림 효과 애니메이션 재생
- (void)playPushMotion {
    // 만일 애니메이션을 재생한다면, 반드시 애니메이션은 맨 마지막 프레임이 눌러지지 않은 상태와 같은 스프라이트여야 한다.
    if (![_pushAnimate isDone])
    {
        [_sprite stopAction:_pushAnimate];
    }

    [_sprite runAction:_pushAnimate];
}



// 눌림 효과 애니메이션 재생(빈 메소드. 애니메이션 미지정 시)
- (void)playPushMotionNull {
    // 이 메소드는 아무 것도 하지 않는다.
}



// 주어진 터치포인트가 이 버튼의 스프라이트의 영역 내에 있는지 확인
- (bool)pushCheckWithCGPoint:(CGPoint)givenPoint {
    bool result = false;
    NSAssert(_pushSelector != nil, @"Button pushCheckWithCGPoint: _pushselector is null!");
    
    if (CGRectContainsPoint(_boundingBox, givenPoint)) {
        // 참고 페이지: 메소드 포인터의 이용(컴파일러의 경고 때문에 이렇게 사용)
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        ((void (*)(id, SEL))[self methodForSelector:_pushSelector])(self, _pushSelector); // 확실히 복잡하고 보기 어렵군...
        
        NSLog(@"Button pushed: %@\n", NSStringFromCGPoint(givenPoint)); // 개발 완료 이후 주석 처리하거나 삭제

        result = true;
    }
    
    return result;
}


- (void)removeButtonSprite {
    [_attachedBatchNode removeChild:_sprite cleanup:true];
    
}



- (void)buttonMoveWithCGPoint:(CGPoint)givenPoint {
    _sprite.position = givenPoint;
    _boundingBox = [_sprite boundingBox];
}


@end