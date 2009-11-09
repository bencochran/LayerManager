//
//  GNLandmark.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"
#import <stdlib.h>

@implementation GNLandmark

@synthesize ID=_id, name=_name, location=_location, activeLayers=_activeLayers;

// Methods starting with "init" are usually reserved for non-static methods which run
// on an alloc'd object, not static methods wich alloc AND init an object itself.
+(GNLandmark*) landmarkWithID:(int)ID name:(NSString*)name location:(CLLocation*)location {
	GNLandmark *newLandmark = [[[GNLandmark alloc] init] autorelease];
	newLandmark.ID = ID;
	newLandmark.name = name;
	newLandmark.location = location;
	return newLandmark;
}

-(int)getNumActiveLayers {
	return (int) ([self.activeLayers count]);
}

-(void)addActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject: layer];
	[self.activeLayers addObject: layer];
}

-(void)removeActiveLayer:(GNLayer*)layer {
	[self.activeLayers removeObject: layer];
}

-(void)clearActiveLayers {
	[self.activeLayers removeAllObjects];
}

@end
