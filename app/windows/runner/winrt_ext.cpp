#include "winrt_ext.h"

#include <windows.h>
#include <appmodel.h>
#include <winrt/windows.foundation.h>
#include <winrt/windows.foundation.collections.h>
#include <winrt/windows.storage.h>
#include <winrt/windows.storage.streams.h>
#include <winrt/windows.applicationmodel.activation.h>
#include <winrt/windows.applicationmodel.datatransfer.h>
#include <winrt/windows.applicationmodel.datatransfer.sharetarget.h>
#include <winrt/windows.data.json.h>

using namespace winrt;
using namespace ::Windows::ApplicationModel;
using namespace ::Windows::ApplicationModel::Activation;
using namespace ::Windows::ApplicationModel::DataTransfer;
using namespace ::Windows::Data::Json;

enum class SharedAttachmentType
{
  IMAGE = 0,
  VIDEO = 1,
  AUDIO = 2,
  FILE = 3,
};

bool IsRunningWithIdentity()
{
  constexpr SIZE_T kPackageNameMaxLength = 1024;
  UINT32 length = kPackageNameMaxLength;
  wchar_t packageName[kPackageNameMaxLength];
  LONG result = GetCurrentPackageFullName(&length, packageName);

  return (result == ERROR_SUCCESS);
}

winrt::hstring GetSharedMedia()
{
  try
  {
    auto args = AppInstance::GetActivatedEventArgs();

    // 2. 检查是否由“发送到”或“分享”触发
    if (args == nullptr || args.Kind() != ActivationKind::ShareTarget)
    {
      return winrt::hstring();
    }

    // 3. 【关键补全】获取 ShareTarget 参数并提取 op (ShareOperation)
    auto share_target_args = args.as<ShareTargetActivatedEventArgs>();
    auto op = share_target_args.ShareOperation();
    auto data = op.Data();
    JsonObject json;
    if (data.Contains(StandardDataFormats::Text()))
    {
      auto text = data.GetTextAsync().get();
      json.SetNamedValue(L"content", JsonValue::CreateStringValue(text));
    }
    if (data.Contains(StandardDataFormats::Uri()))
    {
      auto uri = data.GetUriAsync().get();
      json.SetNamedValue(L"content", JsonValue::CreateStringValue(uri.ToString()));
    }
    if (data.Contains(StandardDataFormats::StorageItems()))
    {
      JsonArray attachments;
      auto storage_items = data.GetStorageItemsAsync().get();
      for (const auto &item : storage_items)
      {
        JsonObject attachment;
        attachment.SetNamedValue(L"type", JsonValue::CreateNumberValue(static_cast<double>(SharedAttachmentType::FILE)));
        attachment.SetNamedValue(L"path", JsonValue::CreateStringValue(item.Path()));
        attachments.Append(attachment);
      }
      json.SetNamedValue(L"attachments", attachments);
    }
    op.ReportCompleted();
    return json.Stringify();
  }
  catch (const winrt::hresult_error &e)
  {
    // 捕获 WinRT 错误（如 .get() 产生的死锁或权限异常），防止程序崩溃
    OutputDebugStringW(e.message().c_str());
    return winrt::hstring();
  }
  catch (...)
  {
    // 确保任何未知错误都不会导致实例锁死
    return winrt::hstring();
  }
}