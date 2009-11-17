//
//  GNLandmark.m
//  Implementation of GNLandmark
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"
#import <stdlib.h>

@implementation GNLandmark

@synthesize ID=_id, name=_name, activeLayers=_activeLayers;

+(GNLandmark*)landmarkWithID:(int)ID name:(NSString*)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *newLandmark = [[[GNLandmark alloc] initWithLatitude:longitude longitude:longitude] autorelease];
	newLandmark.ID = ID;
	newLandmark.name = name;
	newLandmark.activeLayers = [[NSMutableArray alloc] init];
	return newLandmark;
}

-(int)getNumActiveLayers {
	return (int) ([self.activeLayers count]);
}

-(void)addActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject:layer];
	[self.activeLayers addObject:layer];
}

-(void)removeActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject: layer];
}

-(void)clearActiveLayers {
	[self.activeLayers removeAllObjects];
}

-(void)dealloc {
	[self.name release];
	[self.activeLayers release];
	[super dealloc];
}

@end