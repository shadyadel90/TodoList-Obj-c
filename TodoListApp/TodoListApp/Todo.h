//
//  Todo.h
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import <Foundation/Foundation.h>

@interface Todo : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *descrption;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSDate *date;

@end
