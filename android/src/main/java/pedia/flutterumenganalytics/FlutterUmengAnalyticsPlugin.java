package pedia.flutterumenganalytics;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.umeng.analytics.MobclickAgent;
import com.umeng.analytics.MobclickAgent.EScenarioType;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.commonsdk.statistics.common.MLog;
import com.umeng.commonsdk.statistics.common.DeviceConfig;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterUmengAnalyticsPlugin */
public class FlutterUmengAnalyticsPlugin implements MethodCallHandler {
  private Activity activity;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "flutter_umeng_analytics");
    channel.setMethodCallHandler(new FlutterUmengAnalyticsPlugin(registrar.activity()));
  }

  private FlutterUmengAnalyticsPlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {
      init(call, result);
    } else if (call.method.equals("beginPageView")) {
      Log.i("UMENG", (String) call.argument("name"));
      MobclickAgent.onPageStart((String) call.argument("name"));
      result.success(null);
    } else if (call.method.equals("endPageView")) {
      Log.i("UMENG", (String) call.argument("name"));
      MobclickAgent.onPageEnd((String) call.argument("name"));
      result.success(null);
    } else if (call.method.equals("logEvent")) {
      Map<String, String> params = call.arguments();
      HashMap<String,String> map = new HashMap<String,String>();
      map.putAll(params);
      Log.e("UMENG", params.toString());
      String eventId;
      if (map.containsKey("eventId")) {
        eventId = map.get("eventId");
        map.remove("eventId");
        if (map.isEmpty()) {
          MobclickAgent.onEvent((Context) activity, eventId);
        } else {
          MobclickAgent.onEvent((Context) activity, eventId, map);
        }
      } else {
        result.notImplemented();
      }


      result.success(null);
    } else if (call.method.equals("reportError")) {

      Log.e("UMENG", (String) call.argument("error"));
      MobclickAgent.reportError((Context) activity, (String) call.argument("error"));
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  public void init(MethodCall call, Result result) {
//    MobclickAgent.UMAnalyticsConfig config =
//        new MobclickAgent.UMAnalyticsConfig(
//            (Context) activity, (String) call.argument("key"), "default");
//
//    MobclickAgent.startWithConfigure(config);
    UMConfigure.init((Context) activity, (String) call.argument("key"), "ZhaopaiDefault", UMConfigure.DEVICE_TYPE_PHONE, null);
    UMConfigure.setLogEnabled(true);
    getTestDeviceInfo((Context) activity);
    result.success(true);
  }
  public String[] getTestDeviceInfo(Context context){
    String[] deviceInfo = new String[2];
    try {
      if(context != null){
        deviceInfo[0] = DeviceConfig.getDeviceIdForGeneral(context);
        deviceInfo[1] = DeviceConfig.getMac(context);
        Log.i("UMENG", deviceInfo[0]);
        Log.i("UMENG", deviceInfo[1]);
      }
    } catch (Exception e){
    }
    return deviceInfo;
  }
}
