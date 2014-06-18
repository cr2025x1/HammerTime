//
//  GameSetting.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/23/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GameCommon.h"

// 각 블록의 타입값. 새로운 종류의 블록을 만들 때 여기에 등록할 것.
enum BlockType {
    red_normal = 0,
    red_reinforced,
    green_normal,
    green_reinforced,
    blue_normal,
    blue_reinforced,
    magenta_normal,
    magenta_reinforced,
    special_bonus,
    special_timer,
    special_common,
    not_a_block
};
typedef enum BlockType BlockType;

@interface GameSetting : NSObject {
    // 블록 및 블록 그룹 환경변수
    unsigned int _blockSizeX;
    unsigned int _blockSizeY;
    unsigned int _blockPixelSizeX;
    unsigned int _blockPixelSizeY;
    unsigned int _blockTypeCount;
    unsigned int _blockFrameCount;
    float _blockFrameDelay;
    float _blockFallAcceleration;
    float _blockBumpDuration;
    float _blockInflationRatio;
    unsigned int _blockVisibleCount; // reserveCount = visibleCount로 설정함.
    NSString* _blockTextureFile;
    int _blockZOrder;
    unsigned int* _blockTypeDurabilityArray; // 각 블럭타입당 내구도 정보
    unsigned int _blockFragTypeCount; // 블록 파편의 종류 개수 (각 블록타입당)
    unsigned int _blockFragGenCount; // 한 블록 파괴시 발생 파편 개수
    unsigned int _blockFragSizePixelX; // 블록 파편의 좌우폭 픽셀크기
    unsigned int _blockFragSizePixelY; // 블록 파편의 상하폭 픽셀크기
    float _blockFragAnglerVelocityMax; // 블록 파편의 회전속도 최대한도
    float _blockFragAnglerVelocityMin; // 블록 파편의 회전속도 최저한도
    float _blockFragVelocityMax; // 블록 파편의 비산속도 최대크기
    float _blockFragVelocityMin; // 블록 파편의 비산속도 최저크기
    float _blockFragAngleMax; // 블록 파편의 비산각도 최대 크기
    float _blockFragAngleMin; // 블록 파편의 비산각도 최저 크기
    float _blockFragGravAcc; // 블록 파편의 낙하가속도 (아래로 떨어지려면 음수여야 한다!)
    NSString* _blockFragTextureFile; // 블록 파편 스프라이트 시트 파일
    int _blockFragZOrder; // 블록 파편의 Z축 위치
    CGPoint _blockGroupBaseCGP; // 블록 그룹의 바닥 중심 위치 (블록이 떨어져 부딪히는 그 바닥의 중심점)
    float _blockFallDurationMax; // 자유낙하 소요시간 최대허용치
    float _blockGap; // 블록간 갭
    int _blockFallAccDirection; // 블록의 낙하 가속도 방향벡터(입력값은 단위벡터로 정규화되어 처리됨)
    
    // 버튼 및 버튼 그룹 환경변수
    unsigned int _buttonTypeCount;
    unsigned int _buttonFrameCount;
    float _buttonFrameDelay;
    unsigned int _buttonSizeX;
    unsigned int _buttonSizeY;
    unsigned int _buttonPixelSizeX;
    unsigned int _buttonPixelSizeY;
    unsigned int _buttonGroupCapacity; // 버튼의 최대 개수
    unsigned int _buttonInitialCount; // 시작시 버튼 개수
    NSString* _buttonTextureFile; // 버튼 객체에 쓸 스프라이트 시트 파일명
    int _buttonZOrder; // 버튼의 배치노드의 z축 위치
    NSArray* _buttonPositionArray; // 버튼의 위치 데이터 배열
    
    // 게임 로직 환경변수
    double _specBlkPMax; // 특수 블록 생성 확률 최고치
    unsigned int _specBlkPMinScore; // 특수 블록 생성 확률이 생기는 최저 상한 점수 (생성 확률 상승치는 정리 노트 참조)
    unsigned int _specBlkPMaxScore; // 특수 블록 생성 확률 최고치에 도달하는 점수 (생성 확률 상승치는 정리 노트 참조)
    unsigned int _specBlkEffectCount; // 특수 블록 랜덤 효과 개수
    double _enhancedBlkPMax; // 각 색상별 강화블럭 생성 확률 최고치
    unsigned int _enhancedBlkPMinScore; // 각 색상별 강화블럭 생성 확률이 생기는 최저 상한 점수 (생성 확률 상승치는 정리 노트 참조)
    unsigned int _enhancedBlkPMaxScore; // 각 색상별 강화블럭 생성 확률 최고치에 도달하는 점수 (생성 확률 상승치는 정리 노트 참조)
    unsigned int* _blockTypeUnlockScore; // 각 색상별 블럭 언락 점수
    BlockType* _buttonBlockBindingArray; // 각 블럭과 버튼당 바인딩 정보
    unsigned int* _blockTypeRemovalScore; // 각 블럭 제거시 주어지는 점수
    unsigned int _timerComboCount; // 타이머 블록을 주는 콤보 숫자
    double _timeLimit; // 처음 주어지는 시간 (그리고 타이머의 최대 수치)
    double _timeBonusAmount; // 타임 보너스 때 가산되는 시간
    double _gameOverSceneSwitchingDelay; // 게임 오버시 다음 씬으로 넘어가기 이전의 딜레이 시간
    double _gameStartCountStartDelay; // 게임 시작 카운트가 시작되기 이전의 딜레이 시간
    NSString* _soundBGM; // 배경음 소리 파일
    NSString* _soundBlockRemove; // 일반 블록이 파괴되는 소리
    NSString* _soundTimerEffect; // 시간 연장 블록이 파괴되는 소리 (=타이머 효과 발동 소리)
    NSString* _soundSpecialEffect; // 버튼 위치 섞기 블록 파괴 소리 (=버튼 위치 섞기 효과 발동 소리)
    NSString* _soundComboFull; // 콤보 블록 생성 소리 (=콤보 게이지가 풀로 채워졌을 때 나는 소리)
    NSString* _soundTimeOver; // 제한 시간이 소진되었을 때 나는 소리 (=게임 오버 시 나는 소리)
    NSString* _soundWrongButton; // 다른 색상의 버튼을 눌렀을 때 나는 소리 (=버튼을 잘못 눌렀을 때 나는 소리, 콤보가 초기화되는 소리)
    NSString* _soundEnhancedBlockCrack; // 강화 블럭이 금가는 소리
    NSString* _soundStartCountTick; // 시작 카운터의 숫자가 줄어들 때 나는 소리 (=맨 마지막 프레임 제외한 프레임의 등장 소리)
    NSString* _soundStartCountComplete; // 시작 카운터가 끝났을 때 나는 소리 (=맨 마지막 프레임 등장 소리)
    float _bgmFadeOutDuration; // 게임 오버시 배경음 페이드아웃 효과 진행시간
    unsigned int _streakEffectHitCount; // 콤보 배경을 드러내는 연속 적중수
    unsigned int _streakSoundThresholdCount; // 사운드 재생 연속 적중수 경계점의 개수
    unsigned int* _streakSoundThreholdArray; // 사운드 재생 연속 적중수 경계점 배열
    NSMutableArray* _streakSoundThreholdEffectArray; // 사운드 재생 연속 적중수 경계점 재생 사운드 배열
//    NSString __strong** _streakSoundThreholdEffectArray; // 사운드 재생 연속 적중수 경계점 재생 사운드 배열
    
    // UI그룹 환경변수
    NSString* _timerBarTextureFile; // 타이머 바 스프라이트 파일
    NSString* _timerBGTextureFile; // 타이머 배경 스프라이트 파일
    CGPoint _timerPosition; // 타이머의 화면상 위치
    CGPoint _timerAnchorPoint; // 타이머의 앵커포인트
    int _timerBarZOrder; // 타이머 바의 화면상 z축 위치
    int _timerBGZOrder; // 타이머 배경의 화면상 z축 위치
    NSString* _comboBarTextureFile; // 콤보 바 스프라이트 파일
    NSString* _comboBGTextureFile; // 콤보 배경 스프라이트 파일
    NSString* _comboFHTextureFile; // 콤보 피겨헤드 스프라이트 파일
    CGPoint _comboPosition; // 콤보의 화면상 위치
    CGPoint _comboAnchorPoint; // 콤보의 앵커포인트
    int _comboBarZOrder; // 콤보 바의 화면상 z축 위치
    int _comboBGZOrder; // 콤보 배경의 화면상 z축 위치
    int _comboFHZOrder; // 콤보 피겨헤드의 화면상 z축 위치
    float _comboFHScaleDuration; // 콤보 피겨헤드의 확대/축소 에니메이션에 걸리는 시간
    float _comboFHScaleSize; // 콤보 피겨헤드의 최대 확대 비율
    NSString* _startCountTextureFile; // 스타트 카운터 스프라이트 파일
    unsigned int _startCountFrameCount; // 스타트 카운터 프레임의 수
    unsigned int _startCountPixelSizeX; // 스타트 카운터 픽셀 크기 X축
    unsigned int _startCountPixelSizeY; // 스타트 카운터 픽셀 크기 Y축
    CGPoint _startCountPosition; // 스타트 카운터의 화면상 위치
    CGPoint _startCountAnchorPoint; // 스타트 카운터의 앵커포인트
    int _startCountZOrder; // 스타트 카운터의 화면상 z축 위치
    float _startCountJumpHeight; // 스타트 카운터의 점프 높이
    float _startCountScaleSize; // 스타트 카운터 확대비율
    float _startCountFadeDuration; // 스타트 카운터의 페이드아웃 시간
    float _startCountTimePerFrame; // 스타트 카운트 도중 매 프레임간 소요시간 (맨 마지막 완주 프레임은 _startCountFadeDuration을 사용함)
    float _startCountTimeTotal; // 스타트 카운트에 소요되는 전체 시간 (역시 맨 마지막 완주 프레임 제외)
    bool _isScoreFontSprite; // 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정
    NSString* _ScoreLabelTTFFontName; // 스코어 라벨의 폰트명 (TTF)
    unsigned int _ScoreLabelTTFFontSize; // 스코어 라벨의 폰트 사이즈 (TTF)
    CCColor* _ScoreLabelTTFColor; // 스코어 라벨의 폰트 색상 (TTF)
    NSString* _ScoreLabelAtlasTextureFile; // 스코어 라벨의 폰트 스프라이트 (Atlas)
    float _ScoreLabelAtlasFontSizeX; // 스코어 라벨의 폰트 좌우폭
    float _ScoreLabelAtlasFontSizeY; // 스코어 라벨의 폰트 상하폭
    CGPoint _ScoreLabelAnchorPoint; // 스코어 라벨의 앵커포인트
    CGPoint _ScoreLabelPosition; // 스코어 라벨의 위치
    int _ScoreLabelZOrder; // 스코어 라벨의 Z축 위치
    int _backgroundZOrder; // 배경 노드의 z축 위치
    int _backgroundComboZOrder; // 콤보 배경 노드의 z축 위치
    int _backgroundUIZOrder; // 배경 UI 노드의 z축 위치
    int _comboFHPositionModifier; // 콤보 피겨헤드의 좌/우측 위치 결정. (-1: 좌측, 1: 우측)
    int _backgroundUpperZOrder; // 배경 위의 객체가 담긴 노드의 z축 위치
    bool _isStreakFontSprite; // 콤보 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정
    NSString* _streakLabelTTFFontName; // 콤보 라벨의 폰트명 (TTF)
    unsigned int _streakLabelTTFFontSize; // 콤보 라벨의 폰트 사이즈 (TTF)
    CCColor* _streakLabelTTFColor; // 콤보 라벨의 폰트 색상 (TTF)
    NSString* _streakLabelAtlasTextureFile; // 콤보 라벨의 폰트 스프라이트 (Atlas)
    float _streakLabelAtlasFontSizeX; // 콤보 라벨의 폰트 좌우폭
    float _streakLabelAtlasFontSizeY; // 콤보 라벨의 폰트 상하폭
    CGPoint _streakLabelAnchorPoint; // 콤보 라벨의 앵커포인트
    CGPoint _streakLabelPosition; // 콤보 라벨의 위치
    int _streakLabelZOrder; // 콤보 라벨의 Z축 위치
    float _streakLabelJumpHeight; // 콤보 라벨의 점프 높이
    float _streakLabelJumpDuration; // 콤보 라벨의 점프 소요 시간
    float _streakLabelFadeDelay; // 콤보 라벨의 페이드아웃 시작 이전 대기 시간
    float _streakLabelFadeDuration; // 콤보 라벨의 페이드아웃 시간
    unsigned int _streakLabelActiveCount; // 콤보 라벨이 활성화되는 적중 연속수 최소 한계치
}

// 블록 및 블록 그룹 접근자
@property (nonatomic, readonly) unsigned int blockSizeX;
@property (nonatomic, readonly) unsigned int blockSizeY;
@property (nonatomic, readonly) unsigned int blockTypeCount;
@property (nonatomic, readonly) unsigned int blockPixelSizeX;
@property (nonatomic, readonly) unsigned int blockPixelSizeY;
@property (nonatomic, readonly) unsigned int blockFrameCount;
@property (nonatomic, readonly) float blockFrameDelay;
@property (nonatomic, readonly) float blockFallAcceleration;
@property (nonatomic, readonly) float blockBumpDuration;
@property (nonatomic, readonly) float blockInflationRatio;
@property (nonatomic, readonly) unsigned int blockVisibleCount;
@property (nonatomic, readonly) NSString* blockTextureFile;
@property (nonatomic, readonly) int blockZOrder;
@property (nonatomic, readonly) unsigned int* blockTypeDurabilityArray;
@property (nonatomic, readonly) unsigned int blockFragTypeCount; // 블록 파편의 종류 개수 (각 블록타입당)
@property (nonatomic, readonly) unsigned int blockFragGenCount; // 한 블록 파괴시 발생 파편 개수
@property (nonatomic, readonly) unsigned int blockFragSizePixelX; // 블록 파편의 좌우폭 픽셀크기
@property (nonatomic, readonly) unsigned int blockFragSizePixelY; // 블록 파편의 상하폭 픽셀크기
@property (nonatomic, readonly) float blockFragAnglerVelocityMax; // 블록 파편의 회전속도 최대한도
@property (nonatomic, readonly) float blockFragAnglerVelocityMin; // 블록 파편의 회전속도 최저한도
@property (nonatomic, readonly) float blockFragVelocityMax; // 블록 파편의 비산속도 최대크기
@property (nonatomic, readonly) float blockFragVelocityMin; // 블록 파편의 비산속도 최저크기
@property (nonatomic, readonly) float blockFragAngleMax; // 블록 파편의 비산각도 최대 크기
@property (nonatomic, readonly) float blockFragAngleMin; // 블록 파편의 비산각도 최저 크기
@property (nonatomic, readonly) float blockFragGravAcc; // 블록 파편의 낙하가속도 (아래로 떨어지려면 음수여야 한다!)
@property (nonatomic, readonly) NSString* blockFragTextureFile; // 블록 파편 스프라이트 시트 파일
@property (nonatomic, readonly) int blockFragZOrder; // 블록 파편의 Z축 위치
@property (nonatomic, readonly) CGPoint blockGroupBaseCGP; // 블록 그룹의 바닥 중심 위치 (블록이 떨어져 부딪히는 그 바닥의 중심점)
@property (nonatomic, readonly) float blockFallDurationMax; // 자유낙하 소요시간 최대허용치
@property (nonatomic, readonly) float blockGap; // 블록간 갭
@property (nonatomic, readonly) int blockFallAccDirection; // 블록의 낙하 가속도 방향벡터(입력값은 단위벡터로 정규화되어 처리됨)


// 버튼 및 버튼 그룹 접근자
@property (nonatomic, readonly) unsigned int buttonSizeX;
@property (nonatomic, readonly) unsigned int buttonSizeY;
@property (nonatomic, readonly) unsigned int buttonTypeCount;
@property (nonatomic, readonly) unsigned int buttonPixelSizeX;
@property (nonatomic, readonly) unsigned int buttonPixelSizeY;
@property (nonatomic, readonly) unsigned int buttonGroupCapacity;
@property (nonatomic, readonly) unsigned int buttonInitialCount;
@property (nonatomic, readonly) NSString* buttonTextureFile;
@property (nonatomic, readonly) int buttonZOrder;
@property (nonatomic, readonly) NSArray* buttonPositionArray;
@property (nonatomic, readonly) unsigned int buttonFrameCount;
@property (nonatomic, readonly) float buttonFrameDelay;

// 게임 로직 환경변수
@property (nonatomic, readonly) double specBlkPMax;
@property (nonatomic, readonly) unsigned int specBlkPMinScore;
@property (nonatomic, readonly) unsigned int specBlkPMaxScore;
@property (nonatomic, readonly) unsigned int specBlkEffectCount;
@property (nonatomic, readonly) double enhancedBlkPMax;
@property (nonatomic, readonly) unsigned int enhancedBlkPMinScore;
@property (nonatomic, readonly) unsigned int enhancedBlkPMaxScore;
@property (nonatomic, readonly) unsigned int* blockTypeUnlockScore;
@property (nonatomic, readonly) BlockType* buttonBlockBindingArray;
@property (nonatomic, readonly) unsigned int* blockTypeRemovalScore;
@property (nonatomic, readonly) unsigned int timerComboCount;
@property (nonatomic, readonly) double timeLimit; // 처음 주어지는 시간 (그리고 타이머의 최대 수치)
@property (nonatomic, readonly) double timeBonusAmount; // 타임 보너스 때 가산되는 시간
@property (nonatomic, readonly) double gameOverSceneSwitchingDelay; // 게임 오버시 다음 씬으로 넘어가기 이전의 딜레이 시간
@property (nonatomic, readonly) double gameStartCountStartDelay; // 게임 시작 카운트가 시작되기 이전의 딜레이 시간
@property (nonatomic, readonly) NSString* soundBGM; // 배경음 소리 파일
@property (nonatomic, readonly) NSString* soundBlockRemove; // 일반 블록이 파괴되는 소리
@property (nonatomic, readonly) NSString* soundTimerEffect; // 시간 연장 블록이 파괴되는 소리 (=타이머 효과 발동 소리)
@property (nonatomic, readonly) NSString* soundSpecialEffect; // 버튼 위치 섞기 블록 파괴 소리 (=버튼 위치 섞기 효과 발동 소리)
@property (nonatomic, readonly) NSString* soundComboFull; // 콤보 블록 생성 소리 (=콤보 게이지가 풀로 채워졌을 때 나는 소리)
@property (nonatomic, readonly) NSString* soundTimeOver; // 제한 시간이 소진되었을 때 나는 소리 (=게임 오버 시 나는 소리)
@property (nonatomic, readonly) NSString* soundWrongButton; // 다른 색상의 버튼을 눌렀을 때 나는 소리 (=버튼을 잘못 눌렀을 때 나는 소리, 콤보가 초기화되는 소리)
@property (nonatomic, readonly) NSString* soundEnhancedBlockCrack; // 강화 블럭이 금가는 소리
@property (nonatomic, readonly) NSString* soundStartCountTick; // 시작 카운터의 숫자가 줄어들 때 나는 소리 (=맨 마지막 프레임 제외한 프레임의 등장 소리)
@property (nonatomic, readonly) NSString* soundStartCountComplete; // 시작 카운터가 끝났을 때 나는 소리 (=맨 마지막 프레임 등장 소리)
@property (nonatomic, readonly) float bgmFadeOutDuration; // 게임 오버시 배경음 페이드아웃 효과 진행시간
@property (nonatomic, readonly) unsigned int streakEffectHitCount; // 콤보 배경을 드러내는 연속 적중수
@property (nonatomic, readonly) unsigned int* streakSoundThreholdArray; // 사운드 재생 연속 적중수 경계점 배열
@property (nonatomic, readonly) NSMutableArray* streakSoundThreholdEffectArray; // 사운드 재생 연속 적중수 경계점 재생 사운드 배열
//@property (nonatomic, readonly) NSString __strong** streakSoundThreholdEffectArray; // 사운드 재생 연속 적중수 경계점 재생 사운드 배열
@property (nonatomic, readonly) unsigned int streakLabelActiveCount; // 콤보 라벨이 활성화되는 적중 연속수 최소 한계치
@property (nonatomic, readonly) unsigned int streakSoundThresholdCount; // 사운드 재생 연속 적중수 경계점의 개수

// UI그룹 환경변수
@property (nonatomic, readonly) NSString* timerBarTextureFile; // 타이머 바 스프라이트 파일
@property (nonatomic, readonly) NSString* timerBGTextureFile; // 타이머 배경 스프라이트 파일
@property (nonatomic, readonly) CGPoint timerPosition; // 타이머의 화면상 위치
@property (nonatomic, readonly) CGPoint timerAnchorPoint; // 타이머의 앵커포인트
@property (nonatomic, readonly) int timerBarZOrder; // 타이머의 화면상 z축 위치
@property (nonatomic, readonly) int timerBGZOrder; // 타이머 배경의 화면상 z축 위치
@property (nonatomic, readonly) NSString* comboBarTextureFile; // 콤보 바 스프라이트 파일
@property (nonatomic, readonly) NSString* comboBGTextureFile; // 콤보 배경 스프라이트 파일
@property (nonatomic, readonly) NSString* comboFHTextureFile; // 타이머 피겨헤드 스프라이트 파일
@property (nonatomic, readonly) CGPoint comboPosition; // 콤보의 화면상 위치
@property (nonatomic, readonly) CGPoint comboAnchorPoint; // 콤보의 앵커포인트
@property (nonatomic, readonly) int comboBarZOrder; // 콤보 바의 화면상 z축 위치
@property (nonatomic, readonly) int comboBGZOrder; // 콤보 배경의 화면상 z축 위치
@property (nonatomic, readonly) int comboFHZOrder; // 콤보 피겨헤드의 화면상 z축 위치
@property (nonatomic, readonly) float comboFHScaleDuration; // 콤보 피겨헤드의 확대/축소 에니메이션에 걸리는 시간
@property (nonatomic, readonly) float comboFHScaleSize; // 콤보 피겨헤드의 최대 확대 비율
@property (nonatomic, readonly) NSString* startCountTextureFile; // 스타트 카운터 스프라이트 파일
@property (nonatomic, readonly) unsigned int startCountFrameCount; // 스타트 카운터 프레임의 수
@property (nonatomic, readonly) unsigned int startCountPixelSizeX; // 스타트 카운터 픽셀 크기 X축
@property (nonatomic, readonly) unsigned int startCountPixelSizeY; // 스타트 카운터 픽셀 크기 Y축
@property (nonatomic, readonly) CGPoint startCountPosition; // 스타트 카운터의 화면상 위치
@property (nonatomic, readonly) CGPoint startCountAnchorPoint; // 스타트 카운터의 앵커포인트
@property (nonatomic, readonly) int startCountZOrder; // 스타트 카운터의 화면상 z축 위치
@property (nonatomic, readonly) float startCountJumpHeight; // 스타트 카운터의 점프 높이
@property (nonatomic, readonly) float startCountScaleSize; // 스타트 카운터 확대비율
@property (nonatomic, readonly) float startCountFadeDuration; // 스타트 카운터의 페이드아웃 시간
@property (nonatomic, readonly) float startCountTimePerFrame; // 스타트 카운트 도중 매 프레임간 소요시간 (맨 마지막 완주 프레임은 _startCountFadeDuration을 사용함)
@property (nonatomic, readonly) float startCountTimeTotal; // 스타트 카운트이 진행되는 동안 기다려 줄 시간
@property (nonatomic, readonly) bool isScoreFontSprite; // 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정
@property (nonatomic, readonly) NSString* ScoreLabelTTFFontName; // 스코어 라벨의 폰트명 (TTF)
@property (nonatomic, readonly) unsigned int ScoreLabelTTFFontSize; // 스코어 라벨의 폰트 사이즈 (TTF)
@property (nonatomic, readonly) CCColor* ScoreLabelTTFColor; // 스코어 라벨의 폰트 색상 (TTF)
@property (nonatomic, readonly) NSString* ScoreLabelAtlasTextureFile; // 스코어 라벨의 폰트 스프라이트 (Atlas)
@property (nonatomic, readonly) float ScoreLabelAtlasFontSizeX; // 스코어 라벨의 폰트 좌우폭 (Atlas)
@property (nonatomic, readonly) float ScoreLabelAtlasFontSizeY; // 스코어 라벨의 폰트 상하폭 (Atlas)
@property (nonatomic, readonly) CGPoint ScoreLabelAnchorPoint; // 스코어 라벨의 앵커포인트
@property (nonatomic, readonly) CGPoint ScoreLabelPosition; // 스코어 라벨의 위치
@property (nonatomic, readonly) int ScoreLabelZOrder; // 스코어 라벨의 Z축 위치
@property (nonatomic, readonly) int backgroundZOrder; // 배경 노드의 z축 위치
@property (nonatomic, readonly) int backgroundComboZOrder; // 콤보 배경 노드의 z축 위치
@property (nonatomic, readonly) float backgroundComboFadeEffectDuration; // 콤보 배경 노드의 페이드인/아웃 효과 진행시간
@property (nonatomic, readonly) int backgroundUIZOrder; // 배경 UI 노드의 z축 위치
@property (nonatomic, readonly) int comboFHPositionModifier; // 콤보 피겨헤드의 좌/우측 위치 결정. (-1: 좌측, 1: 우측)
@property (nonatomic, readonly) int backgroundUpperZOrder; // 배경 위의 객체가 담긴 노드의 z축 위치
@property (nonatomic, readonly) bool isStreakFontSprite; // 콤보 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정
@property (nonatomic, readonly) NSString* streakLabelTTFFontName; // 콤보 라벨의 폰트명 (TTF)
@property (nonatomic, readonly) unsigned int streakLabelTTFFontSize; // 콤보 라벨의 폰트 사이즈 (TTF)
@property (nonatomic, readonly) CCColor* streakLabelTTFColor; // 콤보 라벨의 폰트 색상 (TTF)
@property (nonatomic, readonly) NSString* streakLabelAtlasTextureFile; // 콤보 라벨의 폰트 스프라이트 (Atlas)
@property (nonatomic, readonly) float streakLabelAtlasFontSizeX; // 콤보 라벨의 폰트 좌우폭
@property (nonatomic, readonly) float streakLabelAtlasFontSizeY; // 콤보 라벨의 폰트 상하폭
@property (nonatomic, readonly) CGPoint streakLabelAnchorPoint; // 콤보 라벨의 앵커포인트
@property (nonatomic, readonly) CGPoint streakLabelPosition; // 콤보 라벨의 위치
@property (nonatomic, readonly) int streakLabelZOrder; // 콤보 라벨의 Z축 위치
@property (nonatomic, readonly) float streakLabelJumpHeight; // 콤보 라벨의 점프 높이
@property (nonatomic, readonly) float streakLabelJumpDuration; // 콤보 라벨의 점프 소요 시간
@property (nonatomic, readonly) float streakLabelFadeDelay; // 콤보 라벨의 페이드아웃 시작 이전 대기 시간
@property (nonatomic, readonly) float streakLabelFadeDuration; // 콤보 라벨의 페이드아웃 시간

+ (GameSetting *) shared;

@end

// 만일 동일 객체가 여럿 있다면 GameSetting 또한 하부 객체를 두고 그 안에 각각의 객체에 매칭되는 각자의 설정을 유지해야 한다.
// 그리고 지정한 객체 또한 자신의 설정값을 물고 있는 객체를 전달받아야 할 것이다.