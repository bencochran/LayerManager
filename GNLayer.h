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
	NSString* _name;
	BOOL _active;
	NSString* _iconPath;
	NSMutableArray* _closestLandmarks;
	NSDictionary* layerInfoByLandmarkID;
// layerInfoByLandmarkID stores the information necessary to generate the final view of a landmark. 
// The dictionary's keys are Landmark IDs.
	
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableArray* closestLandmarks;


+(GNLayer*)initWithName:(NSString*)initName;

// -(NSIcon) getIcon;
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location;
-(NSMutableArray*)removeSelfFromLandmarks;
-(UIViewController*)getLayerViewForID:(int)landmarkID;

@end

struct Dist_And_Landmark {
	float dist;
	GNLandmark *landmark;
}; typedef struct Dist_And_Landmark Dist_And_Landmark;