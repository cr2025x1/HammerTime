//
//  GameLogic.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/30/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//


#import "GameLogic.h"



#pragma mark - GameLogic Interface
@interface GameLogic (private)
- (void)blockHealthHandler;
- (void)addScore;
- (void)operateBlockTypeWithAmount:(unsigned int)amount;
- (void)operateButtonUnlock;
- (void)addComboPoint:(int)amount;
- (void)normalBlockEffect;
- (void)specialBlockEffect;
- (void)timerBlockEffect;
- (void)gameOver;
- (void)addHitStreak:(int)amount;

@end



#pragma mark - GameLogic Implmentation
@implementation GameLogic {
    int _bottomBlockHealth;
    float _userResponseTime;
}

- (GameLogic*)init {
    if( [self class] == [GameLogic class]) {
        NSAssert(false, @"You must not use -(id)init method to initialize a GameLogic object. Use initWithBlockGroup: instead.\n");
        
        self = nil;
    }
    else {
        self = [super init];
    }
    
    return self;

}


- (GameLogic*)initWithBlockGroup:(BlockGroup*)blockGroup buttonGroup:(ButtonGroup*)buttonGroup uiGroup:(UIGroup*)uiGroup attachedScene:(CCScene*)attachedScene{
    self = [super init];
    if (!self) return(nil);
    
    NSAssert(blockGroup != nil, @"GameLogic initWithBlockGroup: given blockGroup is nil.\n");
    _blockGroup = blockGroup;
    
    NSAssert(buttonGroup != nil, @"GameLogic initWithBlockGroup: given buttonGroup is nil.\n");
    _buttonGroup = buttonGroup;
    
    NSAssert(uiGroup != nil, @"GameLogic initWithBlockGroup: given uiGroup is nil.\n");
    _uiGroup = uiGroup;
    
    // 여기서 -1은 타이머 블록을 말함.
    _arrayElementCount = [GameSetting shared].blockTypeCount - 1;
    _specBlockIndex = _arrayElementCount - 1;
    _regularBlockTypeCount = _arrayElementCount - [GameSetting shared].specBlkEffectCount;
    
    unsigned int arraySize = _arrayElementCount * sizeof(double);
    _rateArray = (double*)malloc(arraySize);
    NSAssert(_rateArray != nil, @"GameLogic init: failed to allocate rateArray.\n");
    memset(_rateArray, 0, arraySize);
    
    unsigned int boolArraySize = _regularBlockTypeCount * sizeof(bool);
    _isBlockUnlocked = (bool*)malloc(boolArraySize);
    NSAssert(_isBlockUnlocked != nil, @"GameLogic init: failed to allocate _isBlockUnlocked.\n");
    memset(_isBlockUnlocked, 0, boolArraySize);
    
    unsigned int buttonUnlockArraySize = _regularBlockTypeCount / 2 * sizeof(bool); // 강화형 블록의 변화에 따라 바뀔 수 있음.
    _isButtonUnlocked = (bool*)malloc(buttonUnlockArraySize);
    NSAssert(_isButtonUnlocked != nil, @"GameLogic init: failed to allocate _isButtonUnlocked.\n");
    memset(_isButtonUnlocked, 0, buttonUnlockArraySize);
    for (int i = 0; i < [GameSetting shared].buttonInitialCount; i++) {
        _isButtonUnlocked[i] = 1;
    }
    
    unsigned int selectorArraySize = [GameSetting shared].blockTypeCount * sizeof(SEL);
    _blockEffectSelectorArray = (SEL*)malloc(selectorArraySize);
    NSAssert(_blockEffectSelectorArray != nil, @"GameLogic init: failed to allocate _blockEffectSelectorArray.\n");
    memset(_blockEffectSelectorArray, 0, selectorArraySize);
    for (int i = 0; i < _regularBlockTypeCount; i++) {
        _blockEffectSelectorArray[i] = @selector(normalBlockEffect);
    }
    // 블록 설정 변경에 따라 바뀌어야 할 수 있음.
    _blockEffectSelectorArray[special_bonus] = @selector(specialBlockEffect);
    _blockEffectSelectorArray[special_timer] = @selector(timerBlockEffect);
    
    _attachedScene = attachedScene;
    _blockUnlockCount = 0;
    _blockColorUnlockCount = 0;
    _bottomBlockHealth = 0;
    _userCombo = 0;
    _isGameActive = false;
    _remainingTime = [GameSetting shared].timeLimit;
    _audioEngine = [OALSimpleAudio sharedInstance];
    _userResponseTime = 0.0f;
    
//    srand((unsigned int)time(NULL));
    
    [_uiGroup initComboBarWithPercentage:0.0f];
    [_uiGroup updateTimerBarWithPercentage:100.0f];
    
    [_uiGroup performSelector:@selector(startCountBegin)
               withObject:nil
               afterDelay:[GameSetting shared].gameStartCountStartDelay];
    NSLog(@"Game will start after %lf seconds.\n", [GameSetting shared].startCountTimeTotal + [GameSetting shared].gameStartCountStartDelay);

    [self performSelector:@selector(startGame)
               withObject:nil
               afterDelay:[GameSetting shared].startCountTimeTotal + [GameSetting shared].gameStartCountStartDelay];
//    [self startGame];
    
    return self;

}


- (void)dealloc {
    free(_rateArray);
    free(_isBlockUnlocked);
    free(_isButtonUnlocked);
    free(_blockEffectSelectorArray);
}

- (void)operateBlockTypeWithAmount:(unsigned int)amount {
    
    BlockType selectedBlockType = not_a_block;
    unsigned int LoopCount = 0;
    
    while (LoopCount < amount) {
        if (_userCombo >= [GameSetting shared].timerComboCount) {
            // 콤보 풀이라면 타이머 블록이 반드시 생성.
            selectedBlockType = special_timer;
            NSLog(@"Combo gauge is full. Selected block type = %d\n", selectedBlockType);
            NSLog(@"Resetting combo point to 0.\n");
            [self addComboPoint:(-1)*_userCombo];
            [_blockGroup queueBlockType:selectedBlockType];
            
            [[GameCommon shared] playSound:[GameSetting shared].soundComboFull];

        }
        else {
            [[GameCommon shared] playSound:[GameSetting shared].soundBlockRemove];
            
            // 점수에 따른 블록 해제 여부 점검
            if (_blockUnlockCount < _regularBlockTypeCount) {
                for (int i = 0; i < _regularBlockTypeCount; i++) {
                    if (_isBlockUnlocked[i] == 1) {
                        continue;
                    }
                    else {
                        if ([GameSetting shared].blockTypeUnlockScore[i] <= _userScore) {
                            _isBlockUnlocked[i] = 1;
                            _blockUnlockCount++;
                            if (i % 2 == 0) {
                                _blockColorUnlockCount++;
                            }
                        }
                    }
                }
            }
            
            // 특수 블럭 생성 확률
            if (_userScore <= [GameSetting shared].specBlkPMinScore) {
                _rateArray[_specBlockIndex] = 0;
            }
            else if (_userScore < [GameSetting shared].specBlkPMaxScore) {
                _rateArray[_specBlockIndex] = [GameSetting shared].specBlkPMax * sinf((_userScore - [GameSetting shared].specBlkPMinScore) * M_PI / (2.0 * ([GameSetting shared].specBlkPMaxScore - [GameSetting shared].specBlkPMinScore)));
            }
            else {
                _rateArray[_specBlockIndex] = [GameSetting shared].specBlkPMax;
            }
            
            // 일반 블럭 생성 확률
            double leftoverRange = 1.0 - _rateArray[_specBlockIndex];
            //        double rangeDiv = leftoverRange / _specBlockIndex * 2;
            double rangeDiv = leftoverRange / _blockColorUnlockCount;
            double enhancedBlockP = rangeDiv;
            double normalBlockP = 0;
            // 일반 블럭 중 강화 블럭 생성 확률
            if (_userScore <= [GameSetting shared].enhancedBlkPMinScore) {
                enhancedBlockP *= 0;
            }
            else if (_userScore < [GameSetting shared].enhancedBlkPMaxScore) {
                enhancedBlockP *= [GameSetting shared].enhancedBlkPMax * sinf((_userScore - [GameSetting shared].specBlkPMinScore) * M_PI / (2.0 * ([GameSetting shared].specBlkPMaxScore - [GameSetting shared].specBlkPMinScore)));
            }
            else {
                enhancedBlockP *= [GameSetting shared].enhancedBlkPMax;
            }
            // 일반 블럭 중 일반 블럭 생성 확률
            normalBlockP = rangeDiv - enhancedBlockP;
            
            // 각 블럭별 확률 대입
            for (int i = 0; i < _specBlockIndex; i += 2) {
                if (_isBlockUnlocked[i + 1] == 0) {
                    // 강화블럭이 언락되지 않은 경우
                    _rateArray[i] = rangeDiv * _isBlockUnlocked[i]; // 이 색깔의 블럭 자체가 아직 풀리지 않았다면 _isBlockUnlocked[i] == 0이다.
                    _rateArray[i + 1] = 0;
                }
                else {
                    // 강화블럭이 언락된 경우
                    _rateArray[i] = normalBlockP;
                    _rateArray[i + 1] = enhancedBlockP;
                }
            }
            
            // 확률 결정 종료. 이제 난수에 따라 무슨 블록을 생성할 지 결정한다.
            
            
            // NSLog: 정해진 확률 테이블 출력
            NSLog(@"Current player score = %d\n", _userScore);
            NSLog(@"Calculated block type probability table:\n");
            double cDF = 0;
            for (int i = 0; i < _arrayElementCount; i++) {
                NSLog(@"Type %d = %lf\n", i, _rateArray[i]);
                cDF += _rateArray[i];
            }
            NSLog(@"Sum of probability = %lf\n", cDF);
            
            // 추가해야 할 블록의 수만큼 난수를 뽑아 블록 타입을 결정한 후, 블록그룹의 큐에 이 값을 넣는다.
            while (LoopCount < amount) {
                double randNormalized = (double)arc4random() / ARC4RANDOM_MAX;
                NSLog(@"Normalized arc4random() result: %lf\n", randNormalized);
                double currentCumaltiveP = 0;
                for (int i = 0; i < _specBlockIndex; i++) {
                    currentCumaltiveP += _rateArray[i];
                    if (randNormalized <= currentCumaltiveP) {
                        selectedBlockType = i;
                        break;
                    }
                }
                
                // 특수 블럭 생성
                if (selectedBlockType == not_a_block) {
                    selectedBlockType = special_bonus;
                }
                
                NSLog(@"Selected block type = %d\n", selectedBlockType);
                [_blockGroup queueBlockType:selectedBlockType];
                
                LoopCount++;
            }
            
        }
        
        LoopCount++;
    }
    
    
}

- (void)operateButtonUnlock {
    for (int i = 0; i < [GameSetting shared].buttonTypeCount; i++) {
        if (_isButtonUnlocked[i] == 1) {
            continue;
        }
        else {
            if ([GameSetting shared].blockTypeUnlockScore[i * 2] <= _userScore) {
                NSLog(@"%d", [GameSetting shared].blockTypeUnlockScore[i * 2]);
                _isButtonUnlocked[i] = 1;
                [_buttonGroup addButtonWithAmount:1];
            }
        }
    }
}

// 터치 이벤트 핸들러
- (void)touchEventHandlerWithCGPoint:(CGPoint)touchPoint {
    if (!(_isGameActive)) {
        return;
    }
    
    if ([_blockGroup isBusy]) {
        // 블록그룹 객체가 바쁘다면 터치 동작 수행을 하지 않는다.
        return;
    }
    
    BlockType touchedButtonType = [_buttonGroup blockTypeCheckWithCGPoint:touchPoint];
    BlockType bottomBlockType = [_blockGroup bottomBlockType];
    
    if (touchedButtonType == not_a_block) {
        // 버튼 외의 부분을 누름.
        return;
    }
    
    if ([GameSetting shared].buttonBlockBindingArray[bottomBlockType] == touchedButtonType ||
        [GameSetting shared].buttonBlockBindingArray[bottomBlockType] == special_common) {
        // 제대로 된 버튼을 누름.
        
        [self blockHealthHandler];
        _bottomBlockHealth--;
        
        if (!([GameSetting shared].buttonBlockBindingArray[bottomBlockType] == special_common)) {
            [self addComboPoint:1];
            [self addHitStreak:1];
            if (_userHitStreak >= [GameSetting shared].streakLabelActiveCount) {
                [_uiGroup updateStreakLabel:_userHitStreak];
            }
        }
        [self addScore];
        
        NSLog(@"Bottom block health reduced to %d\n", _bottomBlockHealth);
        if (_bottomBlockHealth == 0) {
            if (_blockColorUnlockCount < [GameSetting shared].buttonTypeCount) {
                [self operateButtonUnlock];
            }
            [self operateBlockTypeWithAmount:1];
            [_blockGroup removeBlockWithAmount:1 userResponseTime:_userResponseTime];
            _userResponseTime = 0.0f;
            // 효과 호출 부분 넣기
            ((void (*)(id, SEL))[self methodForSelector:_blockEffectSelectorArray[bottomBlockType]])(self, _blockEffectSelectorArray[bottomBlockType]);
        }
        else {
            [[GameCommon shared] playSound:[GameSetting shared].soundEnhancedBlockCrack];
            [_blockGroup weakenBottomBlock];
        }
        
    }
    else {
        // 잘못된 버튼을 누름 : 콤보 포인트 소실
        NSLog(@"Wrong button pushed. Resetting combo point to 0.\n");
        [[GameCommon shared] playSound:[GameSetting shared].soundWrongButton];
        
        [self addComboPoint:(-1)*_userCombo];
        [self addHitStreak:(-1)*_userHitStreak];

    }
    
}


- (void)normalBlockEffect {
}


- (void)specialBlockEffect {
    // 버튼 위치 뒤섞기
    [[GameCommon shared] playSound:[GameSetting shared].soundSpecialEffect];
    
    [_buttonGroup shuffleButtons];
}


- (void)timerBlockEffect {
    [[GameCommon shared] playSound:[GameSetting shared].soundTimerEffect];

    _remainingTime += [GameSetting shared].timeBonusAmount;
    if (_remainingTime > [GameSetting shared].timeLimit) {
        _remainingTime = [GameSetting shared].timeLimit;
    }
}

- (void)startGame {
    NSLog(@"Game started.");
//    _userScore = 50000;
    
    [[GameCommon shared] playSound:[GameSetting shared].soundBGM];
    
    _isGameActive = true;
    [self operateBlockTypeWithAmount:[GameSetting shared].blockVisibleCount];
    [_blockGroup fillBlockGroup];
    [self blockHealthHandler];
    [self operateButtonUnlock];
}



- (void)blockHealthHandler {
    // GameLogic 내에서 그냥 간단하게 맨 아래 블록의 체력만 관리한다. 여기서는 하단 블럭의 체력을 세팅값에서 로딩한다.
    if (_bottomBlockHealth == 0) {
        _bottomBlockHealth = [GameSetting shared].blockTypeDurabilityArray[[_blockGroup bottomBlockType]];
        NSLog(@"Loaded bottom block initial health = %d", _bottomBlockHealth);
    }
}


// 점수 가산 메소드
- (void)addScore {
    _userScore += [GameSetting shared].blockTypeRemovalScore[[_blockGroup bottomBlockType]];
    NSLog(@"Player Score updated to %d", _userScore);
    [_uiGroup updateScoreLabel:_userScore];
}


// 콤보 포인트 처리 메소드
- (void)addComboPoint:(int)amount {
    if (amount < 0) {
        NSAssert(_userCombo + amount >= 0, @"GameLogic addComboPoint: given value causes _userCombo to overflow.\n");
    }
    
    _userCombo += amount;
    NSLog(@"Current combo point = %d\n", _userCombo);
    [_uiGroup updateComboBarWithPercentage:(double)_userCombo / (double)([GameSetting shared].timerComboCount) * 100.0f];
}

// 매 프레임간 지나간 시간을 처리하는 메소드
- (void)updatedTimeHandler: (CCTime)deltaTime {
    if (!(_isGameActive)) {
        return;
    }
    
    _userResponseTime += (float)deltaTime;
    _remainingTime -= (double)deltaTime;
    if (_remainingTime < 0) {
        _remainingTime = 0.0f ;
        _isGameActive = false;
        [self gameOver];
    }
    [_uiGroup updateTimerBarWithPercentage:_remainingTime / [GameSetting shared].timeLimit * 100.0f];
}

// 게임 오버 상황 시작 메소드
- (void)gameOver {
    [[GameCommon shared] playSound:[GameSetting shared].soundTimeOver];
    
    [_blockGroup gameOver];
    [[GameCommon shared] bgmFadeOutWithDuration:[GameSetting shared].bgmFadeOutDuration scene:_attachedScene];
//    [- (void)bgmFadeOutWithDuration:(unsigned int)duration scene:(CCScene*)scene
    
    
    // 지정한 시간만큼 장면 전환 지연
    [self performSelector:@selector(gameOverEventHandler)
               withObject:nil
               afterDelay:[GameSetting shared].gameOverSceneSwitchingDelay];
}

// 프로토콜 메소드: 소속된 Scene에게 다음 Scene으로 넘어가게 한다.
- (void)gameOverEventHandler {
    [[GameCommon shared] bgmStop];
    
    id <GameOverEventProtocol> delegate = (id)_attachedScene;
    [delegate gameOverEventHandler];
}

- (void)addHitStreak:(int)amount {
    unsigned int _oldStreak = _userHitStreak;
    _userHitStreak += amount;
    NSLog(@"Current player streak = %d",_userHitStreak);
    
    for (int i = 0; i < [GameSetting shared].streakSoundThresholdCount; i++) {
        if (_userHitStreak < [GameSetting shared].streakSoundThreholdArray[i]) {
            break;
        }
        if (_oldStreak < [GameSetting shared].streakSoundThreholdArray[i]) {
            [[GameCommon shared] playStreakSoundWithKey:i];
            break;
        }
    }
    
    if (_userHitStreak >= [GameSetting shared].streakEffectHitCount) {
        [_uiGroup showComboBG];
    }
    else {
        [_uiGroup hideComboBG];
    }
}

@end
