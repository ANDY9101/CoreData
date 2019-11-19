//
//  Student+CoreDataProperties.h
//  CoreData
//
//  Created by haoran on 2019/11/19.
//  Copyright © 2019 haoran. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nonatomic) int16_t age;
@property (nonatomic) int16_t height;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nonatomic) int16_t number;

@end

NS_ASSUME_NONNULL_END
