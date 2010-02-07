//
//  FoodLayer.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "FoodLayer.h"
#import "JSON.h"

@implementation FoodLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Food";
		iconPath = @"food.png";
		userModifiable = YES;
		NSArray *hoursField = [[NSMutableArray alloc] initWithObjects:@"Hours", @"textView", nil];
		NSArray* summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *descriptionField = [[NSMutableArray alloc] initWithObjects:@"Description", @"textView", nil];
		NSArray *menuField = [[NSMutableArray alloc] initWithObjects:@"Menu", @"textView", nil];
		layerFields = [[NSArray alloc] initWithObjects:hoursField, summaryField, descriptionField, menuField, nil];
		[hoursField release];
		[summaryField release];
		[descriptionField release];
		[menuField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location {	
	// http://dev.gnar.us/getInfo.py/DiningAreas?lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/DiningAreas?lat=%f&lon=%f&maxLandmarks=%d",
						   [location coordinate].latitude, [location coordinate].longitude, [[GNLayerManager sharedManager] maxLandmarks]];
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	[layerInfoByLandmarkID removeAllObjects];
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release]; reply = nil;
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"menuURL"] forKey:@"menuURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"ID"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		if (self.active) {
			[landmark addActiveLayer:self];
		}
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[self.landmarks addObject:landmark];
		[layerInfo release];
	}
	
	[self.landmarks sortUsingSelector:@selector(compareTo:)];
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];
}

- (void) postLandmarkArray:(NSArray *)info withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/restaurants"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[info objectAtIndex:0] forKey:@"restName"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"hours"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"description"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setData:photoData forKey:@"restImage"];
	[request startAsynchronous];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	UIViewController *viewController = [[UIViewController alloc] init];
	UIWebView *webView = [[UIWebView alloc] init];
	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"menuURL"];

	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	viewController.title = self.name;
	viewController.view = webView;
	[webView release];
	
	return [viewController autorelease];;
}

@end