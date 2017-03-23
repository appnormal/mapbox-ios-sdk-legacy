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

@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithView:(RMMapView *)aMapView annotation:(RMEllipseAnnotation *)annotation geometry:(NSDictionary *)geometry;

@end
