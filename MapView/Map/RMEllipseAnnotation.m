//
//  RMEllipseAnnotation.m
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMEllipseAnnotation.h"

#import "RMEllipse.h"

@implementation RMEllipseAnnotation
{
    NSDictionary *_geometry;
}

#pragma mark - Lifecycle

- (instancetype)initWithMapView:(RMMapView *)aMapView geometry:(NSDictionary *)geometry
{
    NSDictionary *center = geometry[@"center"];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake([center[@"lat"] doubleValue], [center[@"lng"] doubleValue]);
    self = [super initWithMapView:aMapView points:@[[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude]]];
    if (self) {
        _geometry = geometry;
    }
    return self;
}

#pragma mark - Setters

- (void)setLayer:(RMMapLayer *)newLayer
{
    if (newLayer == nil) {
        super.layer = nil;
    }
}

#pragma mark - Getters

- (RMMapLayer *)layer
{
    if (super.layer == nil) {
        RMEllipse *ellipse = [[RMEllipse alloc] initWithView:self.mapView annotation:self geometry:_geometry];
        ellipse.color = _color;
        super.layer = ellipse;
    }
    
    return super.layer;
}

@end
