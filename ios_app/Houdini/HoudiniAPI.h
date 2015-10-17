//
//  HoudiniAPI.hpp
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#ifndef HoudiniAPI_hpp
#define HoudiniAPI_hpp

#import <Foundation/Foundation.h>
#include <functional>
#include <string>

class HoudiniAPI
{
public:
	
	
	static void login(const std::string& username, const std::string& password, std::function<void(BOOL success, NSError* error)> onfinish);
	
	static void requestPhoneCall(const std::string& phone_number, std::function<void(BOOL success, NSError* error)> onfinish);
};

#endif /* HoudiniAPI_hpp */
