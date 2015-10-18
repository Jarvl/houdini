
#ifndef HoudiniAPI_hpp
#define HoudiniAPI_hpp

#import <Foundation/Foundation.h>
#include <functional>
#include <string>

class HoudiniAPI
{
public:
	static void login(const std::string& username, const std::string& password, std::function<void(bool success, const std::string& passwordHash, NSError* error)> onfinish);
	static void signup(const std::string& username, const std::string& password, const std::string& first_name, const std::string& last_name, std::function<void(bool success, const std::string& url, const std::string& passwordHash, const std::string& error_desc, NSError* error)> onfinish);
	
	static void requestPhoneCall(const std::string& phone_number, std::function<void(bool success, NSError* error)> onfinish);
	
	static void setAvailable(bool available, std::function<void(NSError* error)> onfinish);
	static void isAvailable(std::function<void(bool available, NSError* error)> onfinish);
	
	static void setDeviceToken(const std::string& deviceToken);
	
	static std::string getSiteURL();
	
private:
	static std::string deviceToken;
};

#endif
