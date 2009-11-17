//
//  GNLayer.h
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLandmark.h"
#import "GNLayerManager.h"

@class GNLayerManager;

@interface GNLayer : NSObject {
	NSString* _name;
	BOOL _active;
	NSString* iconPath;
	NSMutableArray* _closestLandmarks;
	NSMutableDictionary* layerInfoByLandmarkID;
// layerInfoByLandmarkID stores the information necessary to generate the final view of a landmark. 
// The dictionary's keys are Landmark IDs.
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableArray* closestLandmarks;

+(GNLayer*)layerWithName:(NSString*)initName;

// -(NSIcon) getIcon;
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager;
-(NSMutableArray*)removeSelfFromLandmarks;
-(NSString*)getSummaryStringForID:(int)landmarkID;
-(UIViewController*)getLayerViewForID:(int)landmarkID;

@end


@interface GNDistAndLandmark : NSObject {
	float _dist;
	GNLandmark *_landmark;
}

@property (nonatomic) float dist;
@property (nonatomic, retain) GNLandmark *landmark;

+(GNDistAndLandmark*)gndlWithDist:(float)initDist andLandmark:(GNLandmark*)initLandmark;
-(NSComparisonResult)compareTo:(GNDistAndLandmark*)gndl;

@end