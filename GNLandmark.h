//
//  GNLandmark.h
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GNLayer.h"
#import <Cocoa/Cocoa.h>

@interface GNLandmark : NSObject {
	int ID;
	NSString *name;
	CLLocation *location;
	NSMutableArray *activeLayers;
}

-(int) getID;
-(NSString *) getName;
-(CLLocation *) getLocation;
-(NSMutableArray *) getActiveLayers;

-(int) getNumActiveLayers;
-(void) addActiveLayer: (GNLayer *) layer;
-(void) removeActiveLayer: (GNLayer*) layer;
-(void) clearActiveLayers;

@end