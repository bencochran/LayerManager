//
//  GNLayer.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayer.h"

@implementation GNLayer

-(NSString *) getName {
	return name;
}

-(bool) getActive {
	return active;
}

// -(NSIcon) getIcon;

-(void) setActive: (bool) active {
	self.active = active;
}

-(NSMutableArray *) removeSelfFromLandmarks {
	NSMutableArray *ret = closestLandmarks;
	int i;
	for(i = 0; i < [closestLandmarks count]; i++)
		[((Dist_And_Landmark *) [closestLandmarks objectAtIndex: i]).landmark removeActiveLayer: self];
	closestLandmarks = [[NSMutableArray alloc] init];
	return ret;
}

@end