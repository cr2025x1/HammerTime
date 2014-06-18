//
//  CCActionUDC.h
//  HammerTime
//
//  Created by Chrome-MBPR on 5/22/14.
//  Copyright (c) 2014 cr2025x1. All rights reserved.
//

#import "CCActionUDC.h"
#import "cocos2d.h"
#import "cocos2d-ui.h"



// 자유낙하 액션 클래스
@interface CCActionFreeFall : CCActionInterval <NSCopying> {
	CGPoint _positionDelta;
    CCNode *node;
    CGPoint _terminalVelocity;
    CGPoint _currentVelocity;
    CGPoint _initialVelocity;
    CGPoint _multiplier;
    CGPoint _poly1;
    CGPoint _poly2;
}

@property (nonatomic, readonly) CGPoint terminalVelocity;
@property (nonatomic, readonly) CGPoint currentVelocity;

/**
 *  Creates the action.
 *
 *  @param duration      Action interval.
 *  @param deltaPosition Delta position.
 *
 *  @return New freefall action.
 */
+ (id)actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition initialVelocity:(CGPoint)initialVelocity;
+ (id)actionWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

/**
 *  Initializes the action.
 *
 *  @param duration      Action interval.
 *  @param deltaPosition Delta position.
 *
 *  @return New freefall action.
 */
- (id)initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition initialVelocity:(CGPoint)initialVelocity;
- (id)initWithDuration: (CCTime)duration position:(CGPoint)deltaPosition;

@end



// 충격지점 튕김 액션 클래스
@interface CCActionBump : CCActionInterval <NSCopying> {
    CGPoint _givenVelocity;
	CGPoint _positionDisplacement;
    CGPoint _previousPositionDisplacement;
    CCNode *node;
    float _multiplier;
    
    CGPoint _trigonometrical;
    float _velocityMagnitude;
    float _positionDisplacementMagnitude;
    
}

/**
 *  Creates the action.
 *
 *  @param duration      Action interval.
 *  @param givenVelocity Initial velocity.
 *
 *  @return New bump action.
 */
+ (id)actionWithDuration: (CCTime)duration velocity:(CGPoint)velocity;

/**
 *  Initializes the action.
 *
 *  @param duration      Action interval.
 *  @param givenVelocity Initial velocity.
 *
 *  @return New bump action.
 */
- (id)initWithDuration: (CCTime)duration velocity:(CGPoint)velocity;

@end



@class CCActionDistortShared;

// 충격지점에서의 찌그러짐 후 복원 액션 클래스
@interface CCActionDistort : CCActionBump <NSCopying> {
    CGPoint _scaleApplyingRatio;
    float _collisionSize;
    float _inflationModifier;
    CGPoint _highestDisplacement;
    float _compressionRatio;
    float _inflationRatio;
    float _displacementScaleRatio;
    float _positionDisplacementMagnitudeCompensated;
    float _previousScale[2];
    float _scale[2];
    
    CCActionDistortShared *_sharedSingleton;
}

/**
 *  Creates the action.
 *
 *  @param duration      Action interval.
 *  @param givenVelocity Initial velocity.
 *  @param collisionSize Collision size of the object.
 *  @param inflationRatio Ratio of inflation to compression of the object.
 *
 *  @return New bump with compression action.
 */
+ (id)actionWithDuration: (CCTime)duration velocity:(CGPoint)velocity collisionSize:(float)collisionSize inflationRatio:(float)inflationRatio displacementScale:(float)displacementScale;

/**
 *  Initializes the action.
 *
 *  @param duration      Action interval.
 *  @param givenVelocity Initial velocity.
 *  @param compressibility Compressibility of the object.
 *  @param inflationRatio Ratio of inflation to compression of the object.
 *
 *  @return New bump with compression action.
 */
- (id)initWithDuration: (CCTime)duration velocity:(CGPoint)velocity collisionSize:(float)collisionSize inflationRatio:(float)inflationRatio displacementScale:(float)displacementScale;

@end



// CCActionDistort의 상수 요소 관리 싱글톤
@interface CCActionDistortShared : NSObject {
    float _highestDisplacementTime;
}

@property (nonatomic, readonly) float highestDisplacementTime;
+ (CCActionDistortShared *) shared;

@end
