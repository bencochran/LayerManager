//
//  GNLandmark.h
//  Stores the information relevant to a landmark:
//      a unique integer identifier
//      a string name (not necessarily unique)
//      a longitude and latitude packaged into a CLLocation
//      a list of the active layers that are currently storing information on this landmark
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

+(GNLandmark*)landmarkWithID:(int)ID name:(NSString*)name location:(CLLocation*)location;

-(void)addActiveLayer:(GNLayer*)layer;
-(void)removeActiveLayer:(GNLayer*)layer;
-(int)getNumActiveLayers;
-(void)clearActiveLayers;

@end