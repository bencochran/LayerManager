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
	UILabel *_labelView;
	NSString *_contentString;
	UIImageView *_photoView;
}

@property (nonatomic, retain) GNCellView *cellView;
@property (nonatomic, retain) UILabel *labelView;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, retain) UIImageView *photoView;

//- (void)redisplay;

-(void)setContentString:(NSString *)string withFrameSize:(CGFloat )frameSize;
-(void)displayImage:(UIImage *)newImage;

@end
/////////////
@interface GNCellView : UIView {
}



@end