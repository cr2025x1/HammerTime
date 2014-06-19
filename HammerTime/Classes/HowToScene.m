//
//  HowToScene.m
//  HammerTime
//
//  Created by JH Lee on 2014. 5. 22..
//  Copyright 2014년 cr2025x1. All rights reserved.
//

#import "HowToScene.h"
#import "MenuScene.h"
#import "HowtoGroup.h"

// -----------------------------------------------------------------------
#pragma mark - HowToScene
// -----------------------------------------------------------------------

@implementation HowToScene
{
    CCNode *howtoNode;
    
    CCButton *backButton;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HowToScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    [self createHowtoNode];
    
    return self;
}


// -----------------------------------------------------------------------
#pragma mark - Create HowtoNode
// -----------------------------------------------------------------------

- (void)createHowtoNode
{
    howtoNode = [[HowtoGroup alloc] init];
    howtoNode.anchorPoint = ccp(0.5f, 0.5f);
    howtoNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height);
    howtoNode.positionType = CCPositionTypeNormalized;
    howtoNode.position = ccp(0.5f, 0.5f);
    
    [self addChild:howtoNode z:20];
}

// -----------------------------------------------------------------------

@end
