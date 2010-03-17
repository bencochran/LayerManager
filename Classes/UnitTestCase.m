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
	
	int activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 0, @"The new Landmark should NOT be associated with any layers");
	
	[newLandmark addActiveLayer:carletonBuildings];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 1, @"The Landmark should be associated with 1 layer: academic buildings");
	
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:twitter];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 3, @"The Landmark should be associated with 3 layers: academic buildings, food and administration");
	
	[newLandmark addActiveLayer:food];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 3, @"After adding a redundant layer, the landmark should still be associated with only 3 layers: academic buildings, food and administration");
	
	[newLandmark removeActiveLayer:food];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 2, @"After removing what was a redundant layer, the landmark should now be associated with 2 layers: academic buildings and administration");
	
	[newLandmark removeActiveLayer:food];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 2, @"After removing a non-existent layer, the landmark should still be associated with 2 layers: academic buildings and administration");
	
	[newLandmark clearActiveLayers];
	activeLayerCount = newLandmark.activeLayers.count;
	STAssertEquals(activeLayerCount, 0, @"After removing all layers, the landmark shouldn't be associated with any layers");
	
	[carletonBuildings release];
	[food release];
	[twitter release];
}

- (void) testSingleton {
	GNLayerManager *firstManager = [GNLayerManager sharedManager];
	GNLayerManager *secondManager = [[GNLayerManager alloc] init];
	
	STAssertEqualObjects(firstManager, secondManager, @"Should-be singleton class created two instances");
}

- (void) testEditingTable {
//	GNLayerManager *manager = [GNLayerManager sharedManager];
	GNLayer *food = [[FoodLayer alloc] init];
	STAssertTrue ([food layerIsUserModifiable], @"The food layer should be user modifiable");
//	STAssertTrue (food.layerFields.count == 3, @"The food layer should have three modifiable fields");
	
}

- (void) testServer {
	GNLayerManager *manager = [GNLayerManager sharedManager];
	CarletonLayer *carleton = [[CarletonLayer alloc] init];
	FoodLayer *food = [[FoodLayer alloc] init];
	TweetLayer *tweets = [[TweetLayer alloc] init];
	// FOR SOME REASON THIS CRASHES!!!
	[manager addLayer:tweets];
	[manager addLayer:food];
	[manager addLayer:carleton active:YES];
	[carleton release];
	[food release];
	[tweets release];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationsUpdated:)
												 name:GNLandmarksUpdated
											   object:[GNLayerManager sharedManager]];
	
	CLLocation *location = [[CLLocation alloc] initWithLatitude:44.4654058108 longitude:-93.148436666400002];
	[[GNLayerManager sharedManager] updateToCenterLocation:location];
	[location release];
	// Because this happens asynchronously, we need to poll for updates
	while (self.landmarks == nil) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate
												  dateWithTimeIntervalSinceNow:1.0]];
		NSLog(@"Polling...");
	}
	
	NSLog(@"Finished");
	
	STAssertTrue(self.landmarks.count <= manager.maxLandmarks, @"LayerManager returned more landmark than the maximum");
}

- (void)locationsUpdated:(NSNotification *)note {
	self.landmarks = [note.userInfo objectForKey:@"landmarks"];
}

@end
