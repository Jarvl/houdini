
#ifndef HoudiniAPI_hpp
#define HoudiniAPI_hpp

#import <Foundation/Foundation.h>
#include <functional>
#include <string>

class HoudiniAPI
{
public:
	static void login(const std::string& username, const std::string& password, std::function<void(bool success, NSError* error)> onfinish);
	
	static void requestPhoneCall(const std::string& phone_number, std::function<void(bool success, NSError* error)> onfinish);
	
	static void setAvailable(bool available, std::function<void(NSError* error)> onfinish);
	static void isAvailable(std::function<void(bool available, NSError* error)> onfinish);
	
	static void setDeviceToken(const std::string& deviceToken);
	
private:
	static std::string deviceToken;
};

#endif
