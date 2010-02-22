//
//  SportingArenasLayer.m
//  LayerManager
//
//  Created by Eric Alexander on 2/20/10.
//  Copyright 2010 Gnarus. All rights reserved.
//

#import "SportingArenasLayer.h"
#import "JSON.h"

@implementation SportingArenasLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Sports";
		iconPath = @"sports.png";
		userModifiable = YES;
		NSArray *nameField = [[NSMutableArray alloc] initWithObjects:@"Name", @"textField", nil];
		NSArray *summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *usedByField = [[NSMutableArray alloc] initWithObjects:@"Used By", @"textField", nil];
		NSArray *scheduleURLField = [[NSMutableArray alloc] initWithObjects:@"Schedule", @"textField", nil];
		layerFields = [[NSArray alloc] initWithObjects:nameField, summaryField, usedByField, scheduleURLField, nil];
		[nameField release];
		[summaryField release];
		[usedByField release];
		[scheduleURLField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	// http://dev.gnar.us/getInfo.py/SportingArenas?udid=3&lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	// TODO: add limitToValidated stuff
	/*NSString *urlString = nil;
	if (limitToValidated == YES) {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/SportingArenas?udid=%@&lat=%f&lon=%f&maxLandmarks=%d",
						   [[UIDevice currentDevice] uniqueIdentifier], 
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxLandmarks]];
	}
	else {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/Vote.py/AddingToSportingArenas?lat=%f&lon=%f&maxDistance=%f",
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxDistance]];
	}
	return [NSURL URLWithString:urlString];*/
	return [self URLForLocation:location limitToValidated:limitToValidated withLayerName:@"SportingArenas"];
}

- (NSArray *)parseDataIntoLandmarks:(NSData *) data {
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release]; reply = nil;
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	NSMutableArray *landmarks = [NSMutableArray array];
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"usedBy"] forKey:@"usedBy"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"scheduleURL"] forKey:@"scheduleURL"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"id"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[layerInfo release];
		[landmarks addObject:landmark];
	}
	
	return landmarks;
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/sportingarenas"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	NSLog(@"Info: %@", info);
	[request setPostValue:[info objectAtIndex:0] forKey:@"name"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"usedBy"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"scheduleURL"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setPostValue:landmarkID forKey:@"landmarkID"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
	[request setData:photoData forKey:@"sportingArenasImage"];
	request.delegate = self;
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"Finished: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}


- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	UIViewController *viewController = [[UIViewController alloc] init];
	//	UIWebView *webView = [[UIWebView alloc] init];
	//	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"menuURL"];
	//
	//	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	//	
	//	viewController.title = self.name;
	//	viewController.view = webView;
	//	[webView release];
	
	return [viewController autorelease];
}

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	NSMutableDictionary *landmarkInfo = [[NSMutableDictionary alloc] init];
	NSLog(@"fieldInformationForLandmark, entire dictionary: %@", layerInfoByLandmarkID);
	NSLog(@"fieldInformationForLandmark, hours value: %@", [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"hours"]);
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"hours"] forKey:@"Hours"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"] forKey:@"Summary"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"description"] forKey:@"Description"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"menu"] forKey:@"Menu"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"name"] forKey:@"Name"];	
	return [landmarkInfo autorelease];
}

@end