#include "winhooker_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>
#include <string>
#include <WinUser.h>
#include <codecvt>
#include <algorithm>
#include <comutil.h>
#include <uiautomation.h>
#include <winapifamily.h>
#include <AtlBase.h>
#include <AtlCom.h>
#include <stdlib.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#define WIN32_LEAN_AND_MEAN
#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/standard_message_codec.h>

#include <tchar.h>
#include <initializer_list>
#include <atlimage.h>
#include <codecvt>
#include <fstream>
#include <map>
#include <memory>
#include <sstream>

#ifdef KEYEVENT_DEBUG
#include "spdlog/spdlog.h" // spdlog.h must be above `bin_to_hex.h`. DO NOT delete blank line below

#include "spdlog/fmt/bin_to_hex.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#endif

#include "codeconvert.h"
#include "keyboard_event_plugin.h"
#include "map_serializer.h"
#include "timestamp.h"
#include "virtual_key_map.h"
#ifdef KEYEVENT_DEBUG
#define debug(...) spdlog::debug(__VA_ARGS__);
#define error(...) spdlog::error(__VA_ARGS__);
#else
#define debug(...)
#define error(...)
#endif
#pragma comment(lib,"comsuppw.lib")
using namespace Gdiplus;
using namespace std;
using namespace flutter;
IUIAutomation *pClientUIA;
IUIAutomationElement *pRootElement;
HHOOK kbdhook;
void log_init() {
#ifdef KEYEVENT_DEBUG
  auto console_sink = std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
  console_sink->set_level(spdlog::level::debug);
  console_sink->set_pattern("[keyboard_event] [%^%l%$] %v");

  auto file_sink =
      std::make_shared<spdlog::sinks::basic_file_sink_mt>("logs/log.txt", true);
  file_sink->set_level(spdlog::level::trace);

  set_default_logger(std::make_shared<spdlog::logger>(
      "multi_sink",
      std::initializer_list<spdlog::sink_ptr>{console_sink, file_sink}));
  spdlog::set_level(spdlog::level::debug);
  spdlog::warn("this should appear in both console and file");
  spdlog::info(
      "this message should not appear in the console, only in the file");
#endif
}
namespace winhooker {
std::unique_ptr<flutter::MethodChannel<>> channel = NULL;
std::unique_ptr<flutter::EventChannel<>> eventChannel = NULL;

std::unique_ptr<EventSink<EncodableValue>> eventSink = NULL;
int GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
{
	UINT num = 0;
	UINT size = 0;

	ImageCodecInfo* pImage = NULL;

	GetImageEncodersSize(&num, &size);
	if (size == 0) return -1;

	pImage = (ImageCodecInfo*)(malloc(size));
	if (pImage == NULL) return -1;

	GetImageEncoders(num, size, pImage);

	for (UINT j = 0; j < num; ++j)
	{
		if (wcscmp(pImage[j].MimeType, format) == 0)
		{
			*pClsid = pImage[j].Clsid;
			free(pImage);
			return j;
		}
	}
	free(pImage);
	return -1;
}
const char WinhookerPlugin::kOnLogCallbackMethod[] = "onLog";
const char WinhookerPlugin::kGetVirtualKeyMapMethod[] = "getVirtualKeyMap";

BOOL isDeadKey(DWORD vkCode) {
  GUITHREADINFO Gti;
  ::ZeroMemory(&Gti, sizeof(GUITHREADINFO));
  Gti.cbSize = sizeof(GUITHREADINFO);
  ::GetGUIThreadInfo(0, &Gti);
  DWORD dwThread = ::GetWindowThreadProcessId(Gti.hwndActive, 0);
  HKL hklLayout = ::GetKeyboardLayout(dwThread);
  UINT isDeadKey =
      ((MapVirtualKeyEx(vkCode, MAPVK_VK_TO_CHAR, hklLayout) & 0x80000000) >>
       31);
  return isDeadKey > 0;
}

inline int wp2keyMsg(WPARAM wp) {
  int keyMsg = 0;
  switch (wp) {
    case WM_KEYDOWN:
      keyMsg = 0;
      break;
    case WM_KEYUP:
      keyMsg = 1;
      break;
    case WM_SYSKEYDOWN:
      keyMsg = 2;
      break;
    case WM_SYSKEYUP:
      keyMsg = 3;
      break;
    default:
      keyMsg = 3;
      break;
  }
  return keyMsg;
}
LRESULT llKeyboardProc(int nCode, WPARAM wp, LPARAM lp) {
  KBDLLHOOKSTRUCT k = *(KBDLLHOOKSTRUCT *)lp;
  if (nCode < 0) return CallNextHookEx(kbdhook, nCode, wp, lp);
  if (!isDeadKey(k.vkCode)) {
    EventSink<EncodableValue> *sink = eventSink.get();
    int keyMsg = wp2keyMsg(wp);
    sink->Success(EncodableValue(EncodableList{
        EncodableValue(keyMsg),                 //
        EncodableValue((int64_t)k.vkCode),      //
        EncodableValue((int64_t)k.scanCode),    //
        EncodableValue((int64_t)k.flags),       //
        EncodableValue((int64_t)k.time),        //
        EncodableValue((int64_t)k.dwExtraInfo)  //
    }));
  }
  return CallNextHookEx(kbdhook, nCode, wp, lp);
};

template <typename T = EncodableValue>
void KeyboardHookEnable(std::unique_ptr<EventSink<T>> &&events) {
  HMODULE hInstance = GetModuleHandle(nullptr);

  if constexpr (std::is_same_v<T, EncodableValue>) {
    eventSink = std::move(events);
  }

  kbdhook = SetWindowsHookEx(WH_KEYBOARD_LL, llKeyboardProc, hInstance, NULL);
 // kbdhook = SetWindowsHookEx(WH_MOUSE_LL, llKeyboardProc, hInstance, NULL);
}


void KeyboardHookDisable(
) {
  if (kbdhook) {
    UnhookWindowsHookEx(kbdhook);
    kbdhook = NULL;
  }
}
template <typename T = EncodableValue>
std::unique_ptr<StreamHandlerError<T>> KeyboardEventOnListen(
    const T *arguments, std::unique_ptr<EventSink<T>> &&events) {
  debug("KeyboardEventOnListen");
  if constexpr (std::is_same_v<T, EncodableValue>) {
    KeyboardHookEnable(std::move(events));
  }
  return NULL;
}

template <typename T = EncodableValue>
std::unique_ptr<StreamHandlerError<T>> KeyboardEventOnError(
    const T *arguments) {
  debug("KeyboardEventOnError");
  KeyboardHookDisable();
  // auto error = std::make_unique<StreamHandlerError<T>>(
  //     "error", "No OnListen handler set", nullptr);
  // return std::move(error);
  return NULL;
}


// static
void WinhookerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "winhooker",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WinhookerPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
    eventChannel =
        std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
            registrar->messenger(), "win_tracker_keyboard",
            &flutter::StandardMethodCodec::GetInstance(
                &MapSerializer::GetInstance())  //
        );
  std::unique_ptr<flutter::StreamHandler<flutter::EncodableValue>>
      KeyboardEventStreamHandler =
          std::make_unique<StreamHandlerFunctions<EncodableValue>>(
              KeyboardEventOnListen<EncodableValue>,
              KeyboardEventOnError<EncodableValue>);
  eventChannel->SetStreamHandler(std::move(KeyboardEventStreamHandler));
  registrar->AddPlugin(std::move(plugin));
}

WinhookerPlugin::WinhookerPlugin() {}

WinhookerPlugin::~WinhookerPlugin() { KeyboardHookDisable();}

void WinhookerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_call.method_name().compare("getVirtualKeyMap") == 0) {
           auto args = *method_call.arguments();
           int type = 0;
           if (std::holds_alternative<int>(args)) {
             type = std::get<int>(args);
           }
           if (type == 0) {
             result->Success(CustomEncodableValue(MapData(virtualKeyName2CodeMap)));
           } else {
             result->Success(CustomEncodableValue(MapData(virtualKeyCode2NameMap)));
           }
         }
         else {
    result->NotImplemented();
  }
}
std::wstring s2ws(const std::string& s) {
    int len;
    int slength = (int)s.length() + 1;
    len = MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, 0, 0);
    wchar_t* buf = new wchar_t[len];
    MultiByteToWideChar(CP_ACP, 0, s.c_str(), slength, buf, len);
     std::wstring r(buf);
    delete[] buf;
    return r;
}

std::string MBFromW(LPCWSTR pwsz, UINT cp) {
  int cch = WideCharToMultiByte(cp, 0, pwsz, -1, 0, 0, NULL, NULL);

  char *psz = new char[cch];

  WideCharToMultiByte(cp, 0, pwsz, -1, psz, cch, NULL, NULL);

  std::string st(psz);
  delete[] psz;

  return st;
}
std::string LPCTSTR_To_string(LPCTSTR str) {
#ifdef UNICODE
  return MBFromW(str, CP_ACP);
#else
  return std::string(str);
#endif
}
void WinhookerPlugin::showText(LPCTSTR text) {
  if (channel == NULL) return;
  auto *channel_pointer = channel.get();
  if (channel_pointer) {
    auto result =
        std::make_unique<flutter::EngineMethodResult<flutter::EncodableValue>>(
            [](const uint8_t *reply, size_t reply_size) {
#pragma warning(disable : 4189)
              // const char *buf = (const char *)reply;
              auto buf = std::string((char *)reply, reply_size);
              // auto result = flutter::MethodResult<flutter::EncodableValue>();
              static auto result =
                  flutter::MethodResultFunctions<flutter::EncodableValue>(
                      [](const flutter::EncodableValue *result) {
                        if (std::holds_alternative<std::string>(*result)) {
                          std::string some_string =
                              std::get<std::string>(*result);
                          debug("onLog: ret = {}", some_string);
                        }
                      },
                      [](const std::string &error_code,
                         const std::string &error_message,
                         const flutter::EncodableValue *error_details) {
                        if (std::holds_alternative<std::string>(
                                *error_details)) {
                          std::string err_string =
                              std::get<std::string>(*error_details);
                          error(
                              "onLog ERROR! errCode={}, msg={}, details={}",  //
                              error_code, error_message, err_string);
                        } else {
                          error("onLog ERROR! errCode={}, msg={}",  //
                                error_code, error_message);
                        }
                      },
                      []() { error("onLog ERROR! NotImplemented!"); });
              flutter::StandardMethodCodec::GetInstance()
                  .DecodeAndProcessResponseEnvelope(reply, reply_size, &result);
            },
            &flutter::StandardMethodCodec::GetInstance());
    channel_pointer->InvokeMethod(
        kOnLogCallbackMethod,
        std::make_unique<flutter::EncodableValue>(LPCTSTR_To_string(text)),
        std::move(result));
  }
}
void showText(LPCTSTR text, int behavior) {
  WinhookerPlugin::showText(text);
}

}  // namespace winhooker
