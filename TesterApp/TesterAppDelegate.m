//
//  TesterAppDelegate.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TesterAppDelegate.h"
#import <LayerManager.h>

@implementation TesterAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    	
	NSLog(@"Calling getNClosest on CarletonBuildings. . . .");
	
	GNLayer *carb = [[CarletonBuildingsLayer alloc] init];
	GNLayer *dining = [[DiningAreasLayer alloc] init];
	GNLayer *tweets = [[TweetLayer alloc] init];
	CLLocation *location1 = [[CLLocation alloc] initWithLatitude:44.46123053905879 longitude:-93.15569400787354];
	//CLLocation *location2 = [[CLLocation alloc] initWithLatitude:-1.2345 longitude:5.7785];
	[[GNLayerManager sharedManager] addLayer:carb];
	[[GNLayerManager sharedManager] addLayer:tweets active:NO];
	[[GNLayerManager sharedManager] setLayer:carb active:YES];
	[[GNLayerManager sharedManager] addLayer:dining active:YES];
	[carb release];
	[tweets release];
	[dining release];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationsUpdated:)
												 name:GNLandmarksUpdated
											   object:[GNLayerManager sharedManager]];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[[GNLayerManager sharedManager] updateToCenterLocation:location1];
	[location1 release];
	
	
//	NSArray *landmarks = [manager getNClosestLandmarks:100 toLocation:location1 maxDistance:5];
//	[location1 release];
	
//	NSLog(@"LayerManager returned:\n");
//	GNLandmark *landmark;
//	int i,j;
//	for(i = 0; i < [landmarks count]; i++)
//	{
//		landmark = [landmarks objectAtIndex:i];
//		NSLog(@"Item %i:", i);
//		NSLog(@"\t\tDist:\t%f", landmark.distance);
//		NSLog(@"\t\tID:\t%i", landmark.ID);
//		NSLog(@"\t\tname:\t%@", landmark.name);
//		NSLog(@"\tActive layers:");
//		for(j = 0; j < [landmark getNumActiveLayers]; j++)
//			NSLog(@"\t\t\tActive layer %i: %@", j, [[landmark.activeLayers objectAtIndex:j] name]);
//		NSLog(@"");
//	}
			
	/*NSString *landmarkName = @"Boliou";
	GNLandmark *newLandmark = [[GNLandmark landmarkWithID:1 name:landmarkName latitude:(CLLocationDegrees)15.0 longitude:(CLLocationDegrees)20.0] retain];
	GNLayer *academicBuildings = [GNLayer layerWithName:@"Academic Buildings"];
	GNLayer *food = [GNLayer layerWithName:@"Food"];
	GNLayer *administration = [GNLayer layerWithName:@"Administration"];
	
	NSLog(@"Starting active layers: %i", newLandmark.activeLayers.count);
	NSLog(@"landmark:%@", newLandmark);
	[newLandmark addActiveLayer:academicBuildings];
	NSLog(@"After adding academic buildings: %i", newLandmark.activeLayers.count);
	NSLog(@"active layers:%@", newLandmark.activeLayers);
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:administration];
	NSLog(@"After adding two more: %i", newLandmark.activeLayers.count);
	[newLandmark addActiveLayer:food];
	NSLog(@"After adding redundant food: %i", newLandmark.activeLayers.count);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing food: %i", newLandmark.activeLayers.count);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing non-existant food: %i", newLandmark.activeLayers.count);
	NSLog(@"active layers:%@", newLandmark.activeLayers);
	[newLandmark clearActiveLayers];
	NSLog(@"After removing active layers: %i", newLandmark.activeLayers.count);*/
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)locationsUpdated:(NSNotification *)note {
	NSArray *landmarks = [note.userInfo objectForKey:@"landmarks"];
	GNLandmark *landmark;
	for(int i = 0; i < [landmarks count]; i++)
	{
		landmark = [landmarks objectAtIndex:i];
		NSLog(@"Item %i:", i);
		NSLog(@"\t\tDist:\t%f", landmark.distance);
		NSLog(@"\t\tID:\t%@", landmark.ID);
		NSLog(@"\t\tname:\t%@", landmark.name);
		NSLog(@"\tActive layers:");
		for(int j = 0; j < landmark.activeLayers.count; j++)
			NSLog(@"\t\t\tActive layer %i: %@", j, [[landmark.activeLayers objectAtIndex:j] name]);
		NSLog(@"");
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
