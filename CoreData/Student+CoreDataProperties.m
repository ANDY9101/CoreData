//
//  Student+CoreDataProperties.m
//  CoreData
//
//  Created by haoran on 2019/11/19.
//  Copyright © 2019 haoran. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic age;
@dynamic height;
@dynamic name;
@dynamic sex;
@dynamic number;

@end
