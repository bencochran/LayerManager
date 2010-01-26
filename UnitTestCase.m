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

@synthesize landmarks=_landmarks;

- (void) testPass {
	STAssertTrue(YES, @"");
	
}
- (void) testFail {
	
	//STFail(@"Must fail to succeed.");
}

- (void) testLayerManager {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	GNLandmark *newLandmark = [GNLandmark landmarkWithID:@"1" name:@"Boliou" latitude:(CLLocationDegrees)15.0 longitude:(CLLocationDegrees)20.0];
	GNLayer *carletonBuildings = [[CarletonLayer alloc] init];
	GNLayer *food = [[FoodLayer alloc] init];
	GNLayer *twitter = [[TweetLayer alloc] init];
	[manager addLayer:carletonBuildings];
	[manager addLayer:food active:YES];
	[manager addLayer:twitter];
	[manager setLayer:twitter active:NO];
	STAssertTrue(newLandmark.activeLayers.count == 0, @"The new Landmark should NOT be associated with any layers");
	[newLandmark addActiveLayer:carletonBuildings];
	STAssertTrue(newLandmark.activeLayers.count == 1, @"The Landmark should be associated with 1 layer: academic buildings");
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:twitter];
	STAssertTrue(newLandmark.activeLayers.count == 3, @"The Landmark should be associated with 3 layers: academic buildings, food and administration");
	[newLandmark addActiveLayer:food];
	STAssertTrue(newLandmark.activeLayers.count == 3, @"After adding a redundant layer, the landmark should still be associated with only 3 layers: academic buildings, food and administration");
	[newLandmark removeActiveLayer:food];
	STAssertTrue(newLandmark.activeLayers.count == 2, @"After removing what was a redundant layer, the landmark should now be associated with 2 layers: academic buildings and administration");
	[newLandmark removeActiveLayer:food];
	STAssertTrue(newLandmark.activeLayers.count == 2, @"After removing a non-existent layer, the landmark should still be associated with 2 layers: academic buildings and administration");
	[newLandmark clearActiveLayers];
	STAssertTrue(newLandmark.activeLayers.count == 0, @"After removing all layers, the landmark shouldn't be associated with any layers");
	[carletonBuildings release];
	[food release];
	[twitter release];
}

- (void) testSingleton {
	GNLayerManager *firstManager = [GNLayerManager sharedManager];
	GNLayerManager *secondManager = [[GNLayerManager alloc] init];
	
	STAssertTrue(firstManager == secondManager, @"Should-be singleton class created two instances");
}

- (void) testEditingTable {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	GNLayer *food = [[FoodLayer alloc] init];
	//STAssertTrue ([food layerIsUserModifiable], @"The food layer should be user modifiable");
	//STAssertTrue (food.layerFields.count == 3, @"The food layer should have three modifiable fields");
	
}

//- (void) testServer {
//	GNLayerManager *manager = [GNLayerManager sharedManager];
//	CarletonLayer *carletonBuildings = [[CarletonLayer alloc] init];
//	FoodLayer *diningAreas = [[FoodLayer alloc] init];
//	TweetLayer *tweets = [[TweetLayer alloc] init];
//	// FOR SOME REASON THIS CRASHES!!!
//	[manager addLayer:tweets];
//	STAssertTrue(NO, @"Must FAIL");
//	[manager addLayer:diningAreas];
//	[manager addLayer:carletonBuildings active:YES];
//	[carletonBuildings release];
//	[diningAreas release];
//	[tweets release];
	
//	STAssertTrue(NO, @"Must FAIL");
	
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(locationsUpdated:)
//												 name:GNLandmarksUpdated
//											   object:[GNLayerManager sharedManager]];
//	
//	CLLocation *location = [[CLLocation alloc] initWithLatitude:44.4654058108 longitude:-93.148436666400002];
//	[[GNLayerManager sharedManager] updateToCenterLocation:location];
//	[location release];
	// Because this happens asynchronously, we need to poll for updates
//	while (self.landmarks == nil) {
//		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate
//												  dateWithTimeIntervalSinceNow:1.0]];
//		NSLog(@"Polling...");
//	}
	
//	NSLog(@"Finished");
	
	
//	[[GNLayerManager sharedManager] getNClosestLandmarks: 1 toLocation:location1 maxDistance:5];
//	STAssertTrue(NO, @"Must FAIL");
//	STAssertTrue([[GNLayerManager sharedManager] getSizeofClosestLandmarks] == 2, @"The max number of landmarks was 1, hence there should only be 1 in the closest landmark list");

//}

- (void)locationsUpdated:(NSNotification *)note {
	self.landmarks = [note.userInfo objectForKey:@"landmarks"];
}

@end
