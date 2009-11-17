//
//  TesterAppDelegate.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TesterAppDelegate.h"
#import "GNLandmark.h"
#import "GNLayer.h"
#import "GNLayerManager.h"

@implementation TesterAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	NSLog(@"HELLO");
	
	NSString *landmarkName = @"Boliou";
	CLLocation *landmarkLocation = [[CLLocation alloc] initWithLatitude:15.0 longitude:20.0];
	GNLandmark *newLandmark = [GNLandmark landmarkWithID:1 name:landmarkName location:landmarkLocation];
	GNLayer *academicBuildings = [GNLayer layerWithName:@"Academic Buildings"];
	GNLayer *food = [GNLayer layerWithName:@"Food"];
	GNLayer *administration = [GNLayer layerWithName:@"Administration"];
	
	NSLog(@"Starting active layers: %@", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:academicBuildings];
	NSLog(@"After adding academic buildings: %i", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:administration];
	NSLog(@"After adding two more: %i", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:food];
	NSLog(@"After adding redundant food: %i", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing food: %i", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	NSLog(@"After removing non-existant food: %i", [newLandmark getNumActiveLayers]);
	[newLandmark clearActiveLayers];
	NSLog(@"active layers:%@", newLandmark.activeLayers);
	NSLog(@"After removing active layers: %i", [newLandmark getNumActiveLayers]);
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

@end
