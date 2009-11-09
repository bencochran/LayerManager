//
//  GNLayerManager.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayerManager.h"


@implementation GNLayerManager

-(void)addLayer:(GNLayer*)layer {
	[layers removeObject:layer];
	[layers addObject:layer];
}

-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location maxDistance:(float)maxDistance {
	return nil;
}

-(GNLandmark*)getLandmark:(int)landmarkID name:(NSString*)landmarkName location:(CLLocation*)landmarkLocation {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:landmarkID]);
	if(landmark != nil)
		return landmark;
	
	landmark = [GNLandmark initWithID:landmarkID name:landmarkName location:landmarkLocation];
	[allLandmarks setObject:landmark forKey:landmarkID];
	return landmark;
}

-(void) setLayer:(GNLayer*)layer active:(bool)active {
	[layer setActive:active];
	
	if(active == YES)
	{
		/* TODO: Call getNClosestLandmarks on layer, with last n, location, and maxDistance
		         merge with current list */
	}
	else
	{
		NSMutableArray *layerLandmarks = [layer removeSelfFromLandmarks];
		Dist_And_Landmark *distLand;
		int i;
		for(i = 0; i < [layerLandmarks count]; i++)
		{
			distLand = (Dist_And_Landmark *) [layerLandmarks objectAtIndex:i];
			if([distLand->landmark getNumActiveLayers] == 0)
			{
				[allLandmarks removeObjectForKey:[distLand->landmark getID]];
				[distAndLandmarkList removeObject:distLand];
				[distLand->landmark release];
				free(distLand);
			}
		}
	}
}

@end