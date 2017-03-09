//
//  RMEllipse.h
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMMapLayer.h"

@interface RMEllipse : RMMapLayer

@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithView:(RMMapView *)aMapView geometry:(NSDictionary *)geometry;

@end
