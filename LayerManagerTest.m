//
//  LayerManagerTest.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"
#import "GNLayer.h"
#import "GNLayerManager.h"
#import <CoreLocation/CoreLocation.h>
#import <stdio.h>

int main( int argc, const char *argv[] ) {
	NSString *landmarkName = @"Boliou";
	CLLocation *landmarkLocation = [[CLLocation alloc] initWithLatitude:15.0 longitude:20.0];
	GNLandmark *newLandmark = [GNLandmark landmarkWithID:1 name:landmarkName location:landmarkLocation];
	GNLayer *academicBuildings = [GNLayer layerWithName:@"Academic Buildings"];
	GNLayer *food = [GNLayer layerWithName:@"Food"];
	GNLayer *administration = [GNLayer layerWithName:@"Administration"];
	
	printf("Starting active layers: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:academicBuildings];
	printf("After adding academic buildings: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:food];
	[newLandmark addActiveLayer:administration];
	printf("After adding two more: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark addActiveLayer:food];
	printf("After adding redundant food: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	printf("After removing food: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark removeActiveLayer:food];
	printf("After removing non-existant food: %i\n", [newLandmark getNumActiveLayers]);
	[newLandmark clearActiveLayers];
	printf("After removing active layers: %i\n", [newLandmark getNumActiveLayers]);
	
	return 0;
}