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
	if(self = [super init]) {
		layers = [[NSMutableArray alloc] init];
		distAndLandmarkList = [[NSMutableArray alloc] init];
		allLandmarks = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)addLayer:(GNLayer*)layer {
	[layers removeObject:layer];
	[layers addObject:layer];
}

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location maxDistance:(float)maxDistance {
	NSMutableArray *buffer;
	GNDistAndLandmark *gndl;
	int i;
	NSArray *allLandmarksList = [allLandmarks allValues];
	
	// clear last list of closest landmarks
	[distAndLandmarkList removeAllObjects];
	
	// clear active layers for all landmarks
	for(i = 0; i < [allLandmarksList count]; i++)
		[(GNLandmark*) [allLandmarksList objectAtIndex:i] clearActiveLayers];
	
	// add all GNDistAndLandmarks to distAndLandmarkList
	for(i = 0; i < (int) ([layers count]); i++)
		if([(GNLayer *)[layers objectAtIndex:i] active] == YES)
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

-(GNLandmark*)getLandmark:(int)landmarkID name:(NSString*)landmarkName location:(CLLocation*)landmarkLocation {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:[NSNumber numberWithInt:landmarkID]]);
	if(landmark != nil)
		return landmark;
	
	landmark = [[GNLandmark landmarkWithID:landmarkID name:landmarkName location:landmarkLocation] retain];
	[allLandmarks setObject:landmark forKey:[NSNumber numberWithInt:landmarkID]];
	return landmark;
}

-(void) setLayer:(GNLayer*)layer active:(bool)active {
	[layer setActive:active];
	
	if(active == NO)
	{
		NSMutableArray *layerLandmarks = [layer removeSelfFromLandmarks];
		GNDistAndLandmark *distLand;
		int i;
		for(i = 0; i < [layerLandmarks count]; i++)
		{
			distLand = (GNDistAndLandmark *) [layerLandmarks objectAtIndex:i];
			if([distLand.landmark getNumActiveLayers] == 0)
			{
				[allLandmarks removeObjectForKey:[NSNumber numberWithInt:[distLand.landmark ID]]];
				[distAndLandmarkList removeObject:distLand];
				[distLand.landmark release];//////////////////////////////////
				[distLand release];
			}
		}
	}
}

-(void)dealloc {
	[layers dealloc];
	[distAndLandmarkList dealloc];
	[allLandmarks dealloc];
	[super dealloc];
}

@end