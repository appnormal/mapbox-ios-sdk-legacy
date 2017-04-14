//
//  RMEllipse.h
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMMapLayer.h"

@class RMEllipseAnnotation;

@interface RMEllipse : RMMapLayer

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat tilt;

@property (nonatomic, assign) CGFloat widthInMeters;
@property (nonatomic, assign) CGFloat heightInMeters;

- (instancetype)initWithView:(RMMapView *)aMapView;

@end
