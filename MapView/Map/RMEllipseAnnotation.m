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
@dynamic fillColor, strokeColor, lineWidth, tilt, widthInMeters, heightInMeters;

#pragma mark - Lifecycle

- (instancetype)initWithMapView:(RMMapView *)aMapView
                         center:(CLLocationCoordinate2D)center
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    return self = [super initWithMapView:aMapView points:@[location]];
}

#pragma mark - Setters

- (void)setLayer:(RMMapLayer *)newLayer
{
    if (newLayer == nil) {
        super.layer = nil;
    }
}

- (void)setFillColor:(UIColor *)fillColor
{
    [(RMEllipse *)[self layer] setFillColor:fillColor];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    [(RMEllipse *)[self layer] setStrokeColor:strokeColor];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    [(RMEllipse *)[self layer] setLineWidth:lineWidth];
}

- (void)setTilt:(CGFloat)tilt
{
    [(RMEllipse *)[self layer] setTilt:tilt];
}

- (void)setHeightInMeters:(CGFloat)heightInMeters
{
    [(RMEllipse *)[self layer] setHeightInMeters:heightInMeters];
}

- (void)setWidthInMeters:(CGFloat)widthInMeters
{
    [(RMEllipse *)[self layer] setWidthInMeters:widthInMeters];
}

#pragma mark - Getters

- (RMMapLayer *)layer
{
    if (super.layer == nil) {
        RMEllipse *ellipse = [[RMEllipse alloc] initWithView:self.mapView];
        super.layer = ellipse;
    }
    
    return super.layer;
}

@end
