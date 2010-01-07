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
#import "GNLayerManager.h"


@implementation UnitTestCase

- (void) testPass {
	
	STAssertTrue(TRUE, @"");
	
}
- (void) testFail {
	
	//STFail(@"Must fail to succeed.");
}

- (void) testLayerManager {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	[manager release];
}

@end
