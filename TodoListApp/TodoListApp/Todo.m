//
//  Todo.m
//  TodoListApp
//
//  Created by Shady Adel on 12/08/2024.
//

#import "Todo.h"

@implementation Todo

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.descrption forKey:@"descrption"];
    [coder encodeObject:self.priority forKey:@"priority"];
    [coder encodeObject:self.status forKey:@"status"];
    [coder encodeObject:self.date forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _descrption = [coder decodeObjectOfClass:[NSString class] forKey:@"descrption"];
        _priority = [coder decodeObjectOfClass:[NSString class] forKey:@"priority"];
        _status = [coder decodeObjectOfClass:[NSString class] forKey:@"status"];
        _date = [coder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    }
    return self;
}
@end
