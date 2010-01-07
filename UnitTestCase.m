//
//  UnitTestCase.m
//  LayerManager
//
//  Created by iComps on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UnitTestCase.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@implementation UnitTestCase

- (void) testPass {
	
	STAssertTrue(YES, @"");
	
}
- (void) testFail {
	
	//STFail(@"Must fail to succeed.");
}

- (void) testLayerManager {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	[manager release];
}

- (void) testSingleton {
	GNLayerManager *firstManager = [GNLayerManager sharedManager];
	GNLayerManager *secondManager = [[GNLayerManager alloc] init];
	
	STAssertTrue(firstManager == secondManager, @"Should-be singleton class created two instances");
}

@end
