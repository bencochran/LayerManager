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
	int _id;
	NSString* _name;
	CLLocation* _location;
	NSMutableArray* _activeLayers;
}

@property (nonatomic) int ID;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, retain) CLLocation* location;
@property (nonatomic, retain) NSMutableArray* activeLayers;

+(GNLandmark*)initWithID:(int)initID name:(NSString*)initName location:(CLLocation*)initLocation;

-(void)addActiveLayer:(GNLayer*)layer;
-(void)removeActiveLayer:(GNLayer*)layer;
-(int)getNumActiveLayers;
-(void)clearActiveLayers;

@end