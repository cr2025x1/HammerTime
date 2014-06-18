//
//  CCActionUDC.m
//  HammerTime
//
//  Created by Chrome-MBPR on 5/22/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//


#import "CCActionUDC.h"
#import "GameCommon.h"



#pragma mark - CCActionFreeFall
// 자유낙하 이동 명령
@implementation CCActionFreeFall {
    CGPoint _currentDisplacecment;
    CGPoint _currentPosition;
    CGPoint _previousPosition;
    CGPoint _startPosition;
}

+(id) actionWithDuration: (CCTime)t position: (CGPoint)p initialVelocity:(CGPoint)iV;
{
	return [[self alloc] initWithDuration:t position:p initialVelocity:iV];
}

-(id) initWithDuration: (CCTime)t position: (CGPoint)p initialVelocity:(CGPoint)iV;
{
    if( (self=[super initWithDuration: t])) {
		_positionDelta = p;
        _initialVelocity = iV;
        // _totalDuration = t;
        node = (CCNode *)_target;
        _poly2 = ccpMult( _initialVelocity, t);
        _poly1 = ccpSub(_positionDelta, _poly2);
        _multiplier = ccpMult(_poly1, 2/ t);
        // 다른 메소드가 이 액션 클래스와 연동되어 동작하는 경우, 이 액션 클래스가 종료된 직후의 최종 속도가 필요한 경우가 있다. 따라서 이를 미리 계산해서 property 형식으로 제공한다.
        _terminalVelocity = ccpAdd(_multiplier, _initialVelocity);
        _startPosition = [node position];
        _previousPosition = _startPosition;
        
    }
	return self;
}

+ (id)actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition {
    return [[self alloc] initWithDuration:duration position:deltaPosition initialVelocity:ccp(0.0f, 0.0f)];
}
- (id)initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition {
    return [self initWithDuration:duration position:deltaPosition initialVelocity:ccp(0.0f, 0.0f)];
}


-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:_positionDelta];
}

-(void) startWithTarget:(CCNode *)target
{
	[super startWithTarget:target];
    node = target;
    _startPosition = [node position];
    _previousPosition = _startPosition;
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration position:ccp( -_positionDelta.x, -_positionDelta.y)];
}

-(void) update: (CCTime) t
{
    // 계산식을 정리, 직전 호출의 변위와 현 호출의 변위의 "델타값"을 구하기 위한 시간 부분을 중복계산을 막기 위해 미리 연산한 것이다. 계산식에 대해서는 위키의 노트를 참고한다.
    if (t == 1) {
        _currentVelocity = ccp(0.0f, 0.0f);
    }
    else {
        _currentVelocity = ccpAdd(ccpMult(_multiplier, t), _initialVelocity);
    }
    
    _currentDisplacecment = ccpAdd(ccpMult(_poly1, powf(t, 2.0f)), ccpMult(_poly2, t));
    
#if CC_ENABLE_STACKABLE_ACTIONS
    _startPosition = ccpAdd(_startPosition, ccpSub([node position], _previousPosition));
    _currentPosition = ccpAdd(_startPosition, _currentDisplacecment);
    [node setPosition:_currentPosition];
    _previousPosition = _currentPosition;
    
#else
    
    [node setPosition: ccpAdd(_startPosition, _currentDisplacement)];
    
#endif // CC_ENABLE_STACKABLE_ACTIONS
    
}
@end




#pragma mark - CCActionBump
// 충격지점 튕김 액션 클래스
@implementation CCActionBump
+(id)actionWithDuration: (CCTime)t velocity:(CGPoint)v
{
	return [[self alloc] initWithDuration:t velocity:v];
}

-(id)initWithDuration: (CCTime)t velocity:(CGPoint)v;
{
    if( (self=[super initWithDuration: t])) {
		_givenVelocity = v;
        _positionDisplacement = ccp(0, 0);
        _previousPositionDisplacement = ccp(0, 0);
        node = (CCNode *)_target;
        _velocityMagnitude = [[GameCommon shared] magnitude:v];
        // 변위에 방향성분을 더해야 하므로, 삼각함수값을 구한다. 또한 이 삼각함수값은 변위와 같은 방향을 같는 단위벡터이기도 하다.
        // 단위벡터: 크기가 1인 벡터
        // 삼각함수의 항등식: (sin(x))^2 + (cos(x))^2 = 1
        _trigonometrical = ccp(v.x / _velocityMagnitude, v.y / _velocityMagnitude);
        // 위키의 계산식 중, 상수 부분을 미리 뽑아서 계산한 뒤 변수로 저장했다. 런타임 도중의 무의미한 반복계산을 피하기 위해서이다.
        _multiplier = _velocityMagnitude * powf(t, 2) / M_PI;
        
    }
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] position:_positionDisplacement];
}

-(void) startWithTarget:(CCNode *)target
{
	[super startWithTarget:target];
    node = target;
    _previousPositionDisplacement = ccp(0, 0);
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithDuration:_duration velocity:ccp( -_givenVelocity.x, -_givenVelocity.y)];
}

-(void) update: (CCTime) t
{
    _positionDisplacementMagnitude = _multiplier * (1 - t) * sinf(M_PI * t);
    _positionDisplacement = ccp(_positionDisplacementMagnitude * _trigonometrical.x, _positionDisplacementMagnitude * _trigonometrical.y);
    
#if CC_ENABLE_STACKABLE_ACTIONS
    
    [node setPosition: ccpAdd([node position], ccpSub(_positionDisplacement, _previousPositionDisplacement))];
    
#else
    
    [node setPosition: ccpAdd([node position], ccpSub(_positionDisplacement, _previousPositionDisplacement))];
                              
#endif // CC_ENABLE_STACKABLE_ACTIONS
    
    _previousPositionDisplacement = _positionDisplacement;
}
@end



#pragma mark - CCActionDistort
// 충격지점에서의 찌그러짐 후 복원 액션 클래스
@implementation CCActionDistort

+(id)actionWithDuration: (CCTime)t velocity:(CGPoint)v collisionSize:(float)csz inflationRatio:(float)i displacementScale:(float)dScale
{
    return [[self alloc] initWithDuration:t velocity:v collisionSize:csz inflationRatio:i displacementScale:dScale];
}

-(id)initWithDuration: (CCTime)t velocity:(CGPoint)v collisionSize:(float)csz inflationRatio:(float)i displacementScale:(float)dScale
{
    if( (self=[super initWithDuration: t velocity: v]) )
    {
        _collisionSize = csz;
        _inflationModifier = i;
        // 압축/팽창 성분을 x축 성분, y축 성분의 비로 나눈다. 이는 곧 삼각함수값과 같지만, 압축/팽창은 항상 양의 값을 가지므로 삼각함수값을 절대값 처리한다.
        _scaleApplyingRatio = ccp(fabsf(_trigonometrical.x), fabsf(_trigonometrical.y));
        _sharedSingleton = [CCActionDistortShared shared];
        // 현재의 인수값이 이상행동을 일으킬 수 있는지 없는지, 그 정상 여부를 판가름하기 위해서 이미 주어진 값을 이용, 최대 변위를 계산하여 충돌크기를 벗어나는지 미리 확인한다. 만일 이상범위에 들어간다면 assert 매크로를 이용, 프로그램 실행을 중단한다.
        float _highestDisplacementMagnitude = _multiplier * (1 - _sharedSingleton.highestDisplacementTime) * sinf(M_PI * _sharedSingleton.highestDisplacementTime);
        _highestDisplacement = ccp(_highestDisplacementMagnitude * _trigonometrical.x, _highestDisplacementMagnitude * _trigonometrical.y);
        _displacementScaleRatio = dScale;
        _previousScale[0] = 1;
        _previousScale[1] = 1;
        
        assert(_collisionSize > _highestDisplacementMagnitude);
        assert(_collisionSize - _highestDisplacementMagnitude * _inflationRatio > 0);
    }
    return self;
}

-(id) copyWithZone: (NSZone*) zone
{
    return [[[self class] allocWithZone: zone] initWithDuration:[self duration] velocity:_givenVelocity collisionSize:_collisionSize inflationRatio:_inflationModifier displacementScale:_displacementScaleRatio];
}

-(CCActionInterval*) reverse
{
    return [[self class] actionWithDuration:_duration velocity:ccp(-_givenVelocity.x, -_givenVelocity.y) collisionSize:_collisionSize inflationRatio:_inflationModifier displacementScale:_displacementScaleRatio];
}

-(void) update: (CCTime) t
{
    // 계산식에 따른 이동 변위의 크기 (_multiplier는 상수 부분을 따로 모아서 미리 계산해둔 것. 아래의 계산식과 그 유도과정은 위키의 노트를 참고한다.)
    _positionDisplacementMagnitude = _multiplier * (1 - t) * sinf(M_PI * t);
    // displacementScale값에 따라 변위의 크기를 확대하거나 축소한다.
    _positionDisplacementMagnitudeCompensated = _positionDisplacementMagnitude * _displacementScaleRatio * 2;
    // 스케일 보정된 변위의 크기에 방향 성분을 더해, 2차원 벡터 성분으로 만든다.
    _positionDisplacement = ccp(_positionDisplacementMagnitudeCompensated * _trigonometrical.x, _positionDisplacementMagnitudeCompensated * _trigonometrical.y);
    // 압축비율을 정한다. 충돌한 가상의 벽면 경계를 침범하지 않기 위해서는 변위만큼 스프라이트가 얇아져야 하므로, 그 비율에 맞춰 압축률을 정한다.
    _compressionRatio = 1 - _positionDisplacementMagnitude / _collisionSize;
    // 반면, 충돌방향과 수직한 양방향으로는 스프라이트는 팽창한다. 기본적으로는 압축비의 역수이나, 주어진 보정값을 적용해야하므로 약간 변형한 뒤 팽창률을 정한다.
    _inflationRatio = _collisionSize / (_collisionSize - _positionDisplacementMagnitude * _inflationModifier);
    // 주어진 압축/팽창비를 x축 성분과 y축 성분으로 분할한다.
    _scale[0] = _compressionRatio * _scaleApplyingRatio.x + _inflationRatio * _scaleApplyingRatio.y;
    _scale[1] = _compressionRatio * _scaleApplyingRatio.y + _inflationRatio * _scaleApplyingRatio.x;
    
#if CC_ENABLE_STACKABLE_ACTIONS
    
    // 현재의 변위값에서 직전 호출시의 변위값만큼을 뺀 값(즉 변위의 변화량)을 적용한다.
    [node setPosition: ccpAdd([node position], ccpSub(_positionDisplacement, _previousPositionDisplacement))];
    // 기존의 스프라이트가 이미 스케일 보정이 적용된 것(즉 scaleX=scaleY=1이 아닌 경우)가 있을 수 있으므로, 역시 직전 호출시의 스케일값을 나누기로 제거한 후, 현재  결정된 스케일값을 적용한다.
    [node setScaleX:node.scaleX / _previousScale[0] * _scale[0]];
    [node setScaleY:node.scaleY / _previousScale[1] * _scale[1]];
    
#else
    
    [node setPosition: ccpAdd([node position], ccpSub(_positionDisplacement, _previousPositionDisplacement))];
    [node setScaleX:node.scaleX / _previousScale[0] * _scale[0]];
    [node setScaleY:node.scaleY / _previousScale[1] * _scale[1]];
    
#endif // CC_ENABLE_STACKABLE_ACTIONS
    
    // 다음 호출 시에 지금의 변위값/스케일값은 사용된다. 따라서 이들을 저장한다.
    _previousPositionDisplacement = _positionDisplacement;
    _previousScale[0] = _scale[0];
    _previousScale[1] = _scale[1];
}

@end



#pragma mark - CCActionDistortShared
// CCActionDistort의 상수 요소 관리 싱글톤
@implementation CCActionDistortShared

-(id) init
{
    self = [super init];
    if (!self) return(nil);
    
    // 울프램알파를 이용해서 구한 최대변위를 가지는 t의 값.
    _highestDisplacementTime = 0.354226323456594461428889646042586152765;
    
    return self;
}

static CCActionDistortShared *shared = nil;

+ (CCActionDistortShared *) shared
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

@end