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
	NSString *landmarkName = @"Boliou";
	GNLandmark *newLandmark = [[GNLandmark landmarkWithID:1 name:landmarkName latitude:(CLLocationDegrees)15.0 longitude:(CLLocationDegrees)20.0] retain];
	GNLayer *academicBuildings = [GNLayer layerWithName:@"Academic Buildings"];
	GNLayer *food = [GNLayer layerWithName:@"Food"];
	GNLayer *administration = [GNLayer layerWithName:@"Administration"];
	[manager addLayer:academicBuildings];
	[manager addLayer:food active:NO];
	[manager addLayer:administration];
	[manager setLayer:administration active:YES];
	STAssertTrue([newLandmark getNumActiveLayers] == 0, @"The new Landmark should NOT be associated with any layers");
	[newLandmark addActiveLayer:academicBuildings];
	STAssertTrue([newLandmark getNumActiveLayers] == 1, @"The Landmark should be associated with 1 layer: academic buildings");
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:administration];
	STAssertTrue([newLandmark getNumActiveLayers] == 3, @"The Landmark should be associated with 3 layers: academic buildings, food and administration");
	[newLandmark addActiveLayer:food];
	STAssertTrue([newLandmark getNumActiveLayers] == 3, @"After adding a redundant layer, the landmark should still be associated with only 3 layers: academic buildings, food and administration");
	[newLandmark removeActiveLayer:food];
	STAssertTrue([newLandmark getNumActiveLayers] == 2, @"After removing what was a redundant layer, the landmark should now be associated with 2 layers: academic buildings and administration");
	[newLandmark removeActiveLayer:food];
	STAssertTrue([newLandmark getNumActiveLayers] == 2, @"After removing a non-existent layer, the landmark should still be associated with 2 layers: academic buildings and administration");
	[newLandmark clearActiveLayers];
	STAssertTrue([newLandmark getNumActiveLayers] == 0, @"After removing all layers, the landmark shouldn't be associated with any layers");
	[newLandmark release];
	[academicBuildings release];
	[food release];
	[administration release];
	[manager release];
}

- (void) testSingleton {
	GNLayerManager *firstManager = [GNLayerManager sharedManager];
	GNLayerManager *secondManager = [[GNLayerManager alloc] init];
	
	STAssertTrue(firstManager == secondManager, @"Should-be singleton class created two instances");
}

- (void) testServer {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	CarletonBuildingsLayer *carletonBuildings = [CarletonBuildingsLayer layerWithName:@"Carleton Buildings"];
	DiningAreasLayer *diningAreas = [DiningAreasLayer layerWithName:@"Dining Areas"];
	TweetLayer *tweets = [TweetLayer layerWithName:@"Tweets"];
	
}

@end
