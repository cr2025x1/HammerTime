//
//  GameSetting.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/23/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "GameSetting.h"


// 게임의 설정값을 저장하는 싱글톤 클래스
@implementation GameSetting
-(id) init
{
    self = [super init];
    if (!self) return(nil);
    
    // 변수 기입부 시작
    
    // 블록 및 블록그룹 부분
    _blockSizeX = 120; // 블록의 CGPoint 기준 폭 - 수정
    _blockSizeY = 40; // 블록의 CGPoint 기준 높이 - 수정
    _blockPixelSizeX = 120; // 블록의 상하 높이. 실제 픽셀 / 2 (?) - 수정
    _blockPixelSizeY = 40; // 블록의 좌우 폭. 실제 픽셀 / 2 (?) - 수정
    _blockTypeCount = 10; // 블록의 종류 개수 - 수정
    _blockFrameCount = 1; // 블록에서 재생할 애니메이션의 총 프레임 수.
    _blockFrameDelay = 0.25; // 블록에서 재생할 애니메이션의 각 프레임 간 시간.
    _blockFallAcceleration = 800; // 반드시 양의 실수로 정해야 함. 너무 가속도가 큰 경우 블록 변형 메소드에서 assert 에러 발생 가능.
    _blockBumpDuration = 0.2; // 블록의 탄성. 크면 클수록 젤리에 비슷하게 됨. 그러나 역시 너무 탄성이 큰 경우 변형 메소드에서 assert 에러 발생 가능.
    _blockInflationRatio = 0.5; // 블록의 충돌방향 수직 팽창 계수. 1인 경우 넓이 보존 법칙이 성립하지만, 다소 비현실적임.
    _blockVisibleCount = 9; // 화면 상에 보여질 블록의 최대 개수. - 수정
    _blockTextureFile = @"Block.png"; // 블록 객체에 사용할 텍스쳐 파일.
    _blockZOrder = block_group; // 블록 객체들이 소속될 배치노드의 z축 위치.
    _blockTypeDurabilityArray = (unsigned int*)malloc(sizeof(unsigned int)*_blockTypeCount); // 블록 종류당 체력 정보
    _blockTypeDurabilityArray[0] = 1;
    _blockTypeDurabilityArray[1] = 2;
    _blockTypeDurabilityArray[2] = 1;
    _blockTypeDurabilityArray[3] = 2;
    _blockTypeDurabilityArray[4] = 1;
    _blockTypeDurabilityArray[5] = 2;
    _blockTypeDurabilityArray[6] = 1;
    _blockTypeDurabilityArray[7] = 2;
    _blockTypeDurabilityArray[8] = 1;
    _blockTypeDurabilityArray[9] = 1;
    _blockFragTypeCount = 1; // 블록 파편의 종류 개수 (각 블록타입당)
    _blockFragGenCount = 15; // 한 블록 파괴시 발생 파편 개수 - 수정
    _blockFragSizePixelX = 20; // 블록 파편의 좌우폭 픽셀크기
    _blockFragSizePixelY = 20; // 블록 파편의 상하폭 픽셀크기
    _blockFragAnglerVelocityMax = 4.0f * M_PI; // 블록 파편의 회전속도 최대한도
    _blockFragAnglerVelocityMin = -4.0f * M_PI; // 블록 파편의 회전속도 최저한도
    _blockFragVelocityMax = 1000.0f; // 블록 파편의 비산속도 최대크기
    _blockFragVelocityMin = 500.0f; // 블록 파편의 비산속도 최저크기
    _blockFragAngleMax = M_PI / 3.0f; // 블록 파편의 비산각도 최대 크기
    _blockFragAngleMin = M_PI / 6.0f; // 블록 파편의 비산각도 최저 크기
    _blockFragGravAcc = -500.0f; // 블록 파편의 낙하가속도 (아래로 떨어지려면 음수여야 한다!)
    _blockFragTextureFile = @"BlockFragSheet.png"; // 블록 파편의 스프라이트 시트 파일
    _blockFragZOrder = block_frag;
    _blockGroupBaseCGP = ccp([[CCDirector sharedDirector] viewSize].width/2, [[CCDirector sharedDirector] viewSize].height/1.27f); // 블록 그룹의 바닥 중심 위치 (블록이 떨어져 부딪히는 그 바닥의 중심점) - 수정
    _blockFallDurationMax = 0.5f; // 자유낙하 소요시간 최대허용치
    _blockGap = 3.0f; // 블록간 갭 (단위: CGPoint) - 수정
    _blockFallAccDirection = 1; // 블록의 낙하 가속도 방향 (-1: 아래, 1: 위)
    
    // 버튼 및 버튼그룹 부분
    _buttonTypeCount = 4; // 버튼의 종류 개수
    _buttonSizeX = 70; // 블록의 CGPoint 기준 폭
    _buttonSizeY = 70; // 블록의 CGPoint 기준 높이
    _buttonPixelSizeX = 70; // 블록의 상하 높이. 실제 픽셀
    _buttonPixelSizeY = 70; // 블록의 좌우 폭. 실제 픽셀
    _buttonTextureFile = @"Button.png"; // 버튼 객체에 사용할 텍스쳐 파일
    _buttonZOrder = button_group; // 버튼 객체들이 소속될 배치노드의 z축 위치
    _buttonGroupCapacity = 4; // 버튼 종류의 최대 개수
    _buttonInitialCount = 2; // 시작 시 주어질 버튼의 종류 개수
    _buttonPositionArray = [NSArray arrayWithObjects:
                            [NSValue valueWithCGPoint:ccp(50, 50)],
                            [NSValue valueWithCGPoint:ccp([[CCDirector sharedDirector] viewSize].width - 50,50)],
                            [NSValue valueWithCGPoint:ccp(50, 150)],
                            [NSValue valueWithCGPoint:ccp([[CCDirector sharedDirector] viewSize].width - 50,150)],
                            nil]; // 버튼이 위치할 자리
    _buttonFrameCount = 3; // 버튼 푸시 애니메이션의 프레임 수
    _buttonFrameDelay = 0.25; // 블록에서 재생할 애니메이션의 각 프레임 간 시간.

    // 게임 로직 환경변수
    _specBlkEffectCount = 1; // 특수 블록의 이펙트 수
    _specBlkPMax = 0.05; // 특수 블록 생성 확률 최고치
    _specBlkPMinScore = 500; // 특수 블록 생성 확률이 생기는 점수 (생성 확률 상승치는 정리 노트 참조)
    _specBlkPMaxScore = 50000; // 특수 블록 생성 확률 최고치에 도달하는 점수 (생성 확률 상승치는 정리 노트 참조)
    _enhancedBlkPMax = 0.2; // 각 색상별 강화블럭 생성 확률 최고치
    _enhancedBlkPMinScore = 500; // 각 색상별 강화블럭 생성 확률이 생기는 점수 (생성 확률 상승치는 정리 노트 참조)
    _enhancedBlkPMaxScore = 50000; // 각 색상별 강화블럭 생성 확률 최고치에 도달하는 점수 (생성 확률 상승치는 정리 노트 참조)
    _blockTypeUnlockScore = (unsigned int*)malloc(sizeof(unsigned int)*(_blockTypeCount - 2)); // 각 블록 타입별 언락 점수
    _blockTypeUnlockScore[0] = 0; // 색상 0
    _blockTypeUnlockScore[1] = 2500; // 색상 0 강화형
    _blockTypeUnlockScore[2] = 0; // 색상 2
    _blockTypeUnlockScore[3] = 2500; // 색상 2 강화형
    _blockTypeUnlockScore[4] = 500; // 색상 4
    _blockTypeUnlockScore[5] = 5000; // 색상 4 강화형
    _blockTypeUnlockScore[6] = 500; // 색상 6
    _blockTypeUnlockScore[7] = 5000; // 색상 6 강화형
    _buttonBlockBindingArray = (BlockType*)malloc(sizeof(BlockType)*_blockTypeCount); // 각 블록과 버튼간 바인딩
    _buttonBlockBindingArray[0] = 0; // 색상 0
    _buttonBlockBindingArray[1] = 0; // 색상 0 강화형
    _buttonBlockBindingArray[2] = 2; // 색상 2
    _buttonBlockBindingArray[3] = 2; // 색상 2 강화형
    _buttonBlockBindingArray[4] = 4; // 색상 4
    _buttonBlockBindingArray[5] = 4; // 색상 4 강화형
    _buttonBlockBindingArray[6] = 6; // 색상 6
    _buttonBlockBindingArray[7] = 6; // 색상 6 강화형
    _buttonBlockBindingArray[8] = 10; // 특수 블록: 현재는 버튼 뒤섞기 효과밖에 없음.
    _buttonBlockBindingArray[9] = 10; // 타이머 시간 추기 블록
    _blockTypeRemovalScore = (unsigned int*)malloc(sizeof(unsigned int)*_blockTypeCount); // 각 블록 간 격파 점수
    _blockTypeRemovalScore[0] = 10; // 색상 0
    _blockTypeRemovalScore[1] = 15; // 색상 0 강화형 (강화->일반 블럭으로 약화시킬 떄 점수)
    _blockTypeRemovalScore[2] = 10; // 색상 2
    _blockTypeRemovalScore[3] = 15; // 색상 2 강화형 (강화->일반 블럭으로 약화시킬 떄 점수)
    _blockTypeRemovalScore[4] = 10; // 색상 4
    _blockTypeRemovalScore[5] = 15; // 색상 4 강화형 (강화->일반 블럭으로 약화시킬 떄 점수)
    _blockTypeRemovalScore[6] = 10; // 색상 6
    _blockTypeRemovalScore[7] = 15; // 색상 6 강화형 (강화->일반 블럭으로 약화시킬 떄 점수)
    _blockTypeRemovalScore[8] = 75; // 특수 블록: 현재는 버튼 뒤섞기 효과밖에 없음.
    _blockTypeRemovalScore[9] = 0; // 타이머 시간 추기 블록
    _timerComboCount = 10; // 타이머 블록을 주는 콤보 개수
    _timeLimit = 60.0f; // 처음 주어지는 시간 (그리고 타이머의 최대 수치)
    _timeBonusAmount = 10.0f; // 타임 보너스 때 가산되는 시간
    _gameOverSceneSwitchingDelay = 3.0f; // 게임 오버 이벤트 발생 시 다음 씬으로 넘어가기 직전의 딜레이 시간.
    _gameStartCountStartDelay = 2.0f; // 게임 시작 카운트가 시작되기 이전의 딜레이 시간.
    _soundBGM = @""; // 배경음 소리 파일
    _soundBlockRemove = @""; // 일반 블록이 파괴되는 소리
    _soundTimerEffect = @""; // 시간 연장 블록이 파괴되는 소리 (=타이머 효과 발동 소리)
    _soundSpecialEffect = @""; // 버튼 위치 섞기 블록 파괴 소리 (=버튼 위치 섞기 효과 발동 소리)
    _soundComboFull = @""; // 콤보 블록 생성 소리 (=콤보 게이지가 풀로 채워졌을 때 나는 소리)
    _soundTimeOver = @""; // 제한 시간이 소진되었을 때 나는 소리 (=게임 오버 시 나는 소리)
    _soundWrongButton = @""; // 다른 색상의 버튼을 눌렀을 때 나는 소리 (=버튼을 잘못 눌렀을 때 나는 소리, 콤보가 초기화되는 소리)
    _soundEnhancedBlockCrack = @""; // 강화 블럭이 금가는 소리
    _soundStartCountTick = @""; // 시작 카운터의 숫자가 줄어들 때 나는 소리 (=맨 마지막 프레임 제외한 프레임의 등장 소리)
    _soundStartCountComplete = @""; // 시작 카운터가 끝났을 때 나는 소리 (=맨 마지막 프레임 등장 소리)
    _bgmFadeOutDuration = 1.0f; // 게임 오버시 배경음 페이드아웃 효과 진행시간
    _streakEffectHitCount = 50; // 콤보 배경을 드러내는 연속 적중수
    _streakSoundThresholdCount = 5; // 사운드 재생 연속 적중수 경계점의 개수
    if (_streakSoundThresholdCount > 0) {
        _streakSoundThreholdArray = (unsigned int*)malloc(sizeof(unsigned int)*_streakSoundThresholdCount);
        memset(_streakSoundThreholdArray, 0, sizeof(unsigned int)*_streakSoundThresholdCount);
    }
    if (_streakSoundThresholdCount > 0) {
//        _streakSoundThreholdEffectArray = (NSString*__strong*)malloc(sizeof(NSString*)*_streakSoundThresholdCount);
        _streakSoundThreholdEffectArray = [NSMutableArray arrayWithCapacity:_streakSoundThresholdCount];
        for (int i = 0; i < _streakSoundThresholdCount; i++) {
            _streakSoundThreholdEffectArray[i] = @"";
        }
    }
    // 사운드 재생 연속 적중수 경계점 배열 _streakSoundThreholdArray: 모두 0보다 큰 값을 가져야 하며, 이전 원소보다 항상 값이 커야 한다.
    // 사운드 재생 연속 적중수 경계점 재생 사운드 배열 _streakSoundThreholdEffectArray: 위의 배열에서 지정한 점수를 넘길 때 재생될 소리들
    _streakSoundThreholdArray[0] = 5;
    _streakSoundThreholdEffectArray[0] = @"";
    _streakSoundThreholdArray[1] = 10;
    _streakSoundThreholdEffectArray[1] = @"";
    _streakSoundThreholdArray[2] = 20;
    _streakSoundThreholdEffectArray[2] = @"";
    _streakSoundThreholdArray[3] = 30;
    _streakSoundThreholdEffectArray[3] = @"";
    _streakSoundThreholdArray[4] = 40;
    _streakSoundThreholdEffectArray[4] = @"";
    
    // UI그룹 환경변수
    _timerBarTextureFile = @"TimerGaugeBar.png"; // 타이머 바 스프라이트 파일
    _timerBGTextureFile = @"TimerGaugeBackground.png"; // 타이머 배경 스프라이트 파일
    _timerPosition = ccp([[CCDirector sharedDirector] viewSize].width / 2, [[CCDirector sharedDirector] viewSize].height); // 타이머의 화면상 위치
    _timerAnchorPoint = ccp(0.5f, 1.0f); // 타이머의 앵커포인트
    _timerBarZOrder = timer_bar; // 타이머 바의 화면상 z축 위치
    _timerBGZOrder = timer_background; // 타이머 배경의 화면상 z축 위치
    _comboBarTextureFile = @"ComboGaugeBar.png"; // 콤보 바 스프라이트 파일
    _comboBGTextureFile = @"ComboGaugeBackground.png"; // 콤보 배경 스프라이트 파일
    _comboFHTextureFile = @"ComboGaugeFigurehead.png"; // 콤보 피겨헤드 스프라이트 파일
    _comboPosition = ccp([[CCDirector sharedDirector] viewSize].width / 2, 0); // 콤보 게이지의 화면상 위치
    _comboAnchorPoint = ccp(0.5f, 0.0f); // 콤보의 앵커포인트
    _comboBarZOrder = combo_bar; // 콤보 바의 화면상 z축 위치
    _comboBGZOrder = combo_background; // 콤보 배경의 화면상 z축 위치
    _comboFHZOrder = combo_figurehead; // 콤보 피겨헤드의 화면상 z축 위치
    _comboFHScaleDuration = 0.3f; // 콤보 피겨헤드의 확대/축소 에니메이션에 걸리는 시간
    _comboFHScaleSize = 2.0f; // 콤보 피겨헤드의 최대 확대 비율. 주의점! 피겨헤드의 PNG 파일 크기는 반드시 "확대된 상태"를 기준으로 잡아야 한다. 해상도 문제 때문에 그렇게 설정됨.
    _startCountTextureFile = @"StartCountSheet.png"; // 스타트 카운터 스프라이트 파일
    _startCountFrameCount = 4; // 스타트 카운터 프레임의 수
    _startCountPixelSizeX = 50; // 스타트 카운터 픽셀 크기 X축
    _startCountPixelSizeY = 50; // 스타트 카운터 픽셀 크기 Y축
    _startCountPosition = ccp([[CCDirector sharedDirector] viewSize].width / 2.0f, [[CCDirector sharedDirector] viewSize].height / 2.0f); // 스타트 카운터의 화면상 위치
    _startCountAnchorPoint = ccp(0.5f, 0.5f); // 스타트 카운터의 앵커포인트
    _startCountZOrder = start_counter; // 스타트 카운터의 화면상 z축 위치
    _startCountJumpHeight = 25.0f; // 스타트 카운터의 점프 높이
    _startCountScaleSize = 2.0f; // 스타트 카운터 확대비율
    _startCountFadeDuration = 0.4f; // 스타트 카운터의 페이드아웃 시간
    _startCountTimePerFrame = 1.0f; // 스타트 카운트 도중 매 프레임간 소요시간 (맨 마지막 완주 프레임은 _startCountFadeDuration을 사용함)
    _startCountTimeTotal = 3.0f; // 스타트 카운트이 진행되는 동안 기다려 줄 시간
    _isScoreFontSprite = false; // 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정 (여기에 따라 아래의 적용되는 설정값의 항목도 다르다.)
    _ScoreLabelTTFFontName = @"Verdana-Bold"; // 스코어 라벨의 폰트명 (TTF)
    _ScoreLabelTTFFontSize = 32; // 스코어 라벨의 폰트 사이즈 (TTF)
    _ScoreLabelTTFColor = [CCColor whiteColor]; // 스코어 라벨의 폰트 색상 (TTF)
    _ScoreLabelAtlasTextureFile = @""; // 스코어 라벨의 폰트 스프라이트 (Atlas)
    _ScoreLabelAtlasFontSizeX = 0; // 스코어 라벨의 폰트 좌우폭 (Atlas)
    _ScoreLabelAtlasFontSizeY = 0; // 스코어 라벨의 폰트 상하폭 (Atlas)
    _ScoreLabelAnchorPoint = ccp(1.0f, 0.5f); // 스코어 라벨의 앵커포인트 (공통)
    _ScoreLabelPosition = ccp([[CCDirector sharedDirector] viewSize].width, [[CCDirector sharedDirector] viewSize].height / 2.0f); // 스코어 라벨의 위치 (공통)
    _ScoreLabelZOrder = score_label; // 스코어 라벨의 Z축 위치 (공통)
    _backgroundZOrder = background_zOrder; // 배경 노드의 z축 위치
    _backgroundComboZOrder = background_Combo_ZOrder; // 콤보 배경 노드의 z축 위치
    _backgroundComboFadeEffectDuration = 0.3f; // 콤보 배경 노드의 페이드인/아웃 효과 진행시간
    _backgroundUIZOrder = ui_group; // 배경 UI 노드의 z축 위치
    _comboFHPositionModifier = -1; // 콤보 피겨헤드의 좌/우측 위치 결정. (-1: 좌측, 1: 우측)
    _backgroundUpperZOrder = background_upper; // 배경 위의 객체가 담긴 노드의 z축 위치
    _isStreakFontSprite = false; // 콤보 폰트를 스프라이트로 할지, TTF 폰트로 할지 결정
    _streakLabelTTFFontName = @"Verdana-Bold"; // 콤보 라벨의 폰트명 (TTF)
    _streakLabelTTFFontSize = 32; // 콤보 라벨의 폰트 사이즈 (TTF)
    _streakLabelTTFColor = [CCColor whiteColor]; // 콤보 라벨의 폰트 색상 (TTF)
    _streakLabelAtlasTextureFile = @""; // 콤보 라벨의 폰트 스프라이트 (Atlas)
    _streakLabelAtlasFontSizeX = 0; // 콤보 라벨의 폰트 좌우폭
    _streakLabelAtlasFontSizeY = 0; // 콤보 라벨의 폰트 상하폭
    _streakLabelAnchorPoint = ccp(1.0f, 0.5f); // 콤보 라벨의 앵커포인트
    _streakLabelPosition = ccp([[CCDirector sharedDirector] viewSize].width, [[CCDirector sharedDirector] viewSize].height / 3.0f); // 콤보 라벨의 위치
    _streakLabelZOrder = combo_label; // 콤보 라벨의 Z축 위치
    _streakLabelJumpHeight = 8.0f; // 콤보 라벨의 점프 높이
    _streakLabelJumpDuration = 0.5f; // 콤보 라벨의 점프 소요 시간
    _streakLabelFadeDelay = 0.5f; // 콤보 라벨의 페이드아웃 시작 이전 대기 시간
    _streakLabelFadeDuration = 1.0f; // 콤보 라벨의 페이드아웃 시간
    _streakLabelActiveCount = 1; // 콤보 라벨이 활성화되는 적중 연속수 최소 한계치
    
    // 각 변수에 대한 값 점검
    
    // 블록 및 블록그룹 부분
    NSAssert(_blockSizeX > 0, @"_blockSizeX must be higher than 0.\n");
    NSAssert(_blockSizeY > 0, @"_blockSizeY must be higher than 0.\n");
    NSAssert(_blockPixelSizeX > 0, @"_blockPixelSizeX must be higher than 0.\n");
    NSAssert(_blockPixelSizeY > 0, @"_blockPixelSizeY must be higher than 0.\n");
    NSAssert(_blockTypeCount > 0, @"_blockTypeCount must be higher than 0.\n");
    NSAssert(_blockFrameCount > 0, @"_blockFrameCount must be higher than 0.\n");
    NSAssert(_blockFrameDelay > 0, @"_blockFrameDelay must be higher than 0.\n");
    NSAssert(_blockFallAcceleration > 0, @"_blockFallAcceleration must be higher than 0.\n");
    NSAssert(_blockBumpDuration > 0, @"_blockBumpDuration must be higher than 0.\n");
    NSAssert(_blockInflationRatio > 0, @"_blockInflationRatio must be higher than 0.\n");
    NSAssert(_blockVisibleCount > 0, @"_blockVisibleCount must be higher than 0.\n");
    // _blockZOrder : int형이므로 조건은 생략한다.
    NSAssert([self fileExistsInProject:_blockTextureFile], @"_blockTextureFile indicates a file that doesn't exist.\n");
    NSAssert(_blockFragTypeCount > 0, @"_blockFragTypeCount must be higher than 0.\n");
    NSAssert(_blockFragGenCount > 0, @"_blockFragGenCount must be higher than 0.\n");
    NSAssert(_blockFragSizePixelX > 0, @"_blockFragSizePixelX must be higher than 0.\n");
    NSAssert(_blockFragSizePixelY > 0, @"_blockFragSizePixelY must be higher than 0.\n");
    NSAssert(_blockFragAnglerVelocityMax >= _blockFragAnglerVelocityMin, @"_blockFragAnglerVelocityMax must be higher than _blockFragAnglerVelocityMin or must be same with it.\n");
    NSAssert(_blockFragVelocityMax > 0, @"_blockFragVelocityMax must be higher than 0.\n");
    NSAssert(_blockFragVelocityMin > 0, @"_blockFragVelocityMin must be higher than 0.\n");
    NSAssert(_blockFragVelocityMax >= _blockFragVelocityMin, @"_blockFragVelocityMax must be higher than _blockFragVelocityMin or must be same with it.\n");
    NSAssert(_blockFragAngleMax > 0, @"_blockFragAngleMax must be higher than 0.\n");
    NSAssert(_blockFragAngleMin > 0, @"_blockFragAngleMin must be higher than 0.\n");
    NSAssert(_blockFragAngleMax >= _blockFragAngleMin, @"_blockFragAngleMax must be higher than _blockFragAngleMin or must be same with it.\n");
    NSAssert([self fileExistsInProject:_blockFragTextureFile], @"_blockFragTextureFile indicates a file that doesn't exist.\n");
    NSAssert(_blockFallDurationMax > 0, @"_blockFallDurationMax must be higher than 0.\n");
    NSAssert(_blockGap >= 0, @"_blockFallDurationMax must be equal with 0 or higher than it.\n");
    NSAssert(_blockGap >= 0, @"_blockFallDurationMax must be equal with 0 or higher than it.\n");
    NSAssert(abs(_blockFallAccDirection) == 1, @"_blockFallDurationMax must be 1 or -1.\n");
    
    // 버튼 및 버튼 그룹 부분
    NSAssert(_buttonSizeX > 0, @"_blockSizeX must be higher than 0.\n");
    NSAssert(_buttonSizeY > 0, @"_blockSizeY must be higher than 0.\n");
    NSAssert(_buttonPixelSizeX > 0, @"_blockPixelSizeX must be higher than 0.\n");
    NSAssert(_buttonPixelSizeY > 0, @"_blockPixelSizeY must be higher than 0.\n");
    NSAssert(_buttonTypeCount > 0, @"_blockTypeCount must be higher than 0.\n");
    NSAssert(_buttonGroupCapacity > 0, @"_blockPixelSizeY must be higher than 0.\n");
    NSAssert(_buttonInitialCount > 0, @"_blockTypeCount must be higher than 0.\n");
    NSAssert(_buttonInitialCount <= _buttonGroupCapacity,
             @"_blockInitialCount must be same or less than _buttonGroupCapacity.\n");
    NSAssert([self fileExistsInProject:_buttonTextureFile], @"_buttonTextureFile indicates a file that doesn't exist.\n");
    NSAssert(_buttonPositionArray.count >= _buttonGroupCapacity,
             @"The number of elements in _buttonPositionArray must be same or higher than _buttonGroupCapacity.\n");
    // _buttonZOrder : int형이므로 조건은 생략한다.
    NSAssert(_buttonFrameCount > 0, @"_buttonFrameCount must be higher than 0.\n");
    NSAssert(_buttonFrameDelay > 0, @"_buttonFrameDelay must be higher than 0.\n");
    
    // 게임 로직 부분
    NSAssert(_specBlkPMax <= 1, @"_specBlkMax must be lesser than 1.\n");
    NSAssert(_enhancedBlkPMax <= 1, @"_enhancedBlkMax must be lesser than 1.\n");
    NSAssert(_specBlkPMinScore <= _specBlkPMaxScore, @"_specBlkPMinScore must be lesser than _specBlkPMaxScore.\n");
    NSAssert(_enhancedBlkPMinScore <= _enhancedBlkPMaxScore, @"_enhancedBlkPMinScore must be lesser than _enhancedBlkPMaxScore.\n");
    
    unsigned int loopEnd = _blockTypeCount - 2;
    unsigned int zeroCount = 0;
    for (int i = 0; i < loopEnd; i++) {
        if (_blockTypeUnlockScore[i] == 0) {
            zeroCount++;
        }
    }
    NSAssert(zeroCount == _buttonInitialCount, @"_blockTypeUnlockScore must have same number of 0 value exactly with _buttonInitialCount.\n");
    for (int i = 0; i < loopEnd; i += 2) {
        NSAssert(_blockTypeUnlockScore[i] <= _blockTypeUnlockScore[i + 1], @"_blockTypeUnlockScore: Enhanced block unlocking point must be higher than its normal block unlock value or it must be same with the later.\n");
    }
    for (int i = 0; i < _blockTypeCount; i++) {
        NSAssert(_blockTypeRemovalScore[i] >= 0, @"_blockTypeRemovalScore[%d] must not be negative.\n", i);
    }
    
    NSAssert(_timerComboCount > 0, @"_timerComboCount must be higher than 0.\n");
    NSAssert(_timeLimit > 0, @"_timeLimit must be higher than 0.\n");
    NSAssert(_timeBonusAmount > 0, @"_timeBonusAmount must be higher than 0.\n");
    NSAssert(_gameOverSceneSwitchingDelay > 0, @"_gameOverSceneSwitchingDelay must be higher than 0.\n");
    NSAssert(_gameStartCountStartDelay > 0, @"_gameStartCountStartDelay must be higher than 0.\n");
    if (!([_soundBGM isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundBGM], @"_soundBGM indicates a file that doesn't exist.\n");
    }
    if (!([_soundBlockRemove isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundBlockRemove], @"_soundBlockRemove indicates a file that doesn't exist.\n");
    }
    if (!([_soundTimerEffect isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundTimerEffect], @"_soundTimerEffect indicates a file that doesn't exist.\n");
    }
    if (!([_soundSpecialEffect isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundSpecialEffect], @"_soundSpecialEffect indicates a file that doesn't exist.\n");
    }
    if (!([_soundComboFull isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundComboFull], @"_soundComboFull indicates a file that doesn't exist.\n");
    }
    if (!([_soundTimeOver isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundTimeOver], @"_soundTimeOver indicates a file that doesn't exist.\n");
    }
    if (!([_soundWrongButton isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundWrongButton], @"_soundWrongButton indicates a file that doesn't exist.\n");
    }
    if (!([_soundEnhancedBlockCrack isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundEnhancedBlockCrack], @"_soundEnhancedBlockCrack indicates a file that doesn't exist.\n");
    }
    if (!([_soundStartCountTick isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundStartCountTick], @"_soundStartCountTick indicates a file that doesn't exist.\n");
    }
    if (!([_soundStartCountComplete isEqual:@""])) {
        NSAssert([self fileExistsInProject:_soundStartCountComplete], @"_soundStartCountComplete indicates a file that doesn't exist.\n");
    }
    NSAssert((_bgmFadeOutDuration < _gameStartCountStartDelay) && (_bgmFadeOutDuration > 0), @"_bgmFadeOutDuration must be higher than 0 and lesser than _gameStartCountStartDelay.\n");
    NSAssert(_streakEffectHitCount > 0, @"_streakEffectHitCount must be higher than 0.\n");
    NSAssert(_streakEffectHitCount >= 0, @"_streakEffectHitCount must be higher than 0 or must be same with it.\n");
    if (_streakSoundThresholdCount > 0) {
        NSAssert(_streakSoundThreholdArray[0] > 0, @"_streakSoundThreholdArray's elements must be higher than 0.\n");
        for (int i = 1; i < _streakSoundThresholdCount; i++) {
            NSAssert(_streakSoundThreholdArray[i] > _streakSoundThreholdArray[i - 1], @"_streakEffectHitCount's elements must be higher than the elements with smaller index than its index. (Error detected index = %d)\n", i);
        }
        for (int i = 0; i < _streakSoundThresholdCount; i++) {
            if (!([_streakSoundThreholdEffectArray[i] isEqual:@""])) {
                NSAssert([self fileExistsInProject:_streakSoundThreholdEffectArray[i]], @"_streakSoundThreholdEffectArray[%d] indicates a file that doesn't exist.\n", i);
            }
        }
    }
    
    // UI그룹 부분
    NSAssert([self fileExistsInProject:_timerBarTextureFile], @"_timerBarTextureFile indicates a file that doesn't exist.\n");
    NSAssert([self fileExistsInProject:_timerBGTextureFile], @"_timerBGTextureFile indicates a file that doesn't exist.\n");
    NSAssert([self fileExistsInProject:_comboBarTextureFile], @"_comboBarTextureFile indicates a file that doesn't exist.\n");
    NSAssert([self fileExistsInProject:_comboBGTextureFile], @"_comboBGTextureFile indicates a file that doesn't exist.\n");
    NSAssert([self fileExistsInProject:_comboFHTextureFile], @"_comboFHTextureFile indicates a file that doesn't exist.\n");
    NSAssert(_comboFHScaleDuration > 0, @"_comboFHScaleDuration must be higher than 0.\n");
    NSAssert(_comboFHScaleSize > 0, @"_comboFHScaleSize must be higher than 0.\n");
    NSAssert([self fileExistsInProject:_startCountTextureFile], @"_startCountTextureFile indicates a file that doesn't exist.\n");
    NSAssert(_startCountFrameCount > 0, @"_startCountFrameCount must be higher than 0.\n");
    NSAssert(_startCountPixelSizeX > 0, @"_startCountPixelSizeX must be higher than 0.\n");
    NSAssert(_startCountPixelSizeY > 0, @"_startCountPixelSizeY must be higher than 0.\n");
    NSAssert(_startCountScaleSize > 0, @"_startCountScaleSize must be higher than 0.\n");
    NSAssert(_startCountFadeDuration > 0, @"_startCountFadeDuration must be higher than 0.\n");
    NSAssert(_startCountTimePerFrame > 0, @"_startCountTimePerFrame must be higher than 0.\n");
    NSAssert(_startCountTimeTotal > 0, @"_startCountTimeTotal must be higher than 0.\n");
    NSAssert(_backgroundComboFadeEffectDuration >= 0, @"_backgroundComboFadeEffectDuration must not be negative.\n");
    NSAssert(abs(_comboFHPositionModifier) == 1, @"_comboFHPositionModifier must be 1 or -1.\n");
    NSAssert(_streakLabelJumpDuration >= 0, @"_streakLabelJumpDuration must be higher than 0.\n");
    NSAssert(_streakLabelFadeDelay >= 0, @"_streakLabelFadeDelay must be higher than 0.\n");
    NSAssert(_streakLabelFadeDuration >= 0, @"_streakLabelFadeDuration must be higher than 0.\n");
    NSAssert(_streakLabelActiveCount > 0, @"_streakLabelActiveCount must be higher than 0.\n");

    // 변수 기입부 종료
    
    return self;
}

- (void)dealloc
{
    free(_blockTypeUnlockScore);
    free(_blockTypeDurabilityArray);
    free(_buttonBlockBindingArray);
    free(_blockTypeRemovalScore);
}


static GameSetting *shared = nil;

+ (GameSetting *) shared
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



// 주어진 이름의 파일이 실제로 프로젝트 리소스 안에 존재하는지 확인한다.
// 외부 링크 참조: http://stackoverflow.com/questions/7931315/checking-if-image-exists-in-bundle-iphone
-(bool) fileExistsInProject:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileInResourcesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:fileInResourcesFolder];
}

@end
