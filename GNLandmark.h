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

-(NSString*) getName;
-(CLLocation*) getLocation;
-(int) getID;

-(void) addActiveLayer:(GNLayer*)layer;
-(void) removeActiveLayer:(GNLayer*)layer;
-(NSMutableArray*) getActiveLayers;
-(int) getNumActiveLayers;
-(void) clearActiveLayers;

@end
