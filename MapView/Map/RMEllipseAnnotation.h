//
//  RMEllipseAnnotation.h
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMShapeAnnotation.h"

@interface RMEllipseAnnotation : RMShapeAnnotation

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat tilt;

@property (nonatomic, assign) CGFloat widthInMeters;
@property (nonatomic, assign) CGFloat heightInMeters;

- (instancetype)initWithMapView:(RMMapView *)aMapView
                         center:(CLLocationCoordinate2D)center;

@end
