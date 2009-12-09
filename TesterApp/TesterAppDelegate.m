//
//  TesterAppDelegate.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TesterAppDelegate.h"
#import "LayerManager.h"

@implementation TesterAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    	
	NSLog(@"Calling getNClosest on CarletonBuildings. . . .");
	
	GNLayerManager *manager = [[GNLayerManager alloc] init];
	GNLayer *carb = [[CarletonBuildings alloc] init];
	CLLocation *location1 = [[CLLocation alloc] initWithLatitude:44.4654058108 longitude:-93.148436666400002];
	CLLocation *location2 = [[CLLocation alloc] initWithLatitude:-1.2345 longitude:5.7785];
	[manager addLayer:carb];
	[manager setLayer:carb active:YES];
	NSMutableArray *gndlList = [manager getNClosestLandmarks:10 toLocation:location1 maxDistance:0.22];
	
	NSLog(@"LayerManager returned:\n");
	GNDistAndLandmark *gndl;
	int i,j;
	for(i = 0; i < [gndlList count]; i++)
	{
		gndl = [gndlList objectAtIndex:i];
		NSLog(@"Item %i:", i);
		NSLog(@"\t\tDist:\t%f", gndl.dist);
		NSLog(@"\t\tID:\t%i", gndl.landmark.ID);
		NSLog(@"\t\tname:\t%@", gndl.landmark.name);
		NSLog(@"\tActive layers:");
		for(j = 0; j < [gndl.landmark getNumActiveLayers]; j++)
			NSLog(@"\t\t\tActive layer %i: %@", j, [[[gndl.landmark activeLayers] objectAtIndex:j] name]);
		NSLog(@"");
	}
	
	NSLog(@"Releasing CarletonBuildings. . . .");
	[carb release];
	NSLog(@"Releasing LayerManager");
	//[manager release];
	
	/*NSString *landmarkName = @"Boliou";
	GNLandmark *newLandmark = [[GNLandmark landmarkWithID:1 name:landmarkName latitude:(CLLocationDegrees)15.0 longitude:(CLLocationDegrees)20.0] retain];
	GNLayer *academicBuildings = [GNLayer layerWithName:@"Academic Buildings"];
	GNLayer *food = [GNLayer layerWithName:@"Food"];
	GNLayer *administration = [GNLayer layerWithName:@"Administration"];
	
	NSLog(@"Starting active layers: %i", [newLandmark getNumActiveLayers]);
	NSLog(@"landmark:%@", newLandmark);
	[newLandmark addActiveLayer:academicBuildings];
	NSLog(@"After adding academic buildings: %i", [newLandmark getNumActiveLayers]);
	NSLog(@"active layers:%@", newLandmark.activeLayers);
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:administration];
	NSLog(@"After adding two more: %i", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:food];
	NSLog(@"After adding redundant food: %i", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing food: %i", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing non-existant food: %i", [newLandmark getNumActiveLayers]);
	NSLog(@"active layers:%@", newLandmark.activeLayers);
	[newLandmark clearActiveLayers];
	NSLog(@"After removing active layers: %i", [newLandmark getNumActiveLayers]);*/
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
