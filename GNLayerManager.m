//
//  GNLayerManager.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayerManager.h"

@implementation GNLayerManager

-(id)init {
	if (self = [super init]) {
		layers = [[NSMutableArray alloc] init];
		distAndLandmarkList = [[NSMutableArray alloc] init];
		allLandmarks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

// adds the provided layer to the list of layers
-(void)addLayer:(GNLayer*)layer {
	[layers removeObject:layer];
	[layers addObject:layer];
}

// calls getNClosestLandmarks on each layer in the list of layers
// returns a list of GNDistAndLandmarks, sorted in increasing order by distance,
// of the n closest landmarks (closer than maxDistance) returned by any layer
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location maxDistance:(float)maxDistance {
	NSMutableArray *buffer;
	GNDistAndLandmark *gndl;
	int i;
	NSArray *allLandmarksList = [allLandmarks allValues];
	
	// clear active layers for all landmarks
	for(i = 0; i < [allLandmarksList count]; i++)
		[(GNLandmark*) [allLandmarksList objectAtIndex:i] clearActiveLayers];
	
	// release all GNDistAndLandmarks and clear last list of closest landmarks
	for(i = 0; i < [distAndLandmarkList count]; i++)
		[[distAndLandmarkList objectAtIndex:i] release];
	[distAndLandmarkList removeAllObjects];
	
	///////////////////////////// TODO: ADD THREADING HERE 
	// add all GNDistAndLandmarks to distAndLandmarkList
	for(i = 0; i < (int) ([layers count]); i++)
		if([(GNLayer *)[layers objectAtIndex:i] active] == YES)
		//////////////////////// PROBLEM: CURRENTLY ADDING DUPLICATE LANDMARKS (if landmark is part of 2 layers, will be added twice)
			[distAndLandmarkList addObjectsFromArray:[[layers objectAtIndex:i] getNClosestLandmarks:n toLocation:location withLM:self]];
	
	// sort distAndLandmarkList
	[distAndLandmarkList sortUsingSelector:@selector(compareTo:)];
	
	// return top n closest landmarks that are closer than maxDistance
	buffer = [[NSMutableArray alloc] init];
	for(i = 0; i < MIN(n,[distAndLandmarkList count]); i++)
	{
		gndl = [distAndLandmarkList objectAtIndex:i];
		if(gndl.dist <= maxDistance)
			[buffer addObject:gndl];
		else
			break;
	}
	
	return buffer;
}

// if a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(int)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:[NSNumber numberWithInt:landmarkID]]);
	if(landmark == nil)
	{
		landmark = [[GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude] retain];
		[allLandmarks setObject:landmark forKey:[NSNumber numberWithInt:landmarkID]];
	}
	return landmark;
}

// sets the given layer to the indicated activity
// if the layer is being set to inactive, removes this layer
// from its landmarks' lists of active layers,
// and clears the layer's closestLandmarks list
// if any landmark has no more active layers, removes the
// appropriate GNDistAndLandmark from the distAndLandmarksList,
// removes the landmark from allLandmarks, and releases
// both the GNLandmark and the GNDistAndLandmark
-(void) setLayer:(GNLayer*)layer active:(BOOL)active {
	[layer setActive:active];
	
	if(active == NO)
	{
		NSMutableArray *layerLandmarks = [layer removeSelfFromLandmarks];
		GNDistAndLandmark *gndl;
		int i;
		for(i = 0; i < [layerLandmarks count]; i++)
		{
			gndl = (GNDistAndLandmark*) [layerLandmarks objectAtIndex:i];
			if([gndl.landmark getNumActiveLayers] == 0)
			{
				[allLandmarks removeObjectForKey:[NSNumber numberWithInt:[gndl.landmark ID]]];
				[distAndLandmarkList removeObject:gndl];
				[gndl.landmark release];
				[gndl release];
			}
		}
	}
}

-(void)dealloc {
	NSArray *allLandmarkIDs;
	int i;
	///////////////////////////////////////// SHOULD WE BE DEALLOCATING THE LAYERS???
	// dealloc each layer and the layer list
	for(i = 0; i < [layers count]; i++)
		[[layers objectAtIndex:i] dealloc];
	[layers dealloc];
	
	// dealloc each GNDistAndLandmark
	for(i = 0; i < [distAndLandmarkList count]; i++)
		[[distAndLandmarkList objectAtIndex:i] dealloc];
	[distAndLandmarkList dealloc];
	
	// dealloc each GNLandmark
	allLandmarkIDs = [allLandmarks allKeys];
	for(i = 0; [allLandmarkIDs count]; i++)
		[[allLandmarks objectForKey:[allLandmarkIDs objectAtIndex:i]] dealloc];
	[allLandmarks dealloc];
	
	[super dealloc];
}

@end