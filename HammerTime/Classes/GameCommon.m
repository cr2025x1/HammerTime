//
//  GameCommon.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/23/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "GameCommon.h"

@interface GameCommon (private)
- (void)doNothing;
- (void)playSoundBGM;
- (void)playSoundBlockRemove;
- (void)playSoundTimerEffect;
- (void)playSoundSpecialEffect;
- (void)playSoundComboFull;
- (void)playSoundTimeOver;
- (void)playSoundWrongButton;
- (void)playSoundEnhancedBlockCrack;
- (void)playSoundStartCountTick;
- (void)playSoundStartCountComplete;
- (void)bgmFadeInner;
- (void)playStreakSoundInner:(unsigned int)key;
- (void)doNothingWithKey:(unsigned int)key;


@end


#pragma mark - GameCommon Implementation
// 공통 메소드들을 묶어두는 싱글톤 라이브러리 메소드
@implementation GameCommon {
    GameSetting* _gSetSO;
    
    OALSimpleAudio* _soundEngine;
    float _bgVolumeIncrement;
    SEL* _streakSoundLib;
}
-(id) init
{
    self = [super init];
    if (!self) return(nil);
    
    _soundEngine = [OALSimpleAudio sharedInstance];
    _gSetSO = [GameSetting shared];
    
    _soundLibrary = [NSMutableDictionary dictionaryWithCapacity:11];
    [_soundLibrary setValue:[NSValue valueWithPointer:@selector(doNothing)] forKey:@""];
    if (!([_gSetSO.soundBGM isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundBGM)] forKey:_gSetSO.soundBGM];
    }
    if (!([_gSetSO.soundBlockRemove isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundBlockRemove)] forKey:_gSetSO.soundBlockRemove];
    }
    if (!([_gSetSO.soundTimerEffect isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundTimerEffect)] forKey:_gSetSO.soundTimerEffect];
    }
    if (!([_gSetSO.soundSpecialEffect isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundSpecialEffect)] forKey:_gSetSO.soundSpecialEffect];
    }
    if (!([_gSetSO.soundComboFull isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundComboFull)] forKey:_gSetSO.soundComboFull];
    }
    if (!([_gSetSO.soundTimeOver isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundTimeOver)] forKey:_gSetSO.soundTimeOver];
    }
    if (!([_gSetSO.soundWrongButton isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundWrongButton)] forKey:_gSetSO.soundWrongButton];
    }
    if (!([_gSetSO.soundEnhancedBlockCrack isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundEnhancedBlockCrack)] forKey:_gSetSO.soundEnhancedBlockCrack];
    }
    if (!([_gSetSO.soundStartCountTick isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundStartCountTick)] forKey:_gSetSO.soundStartCountTick];
    }
    if (!([_gSetSO.soundStartCountComplete isEqual:@""])) {
        [_soundLibrary setValue:[NSValue valueWithPointer:@selector(playSoundStartCountComplete)] forKey:_gSetSO.soundStartCountComplete];
    }
    
    _bgVolumeIncrement = 0.0f;
    
    // Streak Sound Library
    _streakSoundLib = (SEL*)malloc(sizeof(SEL)*_gSetSO.streakSoundThresholdCount);
    for (int i = 0; i < [GameSetting shared].streakSoundThresholdCount; i++) {
        if (!([_gSetSO.streakSoundThreholdEffectArray[i] isEqual:@""])) {
            _streakSoundLib[i] = @selector(playStreakSoundInner:);
        }
        else {
            _streakSoundLib[i] = @selector(doNothingWithKey:);
        }
    }

    
    return self;
}

static GameCommon *shared = nil;

+ (GameCommon *) shared
{
    @synchronized(self)
    {
        if (shared == nil)
        {
            shared = [[self alloc] init];
        }
    }
    
    return shared;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(shared == nil)
        {
            shared = [super allocWithZone:zone];
            return shared;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)dealloc {
    free(_streakSoundLib);
}


#pragma mark - Frame Loader
// 주어진 스프라이트시트를 잘라서 인수로 주어진 NSMutableArray에 잘라낸 프레임들을 넣어줌.
- (void)loadFrameFromSprite:(CCTexture *)SourceTexture withTargetArray:(NSMutableArray *)TargetArray withTopLeftX:(float)TopLeftX withTopLeftY:(float)TopLeftY withSizeX:(float)SizeX withSizeY:(float)SizeY withHorizontalCount:(int)HorizontalCount withVerticalCount:(int)VerticalCount isLoadingDirectionHorizontal:(bool)IsHorizontallySorted withTotalFrameCount:(int)FrameCount
{
    CCSpriteFrame *frame = nil;
    int FrameProcessedCounter = 0;
    CGRect aRect;
    int loopCount[2];
    int* varSelector[2];
    int i;
    int j;
    
    // 주어진 인수 검사
    assert(TargetArray != nil);
    assert(TopLeftX >= 0);
    assert(TopLeftY >= 0);
    assert(SourceTexture.contentSizeInPixels.width > TopLeftX);
    assert(SourceTexture.contentSizeInPixels.height > TopLeftY);
    assert(SizeX > 0);
    assert(SizeY > 0);
    assert(HorizontalCount > 0);
    assert(VerticalCount > 0);
    assert(HorizontalCount*VerticalCount >= FrameCount);
    assert(SourceTexture.contentSizeInPixels.width >= SizeX*HorizontalCount);
    assert(SourceTexture.contentSizeInPixels.height >= SizeY*VerticalCount);
    
    // 수평/수직 읽기 인수에 따른 내부 동작값 설정
    if (IsHorizontallySorted) {
        loopCount[0] = VerticalCount;
        loopCount[1] = HorizontalCount;
        varSelector[0] = &j;
        varSelector[1] = &i;
    }
    else {
        loopCount[0] = HorizontalCount;
        loopCount[1] = VerticalCount;
        varSelector[0] = &i;
        varSelector[1] = &j;
    }
    
    // 주어진 스프라이트 시트를 주어진 크기에 맞춰 잘라낸 후 인수로 주어진 NSMutableArray에 넣어줌.
    for (i = 0; i < loopCount[0]; i++) {
        for (j = 0; j < loopCount[1]; j++) {
            aRect = CGRectMake(TopLeftX + SizeX*(*varSelector[0]), TopLeftY + SizeY*(*varSelector[1]), SizeX, SizeY);
            frame = [CCSpriteFrame frameWithTexture:SourceTexture rectInPixels:aRect rotated:false offset:ccp(0,0) originalSize:CGSizeMake(SizeX, SizeY)];
            [TargetArray addObject:frame];
            FrameProcessedCounter++;
            if (FrameProcessedCounter >= FrameCount)
            {
                return;
            }
        }
    }
    
}



#pragma mark - Magnitude of Vector
// 피타고라스의 정리를 이용한 벡터의 크기 반환. 도대체가 이런 것도 기본적인 함수로 제공을 안 해주다니...
- (float)magnitude:(CGPoint)vector {
    return sqrtf(powf(vector.x, 2) + powf(vector.y, 2));
}



#pragma mark - Randomization of CGPoint Array
// 주어진 CGPoint 값의 배열의 원소들을 무작위로 뒤섞어주는 메소드
- (void)randomizeArray:(CGPoint*)array startingIndex:(int)startingIndex endingIndex:(int)endingIndex {
    NSAssert(endingIndex >= startingIndex, @"GameCommon randomizeArray: endingIndex must not be less than startingIndex.\n");
    
    for (int i = startingIndex; i < endingIndex; i++) {
        int randomIndex = arc4random() % (endingIndex - i + 1) + i;
        CGPoint tempValue;
        if (startingIndex == randomIndex) {
            continue;
        }
        
        tempValue = array[i];
        array[i] = array[randomIndex];
        array[randomIndex] = tempValue;
    }
}



//#pragma mark - Randomization of id NSMutableArray
//// 주어진 CGPoint 값의 배열의 원소들을 무작위로 뒤섞어주는 메소드
//- (void)randomizeNSMutableArray:(NSMutableArray*)array startingIndex:(int)startingIndex endingIndex:(int)endingIndex {
//    NSAssert(endingIndex >= startingIndex, @"GameCommon randomizeArray: endingIndex must not be less than startingIndex.\n");
//    
//    for (int i = startingIndex; i < endingIndex; i++) {
//        int randomIndex = arc4random() % (endingIndex - i + 1) + i;
//        id tempValue;
//        if (startingIndex == randomIndex) {
//            continue;
//        }
//        
//        tempValue = array[i];
//        array[i] = array[randomIndex];
//        array[randomIndex] = tempValue;
//    }
//}




- (void)doNothing {
//    NSLog(@"Do nothing invoked\n");
    
}

- (void)playSoundBGM {
    [_soundEngine playBg:[GameSetting shared].soundBGM loop:true];
}

- (void)playSoundBlockRemove {
    [_soundEngine playEffect:[GameSetting shared].soundBlockRemove];
}

- (void)playSoundTimerEffect {
    [_soundEngine playEffect:[GameSetting shared].soundTimerEffect];
}

- (void)playSoundSpecialEffect {
    [_soundEngine playEffect:[GameSetting shared].soundSpecialEffect];
}

- (void)playSoundComboFull {
    [_soundEngine playEffect:[GameSetting shared].soundComboFull];
}

- (void)playSoundTimeOver {
    [_soundEngine playEffect:[GameSetting shared].soundTimeOver];
}

- (void)playSoundWrongButton {
    [_soundEngine playEffect:[GameSetting shared].soundWrongButton];
}

- (void)playSoundEnhancedBlockCrack {
    [_soundEngine playEffect:[GameSetting shared].soundEnhancedBlockCrack];
}

- (void)playSoundStartCountTick {
    [_soundEngine playEffect:[GameSetting shared].soundStartCountTick];
}

- (void)playSoundStartCountComplete {
    [_soundEngine playEffect:[GameSetting shared].soundStartCountComplete];
}

- (void)playSound:(NSString*)soundKey {
    // 사실 다 만들어놓고 보니 그냥 if문 쓰는 게 나은 거 같다. 하지만 귀찮으니 그대로 놔둘래. 뭐 어쩄던 soundBGM은 이거 덕을 보니까.
    SEL soundPTR = [[self.soundLibrary objectForKey:soundKey] pointerValue];
    ((void (*)(id, SEL))[self methodForSelector:soundPTR])(self, soundPTR);
}

- (void)bgmFadeOutWithDuration:(float)duration scene:(CCScene*)scene {
    _bgVolumeIncrement = _soundEngine.bgVolume / (duration/0.02f);
    
    id <SoundFadeProtocol> delegate = (id)scene;
    [delegate soundFadeEventHandlerWithDuration:duration];
}

- (void)bgmFadeInner {
    _soundEngine.bgVolume -= _bgVolumeIncrement;
    if (_soundEngine.bgVolume < 0) {
        _soundEngine.bgVolume = 0;
    }
    NSLog(@"vol = %lf\n", _soundEngine.bgVolume);
}

- (void)bgmStop {
    [_soundEngine stopBg];
}

- (void)playStreakSoundWithKey:(unsigned int)key {
    SEL selector = _streakSoundLib[key];
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL, unsigned int *) = (void *)imp;
    func(self, selector, key);
}

- (void)playStreakSoundInner:(unsigned int)key {
    NSLog(@"Playing sound \"%@\". (Key = %d)\n", _gSetSO.streakSoundThreholdEffectArray[key], key);
    [_soundEngine playEffect:_gSetSO.streakSoundThreholdEffectArray[key]];
}

- (void)doNothingWithKey:(unsigned int)key {
    NSLog(@"Playing sound \"%@\"(NULL). (Key = %d)\n", _gSetSO.streakSoundThreholdEffectArray[key], key);
}

////- (void)bgmFadeOutWithDuration:(unsigned int)duration {
//    float currentVolume = _soundEngine.bgVolume;
////    id fadeOut = [CCActionTween actionWithDuration:duration key:@"bgVolume" from:currentVolume to:0.0f];
////    [[[CCDirector sharedDirector] actionManager] addAc
////    CCNode* testNode = [CCNode node];
////    [[[CCDirector sharedDirector] ccaction];
//
//
//
////    [[[CCDirector sharedDirector] actionManager] addAction:fadeOut target:[SimpleAudioEngine sharedEngine] paused:NO];
//    
//}


@end


