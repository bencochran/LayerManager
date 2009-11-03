//
//  GNLayer.h
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLandmark.h"

@interface GNLayer : NSObject {
	NSString *name;
	bool active;
	NSString *iconPath;
	NSMutableArray *closestLandmarks;
	NSDictionary *layerInfoByLandmarkID;
// layerInfoByLandmarkID stores the information necessary to generate the final view of a landmark. 
// The dictionary's keys are Landmark IDs.
	
}

-(NSString *) getName;
-(bool) getActive;
// -(NSIcon) getIcon;
-(void) setActive:(bool)active;
-(NSMutableArray*) getNClosestLandmarks:(int)n toLocation:(CLLocation*)location;
-(NSArray*) removeSelfFromLandmarks;
-(UIViewController*) getLayerViewForID:(int)landmarkID;

@end

struct Dist_And_Landmark {
	float dist;
	GNLandmark *landmark;
};