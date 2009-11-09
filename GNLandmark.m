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

+(GNLandmark*)initWithID:(int)initID name:(NSString*)initName location:(CLLocation*)initLocation {
	GNLandmark *newLandmark = [[GNLandmark alloc] init];
	newLandmark->ID = initID;
	newLandmark->name = initName;
	newLandmark->location = initLocation;
	return newLandmark;
}

-(int)getID {
	return ID;
}

-(NSString*)getName {
	return name;
}

-(CLLocation*)getLocation {
	return location;
}

-(NSMutableArray*)getActiveLayers {
	return activeLayers;
}

-(int)getNumActiveLayers {
	return (int) ([activeLayers count]);
}

-(void)addActiveLayer:(GNLayer*)layer {
	[activeLayers removeObject: layer];
	[activeLayers addObject: layer];
}

-(void)removeActiveLayer:(GNLayer*)layer {
	[activeLayers removeObject: layer];
}

-(void)clearActiveLayers {
	[activeLayers removeAllObjects];
}

@end
