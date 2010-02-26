//
//  GNTableViewCell.h
//  LayerManager
//
//  Created by Jake Kring on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GNCellView;

@interface GNTableViewCell : UITableViewCell {
	GNCellView *_cellView;
}

@property (nonatomic, retain) GNCellView *cellView;

- (void)redisplay;

@end
/////////////
@interface GNCellView : UIView {
	GNCellView *cellView;
    NSString *contentString;
    BOOL selected;
}
@property (nonatomic, getter=getContentString, setter=setContentString) NSString *contentString;
@property (nonatomic, getter=isSelected) BOOL selected;

@end