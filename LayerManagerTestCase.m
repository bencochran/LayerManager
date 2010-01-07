//
//  LayerManagerTestCase.m
//  LayerManager
//
//  Created by iComps on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LayerManagerTestCase.h"


@implementation LayerManagerTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    //id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    //STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

- (void) testMath {
    
	STFail(@"Must fail to succeed.");
	STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
