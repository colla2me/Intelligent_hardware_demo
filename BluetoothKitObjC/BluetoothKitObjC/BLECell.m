//
//  BLECell.m
//  BluetoothKitObjC
//
//  Created by Samuel on 2018/12/18.
//  Copyright © 2018年 samuel. All rights reserved.
//

#import "BLECell.h"

@implementation BLECell {
    UILabel *_nameLabel;
    UILabel *_UUIDLabel;
    UILabel *_stateLabel;
}

- (void)configName:(NSString *)name uuidString:(NSString *)uuidString {
    _nameLabel.text = [NSString stringWithFormat:@"name: %@", name];
    _UUIDLabel.text = [NSString stringWithFormat:@"UUID: %@", uuidString];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(5);
        }];
        
        _UUIDLabel = [[UILabel alloc] init];
        _UUIDLabel.textColor = [UIColor blackColor];
        _UUIDLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_UUIDLabel];
        [_UUIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.top.equalTo(self->_nameLabel.mas_bottom).offset(5);
        }];
    }
    return self;
}
@end
