//
//  Localidad+Shared.h
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Localidad.h"

@interface Localidad (Shared)
+(Localidad *)sharedLocalidad;
-(NSArray *)getLocalidadesArray;
@end
