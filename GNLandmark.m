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

+(GNLandmark*)initWithID:(int)initID name:(NSString*)initName location:(CLLocation*)initLocation {
	GNLandmark *newLandmark = [[GNLandmark alloc] init];
	newLandmark.ID = initID;
	newLandmark.name = initName;
	newLandmark.location = initLocation;
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
