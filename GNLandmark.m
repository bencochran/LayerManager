//
//  GNLandmark.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLandmark.h"

@implementation GNLandmark

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
