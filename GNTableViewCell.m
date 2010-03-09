//
//  GNTableViewCell.m
//  LayerManager
//
//  Created by Jake Kring on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNTableViewCell.h"


@implementation GNTableViewCell
@synthesize cellView=_cellView, labelView=_labelView, contentString=_contentString, photoView=_photoView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.cellView = [[GNCellView alloc] init];
		//self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundView = self.cellView;
		[self.backgroundView setAlpha:0.80];
		[self.backgroundView setOpaque:YES];
		self.labelView = [[UILabel alloc] init];
		self.labelView.font = [UIFont boldSystemFontOfSize:12];
		self.labelView.textColor = [UIColor whiteColor];
		self.labelView.backgroundColor = [UIColor clearColor];
		[self.cellView addSubview:self.labelView];
		self.photoView = [[UIImageView alloc] init];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setContentString:(NSString *)newContentString withFrameSize:(CGFloat)newFrameSize {
	if (newContentString != self.contentString) {
		CGFloat lineSpacing = (CGFloat)15;
		self.labelView.text = newContentString;
		CGRect textFrame = CGRectMake(15.0, 0.0, self.contentView.bounds.size.width-45, (newFrameSize*lineSpacing)+(CGFloat)40);
		[self.labelView setFrame:textFrame];
		self.labelView.numberOfLines = newFrameSize+ (CGFloat)1;
		[self.cellView setNeedsDisplay];
		self.contentString = newContentString;
	}
}

-(void)displayImage:(UIImage *)newImage {
	CGRect photoFrame = CGRectMake(10.0, 10.0, self.contentView.bounds.size.width-20, self.contentView.bounds.size.height-20);
	[self.photoView setFrame:photoFrame];
	self.photoView.contentMode = UIViewContentModeScaleAspectFit;
	self.photoView.image = newImage;
	[self.cellView addSubview:self.photoView];
	[self.cellView setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}


@end
//////
@implementation GNCellView

-(id)init{
	if (self = [super init]) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

void CGContextAddRoundedRect (CGContextRef context, CGRect rect, int corner_radius) {
	int x_left = rect.origin.x;
	int x_left_center = rect.origin.x + corner_radius;
	int x_right_center = rect.origin.x + rect.size.width - corner_radius;
	int x_right = rect.origin.x + rect.size.width;
	int y_top = rect.origin.y;
	int y_top_center = rect.origin.y + corner_radius;
	int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
	int y_bottom = rect.origin.y + rect.size.height;
	
	/* Begin! */
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, x_left, y_top_center);
	
	/* First corner */
	CGContextAddArcToPoint(context, x_left, y_top, x_left_center, y_top, corner_radius);
	CGContextAddLineToPoint(context, x_right_center, y_top);
	
	/* Second corner */
	CGContextAddArcToPoint(context, x_right, y_top, x_right, y_top_center, corner_radius);
	CGContextAddLineToPoint(context, x_right, y_bottom_center);
	
	/* Third corner */
	CGContextAddArcToPoint(context, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
	CGContextAddLineToPoint(context, x_left_center, y_bottom);
	
	/* Fourth corner */
	CGContextAddArcToPoint(context, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
	CGContextAddLineToPoint(context, x_left, y_top_center);
	
	CGContextClosePath(context);
	
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect outerRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	//CGRect innerRect = CGRectMake(self.bounds.origin.x+4, self.bounds.origin.y+4, self.bounds.size.width-8, self.bounds.size.height-8);
	//CGContextAddRoundedRect(context, outerRect, 15);
	//CGContextSetLineWidth(context, 2);
	//CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
	//CGContextStrokePath(context);
	CGContextAddRoundedRect(context, outerRect, 15);
	CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
	CGContextFillPath(context);

}

@end