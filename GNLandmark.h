//
//  GNLandmark.h
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class GNLayer;

@interface GNLandmark : NSObject {
	int ID;
	NSString *name;
	CLLocation *location;
	NSMutableArray *activeLayers;
}

-(int)getID;
-(NSString*)getName;
-(CLLocation*)getLocation;
-(NSMutableArray*)getActiveLayers;

-(void)addActiveLayer:(GNLayer*)layer;
-(void)removeActiveLayer:(GNLayer*)layer;
-(int)getNumActiveLayers;
-(void)clearActiveLayers;

@end